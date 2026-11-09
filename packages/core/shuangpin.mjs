// Independent, data-driven implementation of published keyboard layouts.
import {PinyinEngine} from './engine.mjs';
const baseInitials=Object.fromEntries('b p m f d t n l g k h j q x r z c s y w'.split(' ').map(s=>[s,s]));
const simple={a:'a',o:'o',e:'e',i:'i',u:'u',v:'v'};
const make=(id,name,initials,finals,zeroRule='prefix',zeroKey='o')=>({id,name,initials:{...baseInitials,...initials},finals:{...simple,...finals},zeroRule,zeroKey,overrides:{}});
const naturalFinals={ai:'l',an:'j',ang:'h',ao:'k',ei:'z',en:'f',eng:'g',er:'r',ia:'w',ian:'m',iang:'d',iao:'c',ie:'x',in:'n',ing:'y',iong:'s',iu:'q',ong:'s',ou:'b',ua:'w',uai:'y',uan:'r',uang:'d',ue:'t',ui:'v',un:'p',uo:'o',ve:'t'};
export const BUILTIN_SCHEMES=[
 make('flypy','小鹤双拼',{zh:'v',ch:'i',sh:'u'},{ai:'d',an:'j',ang:'h',ao:'c',ei:'w',en:'f',eng:'g',er:'r',ia:'x',ian:'m',iang:'l',iao:'n',ie:'p',in:'b',ing:'k',iong:'s',iu:'q',ong:'s',ou:'z',ua:'x',uai:'k',uan:'r',uang:'l',ue:'t',ui:'v',un:'y',uo:'o',ve:'t'},'natural'),
 make('microsoft','微软双拼',{zh:'v',ch:'i',sh:'u'},{...naturalFinals,ing:';',v:'y',ve:'v'}),
 make('ziranma','自然码',{zh:'v',ch:'i',sh:'u'},naturalFinals,'natural'),
 make('sogou','搜狗双拼',{zh:'v',ch:'i',sh:'u'},{...naturalFinals,ing:';',v:'y'}),
 make('abc','智能 ABC',{zh:'a',ch:'e',sh:'v'},{ai:'l',an:'j',ang:'h',ao:'k',ei:'q',en:'f',eng:'g',er:'r',ia:'d',ian:'w',iang:'t',iao:'z',ie:'x',in:'c',ing:'y',iong:'s',iu:'r',ong:'s',ou:'b',ua:'d',uai:'c',uan:'p',uang:'t',ue:'m',ui:'m',un:'n',uo:'o',ve:'m'}),
 make('ziguang','紫光双拼',{zh:'u',ch:'a',sh:'i'},{ai:'p',an:'r',ang:'s',ao:'q',ei:'k',en:'w',eng:'t',er:'j',ia:'x',ian:'f',iang:'g',iao:'b',ie:'d',in:'y',ing:';',iong:'h',iu:'j',ong:'h',ou:'z',ua:'x',uai:'y',uan:'l',uang:'g',ue:'n',ui:'n',un:'m',uo:'o',ve:'n'}),
 make('pyjj','拼音加加',{zh:'v',ch:'u',sh:'i'},{ai:'s',an:'f',ang:'g',ao:'d',ei:'w',en:'r',eng:'t',er:'q',ia:'b',ian:'j',iang:'h',iao:'k',ie:'m',in:'l',ing:'q',iong:'y',iu:'n',ong:'y',ou:'p',ua:'b',uai:'x',uan:'c',uang:'h',ue:'x',ui:'v',un:'z',uo:'o',ve:'x'},'first-letter'),
 make('gb','国标双拼',{zh:'v',ch:'i',sh:'u'},{ai:'k',an:'f',ang:'g',ao:'c',ei:'b',en:'r',eng:'h',er:'l',ia:'q',ian:'d',iang:'n',iao:'m',ie:'t',in:'l',ing:'j',iong:'s',iu:'y',ong:'s',ou:'p',ua:'q',uai:'y',uan:'w',uang:'n',ue:'x',ui:'v',un:'z',uo:'o',ve:'x'},'prefix','a')
];
export const FINAL_NAMES=Object.keys(BUILTIN_SCHEMES[0].finals);
export const INITIAL_NAMES=Object.keys(BUILTIN_SCHEMES[0].initials);
export function validateScheme(s){
 if(!s||typeof s!=='object'||typeof s.name!=='string'||!s.name.trim()||s.name.length>30)throw Error('方案名称需要 1–30 个字');
 if(!['natural','prefix','first-letter'].includes(s.zeroRule))throw Error('零声母规则无效');
 if(!/^[a-z;]$/.test(s.zeroKey||''))throw Error('零声母前缀需要一个字母或分号');
 for(const [group,names]of [['initials',INITIAL_NAMES],['finals',FINAL_NAMES]])for(const n of names)if(typeof s[group]?.[n]!=='string'||!/^[a-z;]$/.test(s[group][n]))throw Error(n+' 需要一个小写字母或分号');
 if(s.overrides&&Object.keys(s.overrides).length>500)throw Error('逐音节覆盖最多 500 项');
 for(const [syllable,code]of Object.entries(s.overrides||{}))if(!/^[a-zv]{1,6}$/.test(syllable)||!Array.isArray(code)||code.length<1||code.length>4||code.some(c=>!/^[a-z;]{2}$/.test(c)))throw Error('音节覆盖需为两键编码数组');
 return {id:String(s.id||'custom').replace(/[^a-z0-9_]/g,'').slice(0,40)||'custom',name:s.name.trim(),initials:Object.fromEntries(INITIAL_NAMES.map(n=>[n,s.initials[n]])),finals:Object.fromEntries(FINAL_NAMES.map(n=>[n,s.finals[n]])),zeroRule:s.zeroRule,zeroKey:s.zeroKey,overrides:{...s.overrides}};
}
export function encodeSyllable(syllable,scheme){
 const s=syllable.toLowerCase().replaceAll('ü','v').replaceAll('u:','v');if(scheme.overrides?.[s])return scheme.overrides[s];
 const initial=/^(zh|ch|sh|[bpmfdtnlgkhjqxrzcsyw])/.exec(s)?.[0]||'';const final=s.slice(initial.length);
 const f=scheme.finals[final];if(!f)return [];
 if(initial){const head=scheme.initials[initial];return head?[head+f]:[];}
 if(scheme.zeroRule==='natural')return [s.length===2?s:s[0]+f];
 if(scheme.zeroRule==='first-letter')return [s[0]+f];
 return [scheme.zeroKey+f];
}
export function encodePinyin(pinyin,scheme){let codes=[''];for(const syllable of pinyin.trim().split(/[\s']+/)){const part=encodeSyllable(syllable,scheme);if(!part.length)return [];codes=codes.flatMap(a=>part.map(b=>a+b)).slice(0,64);}return [...new Set(codes)];}
export function createEngine(entries,{scheme=null,personal={},custom=[]}={}){const all=[...entries,...custom];if(!scheme)return new PinyinEngine(all,{personal});const mapped=all.flatMap(e=>encodePinyin(e.pinyin,scheme).map(code=>({...e,code,short:''})));return new PinyinEngine(mapped,{personal});}
export function keyLegend(scheme,key){if(!scheme)return '';const initial=Object.entries(scheme.initials).filter(([s,k])=>s.length>1&&k===key).map(([s])=>s);const finals=Object.entries(scheme.finals).filter(([s,k])=>s.length>1&&k===key).map(([s])=>s);return [...initial,...finals].join(' · ');}
