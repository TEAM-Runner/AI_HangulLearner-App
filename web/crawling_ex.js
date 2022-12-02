// const axios = require("axios");
// const cheerio = require("cheerio");
// var iconv = require('iconv-lite');
// const log = console.log;
// process.env.NODE_TLS_REJECT_UNAUTHORIZED = "1";
// var textArray = '';
// var a;

async function main() {
  const axios = require("axios");
  const cheerio = require("cheerio");
  var iconv = require('iconv-lite');
  const log = console.log;
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "1";
  var textArray = '';
  var a;

  // ❶ HTML 로드하기
  const resp = await axios.get(
    //'https://dic.daum.net/word/view.do?wordid=kkw000095073&q=%EB%AC%BC%EA%B3%A0%EA%B8%B0&supid=kku000118167' // 뜻 1개일 때
    'https://dic.daum.net/search.do?q=%EC%82%AC%EA%B3%BC&dic=kor' // 뜻 여러개일 때
  );

  const $ = cheerio.load(resp.data); // ❷ HTML을 파싱하고 DOM 생성하기
  //const elements = $('.list_mean');    // ❸ CSS 셀렉터로 원하는 요소 찾기 // 뜻 1개일때
  const elements = $('.list_search');    // ❸ CSS 셀렉터로 원하는 요소 찾기 // 뜻 여러개일 때
  var i = 0;


  // ➍ 찾은 요소를 순회하면서 요소가 가진 텍스트를 출력하기
  elements.each((idx, el) => {
    // ❺ text() 메서드를 사용하기 위해 Node 객체인 el을 $로 감싸서 cheerio 객체로 변환
    // console.log($(el).text().trim() + '****' + i);
    textArray += $(el).text().trim();
    i++;
  });

  //const edit = document.createElement('button');
  //edit.text = 'hihihihihihih';
  console.log(textArray);
  //alert(textArray)
  return textArray;
  //printMain(textArray);
}


// const printMain = async () => {
//   const a = await main().th;
//   console.log(a);
//   return a;
// };

main();














// const getHtml = async () => {
//   try {
//     return await axios.get('https://dic.daum.net/word/view.do?wordid=kkw000127502&q=%EC%82%AC%EA%B3%BC&suptype=KOREA_KK',
//     {Headers: {'User-Agent': 'Mozilla/5.0'}}); // 크롤링 방지 우회를 위한 User-Agent setting
//   } catch (error) {
//     console.error(error);
//   }
// };

// getHtml()
//   .then((html) => {
//     // axios 응답 스키마 `data`는 서버가 제공한 응답(데이터)을 받는다.
//     // load()는 인자로 html 문자열을 받아 cheerio 객체 반환
//     const $ = cheerio.load(html.data);
//     selector = "#mArticle > div.search_cont > div:nth-child(3) > div:nth-child(2)"; // 있음
//     selector = "#mArticle > div.detail_cont > div.cont_left > div:nth-child(2) > div:nth-child(4)";

//     const data = {
//       //mainContents: $('#\39 e3f524a15a64ed3a05db0abb2dcd0b3 > div > a').text(),
//       mainContents: $(selector).text(),

//     };
//     //data_s = data.toString();
//     //alert(data);
//     return data;
//   })
//   .then((res) => log(res));
//   //log(dicdata);