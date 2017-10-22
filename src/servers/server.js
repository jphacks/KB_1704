var http = require('http');
var url = require('url');
var fs = require('fs');
var server = http.createServer();
var XMLHttpRequest = require("xmlhttprequest").XMLHttpRequest;
var IDandEmotion = new Map();
var EmotionQueue;
var emotions = ["anger", "contempt", "disgust", "fear", "happiness", "neutral", "sadness", "surprise"];

function getFaceId(srcImg,res) {
    var request = new XMLHttpRequest();
    
    request.onreadystatechange = function () {
		switch (request.readyState) {	    
		case 0:
			console.log('uninitialized!');
			break;
		case 1:
			console.log('loading...');
			break;
		case 2: 
			console.log('loaded.');
			break;
		case 3: 
			console.log('interactive... ' + request.responseText.length + ' bytes.');
			break;
		case 4: 
			if (request.status == 200 || request.status == 304) {
				console.log('COMPLETE!');
				var data = JSON.parse(request.responseText);
				sentIdentify(data[0].faceId,res);
			} else {
				console.log('Failed. HttpStatus: ' + request.responseText);
			}
			break;
		}
    };
    request.open("POST", "https://eastasia.api.cognitive.microsoft.com/face/v1.0/detect?true&false&gender");
    request.setRequestHeader("Content-Type", "application/json");
    request.setRequestHeader("Ocp-Apim-Subscription-Key", "bcfb3a73caf944a095b8a6c41be5f7b7");
    request.addEventListener("error", () => {
		console.error("Network Error");
    });
    s = "https://s3-ap-northeast-1.amazonaws.com/facard-photo/" + srcImg;
    console.log("URL of Img File is " + s);
    request.send("{'url': 'https://s3-ap-northeast-1.amazonaws.com/facard-photo/" + srcImg + "'}");
}

function getEmotion(srcImg,res) {
    var request = new XMLHttpRequest();
    request.onreadystatechange = function () {
        switch (request.readyState) {
        case 0:
            console.log('uninitialized!');
            break;
        case 1:
            console.log('loading...');
            break;
        case 2:
            console.log('loaded.');
            break;
        case 3:
            console.log('interactive... ' + request.responseText.length + ' bytes.');
            break;
        case 4:
            if (request.status == 200 || request.status == 304) {
                console.log('COMPLETE!');
                var data = JSON.parse(request.responseText);
                var emo = data[0].faceAttributes.emotion[EmotionQueue];
                console.log(data[0].faceAttributes.emotion);
                var s = "false";
                if (Number(emo) >= 0.7) {
                    console.log("SUCCESS!!!");
                    s = "true";
                }

                res.writeHead(200, {
                    'Content-Type': 'text/plain',
                    'charset': 'utf-8'
                });
                res.write(JSON.parse(s));
                res.end();
            } else {
                console.log('Failed. HttpStatus: ' + request.responseText);
            }
            break;
        }
    };
    request.open("POST", "https://eastasia.api.cognitive.microsoft.com/face/v1.0/detect?true&false&returnFaceAttributes=emotion");
    request.setRequestHeader("Content-Type", "application/json");
    request.setRequestHeader("Ocp-Apim-Subscription-Key", "bcfb3a73caf944a095b8a6c41be5f7b7");
    request.addEventListener("error", () => {
        console.error("Network Error");
    });
    s = "https://s3-ap-northeast-1.amazonaws.com/facard-photo/" + srcImg;
    console.log("URL of Img File is " + s);
    request.send("{'url': 'https://s3-ap-northeast-1.amazonaws.com/facard-photo/" + srcImg + "'}");
}

function getUserfromDB(person_id,res){
	var request = new XMLHttpRequest();

	request.onreadystatechange = function () {
		switch (request.readyState) {
		case 0:

			console.log('uninitialized!');
			break;
		case 1: 
			console.log('loading...');
			break;
		case 2: 
			console.log('loaded.');
			break;
		case 3: 
			console.log('interactive... ' + request.responseText.length + ' bytes.');
			break;
		case 4: 
			if (request.status == 200 || request.status == 304) {
				console.log('COMPLETE!');
				console.log(request.responseText);
				res.writeHead(200, {
					'Content-Type': 'application/json',
					'charset': 'utf-8'
				});
				res.write(request.responseText);
				res.end();
			} else {
				console.log('Failed. HttpStatus: ' + request.statusText);
			}
			break;
		}
    };

	request.open("GET", "https://8kw9j63717.execute-api.ap-northeast-1.amazonaws.com/test/users?faceid="+person_id);
	request.setRequestHeader("Content-Type", "application/json");
	request.send()
}

function sentIdentify(data,res) {
    console.log("FaceId of user is "+data);
    var request = new XMLHttpRequest();

    request.onreadystatechange = function () {
		switch (request.readyState) {
		case 0:

			console.log('uninitialized!');
			break;
		case 1: 
			console.log('loading...');
			break;
		case 2: 
			console.log('loaded.');
			break;
		case 3: 
			console.log('interactive... ' + request.responseText.length + ' bytes.');
			break;
		case 4: 
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
				getUserfromDB(PERSON_ID,res);
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
			getFaceId(query.substr(query.indexOf('=')+1,query.length),res);
			break;
		default:
			console.log("DEFAULT");
			break;
		}
    } else  if (uri == "/emotion") {
        switch (req.method) {
        case 'GET':
            console.log("Emotion personalId:" + query.substr(query.indexOf('=') + 1, query.length));
            getEmotion(query.substr(query.indexOf('=') + 1, query.length),res);
            break;
        case deafult:
            console.log("DEFAULT");
            break;
        }
        res.write('NOTE');
    }
    // console.log(uri)
    
});

server.listen(80);
