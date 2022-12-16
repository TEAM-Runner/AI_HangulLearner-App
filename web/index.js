// ******************** settings ********************
// ******************** settings ********************
// const PORT = 5000;
const express = require("express")
const axios = require("axios")
const cheerio = require("cheerio")
const app = express();
const path = require('path')
var fs = require('fs');
var qs = require('querystring');
var http = require('http');
var url = require('url');
const bodyParser = require("body-parser")
const {urlencoded} = require("express");

app.use(bodyParser.urlencoded({
    extended:true
}));
app.set("view engine", "ejs");
app.use(express.static(__dirname + "/public"));



//css 추가방법 찾는중
app.use(express.static('public'));

// ******************** variable ********************
// ******************** variable ********************

var daumWordArray = [''];
var daumMeanArray = [''];

var FlutterText = '저 멀리 깊고 푸른 바다 속에, 물고기 한 마리가 살고 있었습니다. 그 물고기는 보통 물고기가 아니라 온 바다에서 가장 아름다운 물고기였습니다. 파랑, 초록, 자줏빛 바늘 사이사이에 반짝반짝 빛나는 은빛 비늘이 박혀 있었거든요. 다른 물고기들도 그 물고기의 아름다운 모습에 감탄했습니다. 물고기들은 그 물고기를 무지개 물고기라고 불렀습니다. 물고기들은 무지개 물고기에게 말을 붙였습니다';


// ******************** function ********************
// ******************** function ********************
async function daum(word) {
    var korean = /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/; //한글 - 한국어 사전 뜻만 가져오기 위해
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "1";
    var SearchWord = encodeURI(word);
    var link = 'https://dic.daum.net/search.do?q='+ SearchWord
    console.log("link: ", link);

    var resp = await axios.get('https://dic.daum.net/search.do?q='+ SearchWord );
    var $ = cheerio.load(resp.data);

    var meanElements = $('.list_search') // 검색결과의 뜻 class명

    meanElements.each((idx, el) => {
        // 한국어 사전 값만 daumMeanArray 배열에 push
        // 다른 사전 값에도 한국어가 있으면 배열에 들어감 -> 수정 필요
        if (korean.test($(el).text().trim())){
            var sword = $(el).text().trim()
            //sword = sword.replace(/(?:\r\n|\r|\n|\t|)/g, '');
            sword = sword.replace(/(?:\r|\r|\t|)/g, '');

            daumMeanArray.push(sword)
        }
    });

    // 배열에서 빈 값 제거
    daumMeanArray  = daumMeanArray.filter(function(item) {
        return item !== null && item !== undefined && item !== '';
    });

    for (var i=0; i<daumMeanArray.length; i++){
        daumMeanArray[i]= daumMeanArray[i].replace(/(\n)/g, "<br/>");
    }

    /////////////////////////////////////////////////////////  wordElements
    // var wordElements = $('.search_box');
    //
    // wordElements.each((idx, el) => {
    //     // 한국어 사전 값만 daumMeanArray 배열에 push
    //     // 다른 사전 값에도 한국어가 있으면 배열에 들어감 -> 수정 필요
    //     if (korean.test($(el).text().trim())){
    //         var sword = $(el).text().trim()
    //         //sword = sword.replace(/(?:\r\n|\r|\n|\t|)/g, '');
    //         sword = sword.replace(/(?:\r|\r|\t|)/g, '');
    //         daumWordArray.push(sword)
    //     }
    // });
    //
    // // 배열에서 빈 값 제거
    // daumWordArray  = daumWordArray.filter(function(item) {
    //     return item !== null && item !== undefined && item !== '';
    // });
    //
    // for (var i=0; i<daumWordArray.length; i++){
    //     console.log("it's working");
    //     daumWordArray[i]= daumWordArray[i].replace(/(\n)/g, "<br/>");
    // }

    console.log("daumMeanArray.length: ", daumMeanArray.length);
    console.log("daumMeanArray: ", daumMeanArray);
    // console.log("daumWordArray.length: ", daumWordArray.length);
    // console.log("daumWordArray: ", daumWordArray);
    return daumMeanArray;
}




// ******************** route ********************
// ******************** route ********************

app.listen(process.env.PORT || 5000, () =>
    console.log(`The server is active and running`)
);




// [(임시)메인 화면] 플러터에서 글자인식한 문장들 + 사전/음성 버튼 (선택)
app.get("/", (req, res) => {
    res.render("../views/main", {'FlutterText': FlutterText});
});

// [사전 화면] 단어 버튼을 보여줌
app.get("/dic", (req, res) => {
    var wordbutton = FlutterText.split(" "); // FlutterText를 단어 단위로 배열에 저장
    res.render("../views/dic", {'text': wordbutton}); // dic.ejs에 배열을 전송
});

// [사전 화면] 클릭한 단어 버튼 값을 받아서 "/dic/word"에 querystring으로 보냄
app.post('/dic', (req, res) => {
    var buttonName = req.body.buttonName; // 누른 버튼의 buttonName(값)을 가져옴
    res.redirect('/dic/word/?word=' + buttonName); // word 값 전송
});

// [사전 화면] - 다음 사전 연결
app.get("/dic/word", async (req, res) => {

    console.log("daumMeanArray /dic/word: ", daumMeanArray);
    var word = req.query.word; // 검색할 단어
    var meanArray = await daum(word); // 단어 뜻 (배열)
    // daumWordArray 추가 필요 - 나중에 수정
    // var wordArray = daumWordArray;

    // res.render("../views/dic_word", {'word': word, 'meanArray': meanArray, 'wordArray': wordArray}); // dic_word.ejs에 배열을 전송
    res.render("../views/dic_word", {'word': word, 'meanArray': meanArray}); // dic_word.ejs에 배열을 전송
    daumMeanArray.splice(0);
    daumWordArray.splice(0);

});

// [TTS 화면]
app.get("/tts", (req, res) => {
    var wordbutton = FlutterText.split("."); // FlutterText를 문장 단위로 배열에 저장
    res.render("../views/tts", {'text': wordbutton}); // tts.ejs에 배열을 전송
});



///////////////////////// css test
// app.get('/css', (request, responseC) => {
//     responseC.sendFile(path.join(__dirname, "style.css"))
// });