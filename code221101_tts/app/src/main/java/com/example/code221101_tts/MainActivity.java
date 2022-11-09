
package com.example.code221101_tts;
//import androidx.annotation.RequiresApi;
//import androidx.appcompat.app.AppCompatActivity;
//
//import android.os.Build;
//import android.os.Bundle;
//import android.speech.tts.TextToSpeech;
//import android.util.Log;
//import android.view.View;
//import android.widget.Button;
//import android.widget.EditText;
//import android.widget.TextView;
//import android.widget.Toast;
//
//import com.jakewharton.rxbinding4.InitialValueObservable;
//import com.jakewharton.rxbinding4.widget.RxTextView;
//
//import java.util.Locale;
//
//import io.reactivex.rxjava3.annotations.NonNull;
//import io.reactivex.rxjava3.core.Observable;
//import io.reactivex.rxjava3.core.Observer;
//import io.reactivex.rxjava3.disposables.Disposable;
//import io.reactivex.rxjava3.observers.DisposableObserver;
//import io.reactivex.rxjava3.subjects.BehaviorSubject;
//
//public class MainActivity extends AppCompatActivity implements TextToSpeech.OnInitListener {
//
//    private Disposable disposable;
//    private TextToSpeech tts;
//    private Button speak_out;
//    private EditText input_text;
//    private TextView result_text;
//
//    @Override
//    protected void onCreate(Bundle savedInstanceState) {
//        super.onCreate(savedInstanceState);
//        setContentView(R.layout.activity_main);
//
//        tts = new TextToSpeech(this, this);
//        speak_out = findViewById(R.id.button);
//        input_text = findViewById(R.id.editText);
//        result_text = findViewById(R.id.textView);
//
//        observeTextWatcher(input_text);
//
//        speak_out.setOnClickListener(new View.OnClickListener(){
//            @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP) // LOLLIPOP이상 버전에서만 실행 가능
//            @Override
//            public void onClick(View v){
//                speakOut();
//            }
//        });
//    }
//
//    public void observeTextWatcher(TextView tv){
//        Observable ob = RxTextView.textChanges(tv);
//        disposable = ob.subscribe(text -> result_text.setText("INPUT: " + text.toString()));
//    }
//
//    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
//    private void speakOut(){
//        CharSequence text = input_text.getText();
//        tts.setPitch((float)0.6); // 음성 톤 높이 지정
//        tts.setSpeechRate((float)0.1); // 음성 속도 지정
//
//        // 첫 번째 매개변수: 음성 출력을 할 텍스트
//        // 두 번째 매개변수: 1. TextToSpeech.QUEUE_FLUSH - 진행중인 음성 출력을 끊고 이번 TTS의 음성 출력
//        //                 2. TextToSpeech.QUEUE_ADD - 진행중인 음성 출력이 끝난 후에 이번 TTS의 음성 출력
//        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "id1");
//    }
//
//    @Override
//    public void onDestroy() {
//        if(tts!=null){ // 사용한 TTS객체 제거
//            tts.stop();
//            tts.shutdown();
//        }
//        disposable.dispose();
//        super.onDestroy();
//    }
//
//    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
//    @Override
//    public void onInit(int status) { // OnInitListener를 통해서 TTS 초기화
//        if(status == TextToSpeech.SUCCESS){
//            int result = tts.setLanguage(Locale.KOREA); // TTS언어 한국어로 설정
//
//            if(result == TextToSpeech.LANG_NOT_SUPPORTED || result == TextToSpeech.LANG_MISSING_DATA){
//                Log.e("TTS", "This Language is not supported");
//            }else{
//                speak_out.setEnabled(true);
//                speakOut();
//            }
//        }else{
//            Log.e("TTS", "Initialization Failed!");
//        }
//    }
//}
//
////https://hyeals.tistory.com/81

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.os.Build;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import java.util.Locale;

public class MainActivity extends AppCompatActivity implements TextToSpeech.OnInitListener {

    private TextToSpeech tts;
    private Button speak_out;
    private EditText input_text;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        tts = new TextToSpeech(this, this);
        speak_out = findViewById(R.id.button);
        input_text = findViewById(R.id.editText);

        speak_out.setOnClickListener(new View.OnClickListener(){
            @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP) // LOLLIPOP이상 버전에서만 실행 가능
            @Override
            public void onClick(View v){
                speakOut();
            }
        });
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    private void speakOut(){
        CharSequence text = input_text.getText();
        tts.setPitch((float)1.1); // 음성 톤 높이 지정
        tts.setSpeechRate((float)0.5); // 음성 속도 지정

        // 첫 번째 매개변수: 음성 출력을 할 텍스트
        // 두 번째 매개변수: 1. TextToSpeech.QUEUE_FLUSH - 진행중인 음성 출력을 끊고 이번 TTS의 음성 출력
        //                 2. TextToSpeech.QUEUE_ADD - 진행중인 음성 출력이 끝난 후에 이번 TTS의 음성 출력
        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, "id1");
    }

    @Override
    public void onDestroy() {
        if(tts!=null){ // 사용한 TTS객체 제거
            tts.stop();
            tts.shutdown();
        }
        super.onDestroy();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    public void onInit(int status) { // OnInitListener를 통해서 TTS 초기화
        if(status == TextToSpeech.SUCCESS){
            int result = tts.setLanguage(Locale.KOREA); // TTS언어 한국어로 설정

            if(result == TextToSpeech.LANG_NOT_SUPPORTED || result == TextToSpeech.LANG_MISSING_DATA){
                Log.e("TTS", "This Language is not supported");
            }else{
                speak_out.setEnabled(true);
                speakOut();// onInit에 음성출력할 텍스트를 넣어줌
            }
        }else{
            Log.e("TTS", "Initialization Failed!");
        }
    }

}