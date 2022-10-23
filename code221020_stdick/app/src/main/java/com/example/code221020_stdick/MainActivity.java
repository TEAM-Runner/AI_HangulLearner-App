package com.example.code221020_stdick;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
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

    String clientId = "CBCBBFDA17704AC5BA749D55282374C0 ";
    //String clientSecret ="jlnGNRUkqA";
    int display = 1;
    int jsonArray_length;

    TextView text, title_text, description_text;
    EditText search_text;
    //Button searchButton;

    String string_data;
    String title = "";
    String description = "";
    String input_search_text = "";
    String tree = "나무";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main); //메인 레이아웃
        text = findViewById(R.id.apitext);
        title_text = findViewById(R.id.titletext);
        description_text = findViewById(R.id.descriptiontext);
        //searchButton = findViewById(R.id.searchButton);
        search_text = findViewById(R.id.searchText);


        View.OnClickListener listener = new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                //버튼을 눌렀을 때 실행할 동작 설정
                Log.e("BUTTON", "onClick");
                if (search_text.getText().equals("")) {
                    Toast.makeText(MainActivity.this, "값을 입력하세요", Toast.LENGTH_LONG).show();
                } else {
                    input_search_text = search_text.getText().toString();
                }
                Log.e("input_search_text", input_search_text);

            }

            ;

        };
        Button searchButton = (Button) findViewById(R.id.searchButton);
        searchButton.setOnClickListener(listener); //위치

        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    string_data = data();
                        try {
                            // 대괄호 [] = jsonArray / 중괄호 {} jsonObject
                            JSONObject jsonObject = new JSONObject(string_data);
                            String lastBuildDate = jsonObject.getString("item");
                            JSONArray jsonArray = new JSONArray(lastBuildDate);
                            //jsonObject.getJSONArray("title");

                            jsonArray_length = jsonArray.length();

                            for (int i = 0; i < 1; i++) { //원래 중간값 i<jsonArray.length()-1 /마지막 description값이 없어서 임의로 -1함!
                                JSONObject subJsonObject = jsonArray.getJSONObject(i);
                                title = subJsonObject.getString("channel");
                                description = subJsonObject.getString("item");
                                System.out.println("for************************************");
                                System.out.println("channel: " + title + "\n" + "item: " + description); //코드 수정한거라 변수명 이상함 - 수정 필요

                            }

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }


                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            text.setText(string_data);
                            title_text.setText(title);
                            description_text.setText(description);

                        }
                    });
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }).start();




        ///

        TrustManager[] trustAllCerts = new TrustManager[]{new X509TrustManager() {
            public java.security.cert.X509Certificate[] getAcceptedIssuers() {
                return new java.security.cert.X509Certificate[]{};
            }

            @Override
            public void checkClientTrusted(
                    java.security.cert.X509Certificate[] chain,
                    String authType)
                    throws java.security.cert.CertificateException {
                // TODO Auto-generated method stub
            }

            @Override
            public void checkServerTrusted(
                    java.security.cert.X509Certificate[] chain,
                    String authType)
                    throws java.security.cert.CertificateException {
                // TODO Auto-generated method stub
            }
        }};

        // Install the all-trusting trust manager
        try {
            SSLContext sc = SSLContext.getInstance("TLS");
            sc.init(null, trustAllCerts, new java.security.SecureRandom());
            HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
        } catch (Exception e) {
            e.printStackTrace();
        }
        //출처: https://yujuwon.tistory.com/entry/Trust-anchor-for-certification-path-not-found-해결하기 [Ju Factory:티스토리]


        ////

    }

    String data() throws IOException { //api를 받아오는 함수
        StringBuilder sb = new StringBuilder();
        try{
            Log.e("sb", "HIHIHI");
            //String apiURL = "https://stdict.korean.go.kr/api/search.do?&key="+clientId+"&type_search=search&req_type=json&q=" + word;
            String word = URLEncoder.encode(tree, "utf-8");
            String apiURL = "https://stdict.korean.go.kr/api/search.do?&key=CBCBBFDA17704AC5BA749D55282374C0&type_search=search&req_type=json&q=" + word;


            URL url = new URL(apiURL);
            Log.e("url", url.toString());

            HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            Log.e("get","get");


            BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            Log.e("br","br");

//            if(conn.getResponseCode() >= 200 && conn.getResponseCode() <= 500) { //500으로 수정
//                Log.e("conn","if");
//                rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
//            } else {
//                Log.e("conn","else");
//                rd = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
//            }


            Log.e("sb","sb");

            String line = "";
            Log.e("line","line");

            while ((line = rd.readLine()) != null) {
                sb.append(line);
                //Log.e("sb",sb.toString());  - 값 일단 여기서 출력됨
            }

            rd.close();
            conn.disconnect();
            Log.e("sb", sb.toString());
            //System.out.println(sb.toString());

        } catch (Exception e){
            e.printStackTrace();
        }
        return sb.toString();
    }






}





