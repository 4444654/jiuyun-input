package org.jiuyun.input;
import java.util.*;
import org.json.*;
/** Native port of the starter engine. Only the lexicon is generated/shared. */
public final class PinyinEngine {
  static final class Entry {String text,key,shortKey,pinyin;int weight;Entry(JSONObject j)throws JSONException{text=j.getString("text");pinyin=j.getString("pinyin");key=normalize(pinyin);StringBuilder b=new StringBuilder();for(String s:pinyin.split("[ ']+"))if(!s.isEmpty())b.append(s.charAt(0));shortKey=b.toString();weight=j.optInt("weight",100);}Entry(Entry e,String code){text=e.text;pinyin=e.pinyin;key=code;shortKey="";weight=e.weight;}}
  public static final class Candidate {public final String text; final double score;Candidate(String t,double s){text=t;score=s;}}
  final List<Entry> originals=new ArrayList<>(); final List<Entry> entries=new ArrayList<>(); final Map<String,Entry> exact=new HashMap<>();
  public PinyinEngine(String json)throws JSONException {JSONArray a=new JSONArray(json);for(int i=0;i<a.length();i++){Entry e=new Entry(a.getJSONObject(i));entries.add(e);originals.add(e);Entry old=exact.get(e.key);if(old==null||old.weight<e.weight)exact.put(e.key,e);}}
  public void setScheme(JSONObject scheme){entries.clear();exact.clear();for(Entry e:originals){List<Entry> mapped=new ArrayList<>();if(scheme==null)mapped.add(e);else for(String code:Shuangpin.encode(e.pinyin,scheme))mapped.add(new Entry(e,code));for(Entry m:mapped){entries.add(m);Entry old=exact.get(m.key);if(old==null||old.weight<m.weight)exact.put(m.key,m);}}}
  static String normalize(String s){return s.toLowerCase(Locale.ROOT).replace("ü","v").replace("u:","v").replaceAll("[^a-z;]","");}
  public List<Candidate> lookup(String raw,Map<String,Integer> learned){String k=normalize(raw);if(k.length()>48)k=k.substring(0,48);if(k.isEmpty())return new ArrayList<>();List<Candidate> found=new ArrayList<>();
    for(Entry e:entries){int rank=e.key.equals(k)?100000:e.shortKey.equals(k)?50000:e.key.startsWith(k)?20000:0;if(rank>0)found.add(new Candidate(e.text,rank+e.weight-(e.key.length()-k.length())*2+Math.min(10000,learned.getOrDefault(k+"|"+e.text,0))*10));}
    double[] scores=new double[k.length()+1];Arrays.fill(scores,Double.NEGATIVE_INFINITY);scores[0]=0;String[] texts=new String[k.length()+1];texts[0]="";int[] parts=new int[k.length()+1];
    for(int end=1;end<=k.length();end++)for(int start=0;start<end;start++){Entry e=exact.get(k.substring(start,end));if(e==null||texts[start]==null)continue;double score=scores[start]+Math.pow(end-start,2)+Math.log1p(e.weight)/10-2;if(score>scores[end]){scores[end]=score;texts[end]=texts[start]+e.text;parts[end]=parts[start]+1;}}
    if(parts[k.length()]>1)found.add(new Candidate(texts[k.length()],80000+scores[k.length()]));
    found.sort((a,b)->Double.compare(b.score,a.score));Set<String> seen=new HashSet<>();List<Candidate> result=new ArrayList<>();for(Candidate c:found)if(seen.add(c.text)){result.add(c);if(result.size()>=60)break;}return result;
  }
}
