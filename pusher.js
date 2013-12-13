var fs = require('fs');
var Firebase = require('firebase');

var firebase = new Firebase('http://edgarsubmissions.firebaseio.com/submissions');

data = fs.readFileSync('json.txt')
var array = data.toString().split("\n");
for(var i in array) {
	if(array[i].length != 0) {
		es = JSON.parse(array[i]);
		var  pushed = firebase.push(es);
		console.log(pushed.name());
		console.log(pushed.toString());
	}
}

console.log("All stored in firebase!");

// var firebase2 = new Firebase('https://thecrowdcafe.firebaseIO.com/edgarSubmissions/');
// records = firebase2.child("/edgarSubmission");
// console.log(records.val());

process.exit();