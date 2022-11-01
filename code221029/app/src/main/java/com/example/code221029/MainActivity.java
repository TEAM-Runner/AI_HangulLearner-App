package com.example.code221029;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.util.JsonToken;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.xmlpull.v1.XmlPullParser;
import org.xmlpull.v1.XmlPullParserException;
import org.xmlpull.v1.XmlPullParserFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

public class MainActivity extends AppCompatActivity {

    String key = "E48348231D7FB1DB9A8AF0B03A9668CC";
    String data, jsonparsingData;
    TextView text, title_text, description_text;
    EditText search_text;
    XmlPullParser xpp;
    String str;

    ArrayList stringArr = new ArrayList<>();



    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        text = (TextView) findViewById(R.id.apitext);
        title_text = (TextView)findViewById(R.id.titletext);
        description_text = (TextView)findViewById(R.id.descriptiontext);
        search_text = (EditText)findViewById(R.id.searchText);


    }
    public void mOnClick(View v){
        switch (v.getId()){
            case R.id.searchButton:
                new Thread(new Runnable() {
                    @Override
                    public void run() {
                        try {
                            data=getJsonData();
                            Log.e("data", data);
                            title_text.setText(str);


                            getJsonParsingData(data);
                            text.setText(stringArr.toString());
                            //Log.e("jsonparsingData", jsonparsingData);
                            //Log.e("jsonparsingData", "jsonparsingData");



                        } catch (UnsupportedEncodingException e) {
                            e.printStackTrace();
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                text.setText(data); //여기서 실행 안됨

                            }
                        });
                    }
                }).start();
                break;
        }
    }

    String getJsonData() throws UnsupportedEncodingException {
        StringBuffer buffer = new StringBuffer();
        str = search_text.getText().toString();
        StringBuilder sb = new StringBuilder();
        String word = "물고기";
        String urlword = URLEncoder.encode(str, "utf-8");
        String apiURL = "http://opendict.korean.go.kr/api/search?certkey_no=4476&key=" + key + "&target_type=search&req_type=json&part=word&q=" +urlword +"&sort=dict&start=1&num=10";
        try {
            URL url = new URL(apiURL);
            Log.e("url", url.toString());
            InputStream is = url.openStream();
            Log.e("InputStream", "InputStream");

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            Log.e("get","get");
            BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            Log.e("br","br");
            String line = "";
            while ((line = rd.readLine()) != null) {
                sb.append(line);
                //Log.e("while line", sb.toString());


                //if (line = "definition")

            }

            Log.e("line", sb.toString());
            // 여기서 parsing?

            rd.close();
            conn.disconnect();

        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        buffer.append("파싱 끝\n");
        return sb.toString();
        //https://cpcp127.tistory.com/16
    }


    String getJsonParsingData(String data) throws JSONException {
        // 대괄호 [] = jsonArray / 중괄호 {} jsonObject
        Log.e("F:getJsonParsingData", "getJsonParsingData");
        String getdata = data;
        String word, definition;

        JSONObject jsonObject = new JSONObject(getdata);
        Log.e("jsonObject", jsonObject.toString());
        String channel = jsonObject.getString("channel");
        Log.e("channel", channel.toString());
        JSONObject item2 = new JSONObject(channel);
        Log.e("item2", item2.toString());
        String item3 = item2.getString("item");
        Log.e("item3", item3.toString());


        JSONArray item = new JSONArray(item3);

        for (int i =0; i < item.length(); i++){
            JSONObject subJsonObject = item.getJSONObject(i);
            word = subJsonObject.getString("word");
            Log.e("word", word);

            stringArr.add(word);


            String sense3 = subJsonObject.getString("sense");
            Log.e("sense3", sense3);

            JSONArray sense = new JSONArray(sense3);

            for (int j = 0; j<sense.length(); j++){
                JSONObject subJsonObject2 = sense.getJSONObject(j);
                definition = subJsonObject2.getString("definition");
                Log.e("definition", definition);
                stringArr.add(definition);
            }


        }

        for (int k = 0; k < stringArr.size(); k++){
            String kk = (String) stringArr.get(k);
            Log.e("stringArr",kk);
        }


        return getdata.toString();
    }
}

