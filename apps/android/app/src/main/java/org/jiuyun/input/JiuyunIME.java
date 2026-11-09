package org.jiuyun.input;
import android.inputmethodservice.InputMethodService;
import android.view.*;
import android.view.inputmethod.*;
import android.text.InputType;
import android.widget.*;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.content.SharedPreferences;
import java.nio.charset.StandardCharsets;
import java.util.*;
public class JiuyunIME extends InputMethodService {
  private PinyinEngine engine;private org.json.JSONObject scheme;private org.json.JSONArray schemes;private String buffer="";private boolean english=false,privateField=false,symbols=false;private int page=0;
  private LinearLayout root,candidateRow,keys;private TextView composing;private final Map<String,Integer> learned=new HashMap<>();private SharedPreferences prefs;
  private String asset(String name)throws java.io.IOException{try(java.io.InputStream in=getAssets().open(name)){java.io.ByteArrayOutputStream out=new java.io.ByteArrayOutputStream();byte[] b=new byte[4096];int n;while((n=in.read(b))!=-1)out.write(b,0,n);return out.toString("UTF-8");}}
  private void loadScheme(){try{if(schemes==null)schemes=new org.json.JSONArray(asset("schemes.json"));String stored=getSharedPreferences("jiuyun_config",MODE_PRIVATE).getString("scheme","");scheme=stored.equals("full")?null:stored.isEmpty()?schemes.getJSONObject(0):new org.json.JSONObject(stored);if(scheme!=null)Shuangpin.validate(scheme);if(engine!=null)engine.setScheme(scheme);}catch(Exception e){try{scheme=schemes.getJSONObject(0);engine.setScheme(scheme);}catch(Exception ignored){scheme=null;}}}
  private int dp(float n){return (int)(n*getResources().getDisplayMetrics().density+.5f);}
  @Override public void onCreate(){super.onCreate();prefs=getSharedPreferences("jiuyun_frequency",MODE_PRIVATE);for(Map.Entry<String,?> e:prefs.getAll().entrySet())if(e.getValue() instanceof Integer)learned.put(e.getKey(),(Integer)e.getValue());try(java.io.InputStream in=getAssets().open("lexicon.json")){java.io.ByteArrayOutputStream out=new java.io.ByteArrayOutputStream();byte[] block=new byte[4096];int count;while((count=in.read(block))!=-1)out.write(block,0,count);engine=new PinyinEngine(out.toString("UTF-8"));}catch(Exception e){engine=null;}}
  @Override public View onCreateInputView(){root=new LinearLayout(this);root.setOrientation(LinearLayout.VERTICAL);root.setPadding(dp(5),dp(6),dp(5),dp(8));root.setBackgroundColor(Color.rgb(233,237,232));composing=new TextView(this);composing.setPadding(dp(10),0,0,0);composing.setTextColor(Color.rgb(79,116,96));composing.setTextSize(12);root.addView(composing);candidateRow=new LinearLayout(this);root.addView(candidateRow,new LinearLayout.LayoutParams(-1,dp(45)));keys=new LinearLayout(this);keys.setOrientation(LinearLayout.VERTICAL);root.addView(keys);drawKeys();refresh();return root;}
  @Override public void onStartInput(EditorInfo info,boolean restarting){super.onStartInput(info,restarting);buffer="";page=0;loadScheme();int variation=info.inputType&InputType.TYPE_MASK_VARIATION;int type=info.inputType&InputType.TYPE_MASK_CLASS;privateField=(type==InputType.TYPE_CLASS_TEXT&&(variation==InputType.TYPE_TEXT_VARIATION_PASSWORD||variation==InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD||variation==InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD))||(type==InputType.TYPE_CLASS_NUMBER&&variation==InputType.TYPE_NUMBER_VARIATION_PASSWORD)||(info.imeOptions&EditorInfo.IME_FLAG_NO_PERSONALIZED_LEARNING)!=0;english=privateField||type==InputType.TYPE_CLASS_PHONE||type==InputType.TYPE_CLASS_NUMBER;symbols=type==InputType.TYPE_CLASS_PHONE||type==InputType.TYPE_CLASS_NUMBER;if(root!=null){drawKeys();refresh();}}
  @Override public void onFinishInput(){buffer="";page=0;super.onFinishInput();if(root!=null)refresh();}
  @Override public boolean onEvaluateFullscreenMode(){return false;}
  private List<PinyinEngine.Candidate> candidates(){return engine==null||privateField?Collections.emptyList():engine.lookup(buffer,learned);}
  private void refresh(){if(root==null)return;composing.setText(engine==null?"词库加载失败":buffer.isEmpty()?"玖云 · "+(english?"English":scheme==null?"全拼":scheme.optString("name")):buffer);candidateRow.removeAllViews();List<PinyinEngine.Candidate> cs=candidates();page=Math.min(page,Math.max(0,(cs.size()-1)/5));for(int i=page*5;i<Math.min(cs.size(),page*5+5);i++){final String word=cs.get(i).text;Button b=button(word);b.setTextSize(17);b.setOnClickListener(v->commit(word));candidateRow.addView(b,new LinearLayout.LayoutParams(0,-1,1));}if(cs.size()>5){Button next=button("›");next.setContentDescription("下一页候选");next.setOnClickListener(v->{page=(page+1)%((cs.size()+4)/5);refresh();});candidateRow.addView(next,new LinearLayout.LayoutParams(dp(35),-1));}}
  private Button button(String label){Button b=new Button(this);b.setText(label);b.setAllCaps(false);b.setTextSize(16);b.setTextColor(Color.rgb(39,53,46));b.setPadding(0,0,0,0);b.setMinWidth(0);b.setMinimumWidth(0);b.setMinHeight(0);GradientDrawable bg=new GradientDrawable();bg.setColor(Color.WHITE);bg.setCornerRadius(dp(5));b.setBackground(bg);return b;}
  private void drawKeys(){if(keys==null)return;keys.removeAllViews();String[][] rows=symbols?new String[][]{{"1","2","3","4","5","6","7","8","9","0"},{"@","#","$","%","&","-","+","(",")"},{"ABC","!","?",":",";","/","⌫"},{"🌐","中/英",",","空格",".","↵"}}:new String[][]{{"q","w","e","r","t","y","u","i","o","p"},{"a","s","d","f","g","h","j","k","l",";"},{"123","z","x","c","v","b","n","m","⌫"},{"🌐","中/英",",","空格",".","↵"}};
    for(String[] row:rows){LinearLayout line=new LinearLayout(this);line.setPadding(0,dp(3),0,dp(3));for(String label:row){Button b=button(label);if(label.equals("空格"))b.setText(english?"English":"玖云双拼");if(label.equals("↵")){GradientDrawable bg=new GradientDrawable();bg.setColor(Color.rgb(79,116,96));bg.setCornerRadius(dp(5));b.setBackground(bg);b.setTextColor(Color.WHITE);}b.setOnClickListener(v->key(label));LinearLayout.LayoutParams lp=new LinearLayout.LayoutParams(0,dp(45),label.equals("空格")?3:1);lp.setMargins(dp(2),0,dp(2),0);line.addView(b,lp);}keys.addView(line);}}
  private void commit(String text){InputConnection c=getCurrentInputConnection();if(c==null)return;if(!buffer.isEmpty()&&!privateField){String k=PinyinEngine.normalize(buffer)+"|"+text;int n=Math.min(10000,learned.getOrDefault(k,0)+10);learned.put(k,n);prefs.edit().putInt(k,n).apply();}c.commitText(text,1);buffer="";page=0;refresh();}
  private void raw(){InputConnection c=getCurrentInputConnection();if(c!=null&&!buffer.isEmpty())c.commitText(buffer,1);buffer="";page=0;}
  private void key(String k){InputConnection c=getCurrentInputConnection();if(c==null)return;
    if(k.equals("🌐")){((InputMethodManager)getSystemService(INPUT_METHOD_SERVICE)).showInputMethodPicker();return;}
    if(k.equals("123")||k.equals("ABC")){raw();symbols=!symbols;drawKeys();refresh();return;}
    if(k.equals("中/英")){raw();english=!english;drawKeys();refresh();return;}
    if(k.equals("⌫")){if(!buffer.isEmpty()){buffer=buffer.substring(0,buffer.length()-1);c.setComposingText(buffer,1);page=0;}else c.deleteSurroundingTextInCodePoints(1,0);refresh();return;}
    if(k.equals("空格")){List<PinyinEngine.Candidate> cs=candidates();if(!buffer.isEmpty())commit(cs.isEmpty()?buffer:cs.get(page*5).text);else c.commitText(" ",1);return;}
    if(k.equals("↵")){if(!buffer.isEmpty()){raw();refresh();}else if(!sendDefaultEditorAction(true))c.commitText("\n",1);return;}
    if(!english&&!privateField&&(k.matches("[a-z]")||(k.equals(";")&&scheme!=null))){if(buffer.length()<48)buffer+=k;c.setComposingText(buffer,1);page=0;refresh();return;}
    if(!buffer.isEmpty()){List<PinyinEngine.Candidate> cs=candidates();commit(cs.isEmpty()?buffer:cs.get(page*5).text);}
    c.commitText(!english&&!privateField?(k.equals(",")?"，":k.equals(".")?"。":k.equals("?")?"？":k.equals("!")?"！":k):k,1);
  }
}
