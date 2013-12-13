var fs = require('fs');
var Firebase = require('firebase');

// var firebase = new Firebase('https://sandmansubmissions.firebaseIO.com/edgarSubmissions');

// data = fs.readFileSync('json.txt')
// var array = data.toString().split("\n");
// for(var i in array) {
// 	if(array[i].length != 0) {
// 		es = JSON.parse(array[i]);
// 		var pushed = firebase.push();
// 		pushed.set(es)
// 		console.log(pushed.toString());
// 	}
// }

var dataRef = new Firebase("https://sandmansubmissions.firebaseio.com");
dataRef.set("I am now writing data into Firebase!");

console.log("All stored in firebase!");
process.exit();