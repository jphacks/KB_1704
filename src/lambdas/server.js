var http = require('http');
var url = require('url');
var fs = require('fs');
var server = http.createServer();
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;

function getFaceId(srcImg) {
    var request = new XMLHttpRequest();
    // ハンドラの登録.
    request.onreadystatechange = function () {
        switch (request.readyState) {
        case 0:
            // 未初期化状態.
            console.log('uninitialized!');
            break;
        case 1: // データ送信中.
            console.log('loading...');
            break;
        case 2: // 応答待ち.
            console.log('loaded.');
            break;
        case 3: // データ受信中.
            console.log('interactive... ' + request.responseText.length + ' bytes.');
            break;
        case 4: // データ受信完了.
            if (request.status == 200 || request.status == 304) {
                console.log('COMPLETE!');
                var data = JSON.parse(request.responseText);
                sentIdentify(data[0].faceId);
            } else {
                console.log('Failed. HttpStatus: ' + request.responseText);
            }
            break;
        }
    };
    request.open("POST", " https://eastasia.api.cognitive.microsoft.com/face/v1.0/detect?true&false&gender");
    request.setRequestHeader("Content-Type", "application/json");
    request.setRequestHeader("Ocp-Apim-Subscription-Key", "bcfb3a73caf944a095b8a6c41be5f7b7");
    request.addEventListener("error", () => {
        console.error("Network Error");
    });
    s = "https://s3-ap-northeast-1.amazonaws.com/facard-photo/" + srcImg;
    request.send("{'url': 'https://s3-ap-northeast-1.amazonaws.com/facard-photo/" + srcImg + "'}");
}

function sentIdentify(data) {
    console.log("FaceId of user is "+data);
    var request = new XMLHttpRequest();
    // ハンドラの登録.
    request.onreadystatechange = function () {
        switch (request.readyState) {
        case 0:
            // 未初期化状態.
            console.log('uninitialized!');
            break;
        case 1: // データ送信中.
            console.log('loading...');
            break;
        case 2: // 応答待ち.
            console.log('loaded.');
            break;
        case 3: // データ受信中.
            console.log('interactive... ' + request.responseText.length + ' bytes.');
            break;
        case 4: // データ受信完了.
            if (request.status == 200 || request.status == 304) {
                console.log('COMPLETE!');
                console.log(request.responseText);
                var result = JSON.parse(request.responseText);
                var FACE_ID = result[0].faceId;
                var PERSON_ID = result[0].candidates[0].personId;
                var CONFIDENCE = result[0].candidates[0].confidence;
                console.log("FACE_ID=" + FACE_ID);
                console.log("PERSON_ID=" + PERSON_ID);
                console.log("CONFIDENCE=" + CONFIDENCE);
            } else {
                console.log('Failed. HttpStatus: ' + request.statusText);
            }
            break;
        }
    };
    request.open("POST", " https://eastasia.api.cognitive.microsoft.com/face/v1.0/identify?");
    request.setRequestHeader("Content-Type", "application/json");
    request.setRequestHeader("Ocp-Apim-Subscription-Key", "bcfb3a73caf944a095b8a6c41be5f7b7");
    request.addEventListener("error", () => {
        console.error("Network Error");
    });
    var array = [data];
    var s = "{'faceIds': " + "['"+array +"']"+ ",'personGroupId':'facardpersongroup'}";
    request.send(s);
}

server.on('request', function (req, res) {
    var uri = url.parse(req.url).pathname;
    var query = url.parse(req.url).query;
    console.log("access log:" + uri)
    if(uri == "/personalId"){
	switch (req.method) {
	case 'GET':
	    console.log("personalId:"+query.substr(query.indexOf('=')+1,query.length));
	    getFaceId(query.substr(query.indexOf('=')+1,query.length));
	    break;
	default:
	    console.log("DEFAULT");
	    break;
	}
    } else{
	res.write('NOTE');
    }
    // console.log(uri)
    
});

server.listen(80);
