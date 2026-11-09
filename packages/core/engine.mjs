export const normalize = (s) => String(s).toLowerCase().replaceAll('ü', 'v').replaceAll('u:', 'v').replace(/[^a-z;]/g, '');
export const initials = (s) => s.trim().split(/[\s']+/).map(x => x[0] || '').join('');
export class PinyinEngine {
  constructor(entries, { personal = {}, custom = [] } = {}) {
    this.personal = personal;
    this.entries = [...entries, ...custom].filter(e => e.text && normalize(e.pinyin)).map(e => ({...e, key: e.code ?? normalize(e.pinyin), short: e.short ?? initials(e.pinyin), weight: Number(e.weight) || 100}));
    this.exact = new Map();
    for (const e of this.entries) { const group = this.exact.get(e.key) || []; group.push(e); this.exact.set(e.key, group); }
    for (const group of this.exact.values()) group.sort((a,b)=>b.weight-a.weight);
  }
  segment(key) {
    const dp = Array(key.length + 1).fill(null); dp[0] = {text:'',score:0,parts:0};
    for(let end=1; end<=key.length; end++) for(let start=0; start<end; start++) {
      const word = this.exact.get(key.slice(start,end))?.[0];
      if (!word || !dp[start]) continue;
      const candidate = {text:dp[start].text+word.text, score:dp[start].score + (end-start)**2 + Math.log1p(word.weight)/10-2, parts:dp[start].parts+1};
      if(!dp[end] || candidate.score>dp[end].score) dp[end]=candidate;
    }
    return dp[key.length];
  }
  lookup(input, { limit = 30, abbreviations = true } = {}) {
    const key = normalize(input).slice(0,48); if (!key) return [];
    const found = [];
    for(const e of this.entries) {
      const kind = e.key===key?'exact':abbreviations && e.short===key?'initials':e.key.startsWith(key)?'prefix':null;
      if(!kind) continue;
      const rank = {exact:100000,initials:50000,prefix:20000}[kind] + Math.min(10000,Number(this.personal[key+'|'+e.text])||0)*10 + e.weight - (e.key.length-key.length)*2;
      found.push({text:e.text,pinyin:e.pinyin,kind,score:rank});
    }
    const sentence = this.segment(key);
    if(sentence && sentence.parts>1) found.push({text:sentence.text,pinyin:input,kind:'sentence',score:80000+sentence.score});
    const seen=new Set();
    return found.sort((a,b)=>b.score-a.score || a.text.localeCompare(b.text,'zh-CN')).filter(e=>!seen.has(e.text) && seen.add(e.text)).slice(0,limit);
  }
  learn(input,text) {const k=normalize(input)+'|'+text; this.personal[k]=Math.min(10000,(Number(this.personal[k])||0)+10);}
}
