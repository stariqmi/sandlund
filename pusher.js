var fs = require('fs');
var Firebase = require('firebase');

var myDataRef = new Firebase('https://sandmansubmissions.firebaseio.com/submissions');

data = fs.readFileSync('json.txt')
var array = data.toString().split("\n");
for(var i in array) {
	if(array[i].length != 0) {
		es = JSON.parse(array[i]);
		var pushed = myDataRef.push(es, function(err) {
			if(err) {
				console.log(err);
			}
			else {
				console.log("Data saved successfully!");
			}
		});
	}
}

console.log("All stored in firebase!");