//******************************* ver2

//package com.example.code221020_stdick;
//
//import androidx.appcompat.app.AppCompatActivity;
//
//import android.os.Bundle;
//import android.provider.DocumentsContract;
//import android.util.Log;
//import android.view.View;
//import android.widget.Button;
//import android.widget.EditText;
//import android.widget.TextView;
//import android.widget.Toast;
//
//import org.json.JSONArray;
//import org.json.JSONException;
//import org.json.JSONObject;
//import org.json.JSONTokener;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.w3c.dom.Node;
//import org.w3c.dom.NodeList;
//import org.xml.sax.SAXException;
//
//import java.io.BufferedReader;
//import java.io.IOException;
//import java.io.InputStream;
//import java.io.InputStreamReader;
//import java.io.UnsupportedEncodingException;
//import java.net.HttpURLConnection;
//import java.net.URL;
//import java.net.URLEncoder;
//import java.util.ArrayList;
//import java.util.Dictionary;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//
//import javax.net.ssl.HttpsURLConnection;
//import javax.net.ssl.SSLContext;
//import javax.net.ssl.TrustManager;
//import javax.net.ssl.X509TrustManager;
//import javax.xml.parsers.DocumentBuilder;
//import javax.xml.parsers.DocumentBuilderFactory;
//import javax.xml.parsers.ParserConfigurationException;
//
//
//public class MainActivity extends AppCompatActivity {
//
//    String clientId = "CBCBBFDA17704AC5BA749D55282374C0 ";
//    //String clientSecret ="jlnGNRUkqA";
//    int display = 1;
//    int jsonArray_length;
//
//    TextView text, title_text, description_text;
//    EditText search_text;
//    //Button searchButton;
//
//    String string_data;
//    String title = "";
//    String description = "";
//    String input_search_text = "";
//    String tree = "나무";
//
//    String apiURL;
//
//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        setContentView(R.layout.activity_main); //메인 레이아웃
//        text = findViewById(R.id.apitext);
//        title_text = findViewById(R.id.titletext);
//        description_text = findViewById(R.id.descriptiontext);
//        //searchButton = findViewById(R.id.searchButton);
//        search_text = findViewById(R.id.searchText);
//
//
//        View.OnClickListener listener = new View.OnClickListener() {
//            @Override
//            public void onClick(View view) {
//                //버튼을 눌렀을 때 실행할 동작 설정
//                Log.e("BUTTON", "onClick");
//                if (search_text.getText().equals("")) {
//                    Toast.makeText(MainActivity.this, "값을 입력하세요", Toast.LENGTH_LONG).show();
//                } else {
//                    input_search_text = search_text.getText().toString();
//                }
//                Log.e("input_search_text", input_search_text);
//
//            }
//
//
//        };
//        Button searchButton = (Button) findViewById(R.id.searchButton);
//        searchButton.setOnClickListener(listener); //위치?
//
//        new Thread(new Runnable() {
//            @Override
//            public void run() {
//                try {
//                    string_data = data();
//                    try {
//                        // 대괄호 [] = jsonArray / 중괄호 {} jsonObject
//                        // channel - jsonObject
//                        // item - jsonArray
//                        // word - jsonObject
//                        // sense - jsonObject
//                        // definition - jsonObject
//
//
//
//                        JSONObject jsonObject = new JSONObject(string_data);
//                        Log.e("jsonObject", jsonObject.toString());
//                        JSONObject channel = (JSONObject)jsonObject.get("channel");
//                        Log.e("channel", channel.toString());
//                        JSONObject title = (JSONObject)channel.get("title");
//                        Log.e("title", title.toString());
//
//
//
//
//                        String lastBuildDate = jsonObject.getString("item");
//                        JSONArray jsonArray = new JSONArray(lastBuildDate);
//                        //jsonObject.getJSONArray("title");
//
//                        jsonArray_length = jsonArray.length();
//
//                        for (int i = 0; i < 1; i++) { //원래 중간값 i<jsonArray.length()-1 /마지막 description값이 없어서 임의로 -1함!
//                            JSONObject subJsonObject = jsonArray.getJSONObject(i);
//                            //channel = subJsonObject.getString("channel");
//                            description = subJsonObject.getString("item");
//                            System.out.println("for************************************");
//                            System.out.println("channel: " + title + "\n" + "item: " + description); //코드 수정한거라 변수명 이상함 - 낮ㅇ에 수정 필요
//
//                        }
//
//                    } catch (JSONException e) {
//                        e.printStackTrace();
//                    }
//
//
//
//                    runOnUiThread(new Runnable() {
//                        @Override
//                        public void run() {
//                            text.setText(string_data);
//                            title_text.setText(title);
//                            description_text.setText(description);
//
//                        }
//                    });
//                } catch (IOException e) {
//                    e.printStackTrace();
//                }
//            }
//        }).start();
//
//
//
//
//        ///
//
//        TrustManager[] trustAllCerts = new TrustManager[]{new X509TrustManager() {
//            public java.security.cert.X509Certificate[] getAcceptedIssuers() {
//                return new java.security.cert.X509Certificate[]{};
//            }
//
//            @Override
//            public void checkClientTrusted(
//                    java.security.cert.X509Certificate[] chain,
//                    String authType)
//                    throws java.security.cert.CertificateException {
//                // TODO Auto-generated method stub
//            }
//
//            @Override
//            public void checkServerTrusted(
//                    java.security.cert.X509Certificate[] chain,
//                    String authType)
//                    throws java.security.cert.CertificateException {
//                // TODO Auto-generated method stub
//            }
//        }};
//
//        // Install the all-trusting trust manager
//        try {
//            SSLContext sc = SSLContext.getInstance("TLS");
//            sc.init(null, trustAllCerts, new java.security.SecureRandom());
//            HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        //출처: https://yujuwon.tistory.com/entry/Trust-anchor-for-certification-path-not-found-해결하기 [Ju Factory:티스토리]
//
//
//        ////
//
//    }
//
//    String data() throws IOException { //api를 받아오는 함수
//        StringBuilder sb = new StringBuilder();
//        try{
//            Log.e("sb", "HIHIHI");
//            //String apiURL = "https://stdict.korean.go.kr/api/search.do?&key="+clientId+"&type_search=search&req_type=json&q=" + word;
//            String word = URLEncoder.encode(tree, "utf-8");
//            apiURL = "https://stdict.korean.go.kr/api/search.do?&key=CBCBBFDA17704AC5BA749D55282374C0&type_search=search&req_type=json&q=" + word;
//
//
//            URL url = new URL(apiURL);
//            Log.e("url", url.toString());
//
//            HttpsURLConnection conn = (HttpsURLConnection) url.openConnection();
//            conn.setRequestMethod("GET");
//            Log.e("get","get");
//
//
//            BufferedReader rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
//            Log.e("br","br");
//
////            if(conn.getResponseCode() >= 200 && conn.getResponseCode() <= 500) { //500으로 수정
////                Log.e("conn","if");
////                rd = new BufferedReader(new InputStreamReader(conn.getInputStream()));
////            } else {
////                Log.e("conn","else");
////                rd = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
////            }
//
//
//            Log.e("sb","sb");
//
//            String line = "";
//            Log.e("line","line");
//
//            while ((line = rd.readLine()) != null) {
//                sb.append(line);
//                //Log.e("sb",sb.toString());  - 값 일단 여기서 출력됨
//            }
//
//            rd.close();
//            conn.disconnect();
//            Log.e("sb", sb.toString());
//            //System.out.println(sb.toString());
//
//        } catch (Exception e){
//            e.printStackTrace();
//        }
//        return sb.toString();
//    }
//
//
//
//
//
//
//}
