var fs = require('fs');
var Firebase = require('firebase');
var Deferred = require('JQDeferred');
var promises = [];
 
var firebase = new
Firebase('http://sandmansubmissions.firebaseio.com/submissions');
 
data = fs.readFileSync('json.txt');
var array = data.toString().split("\n");
for(var i in array) {
 if(array[i].length != 0) {
   promises.push(Deferred(function(def) {
      var row = JSON.parse(array[i]);
      var pushed = firebase.push(row, function(err) {
         console.log('finished', pushed.name());
         if( err ) {
            def.reject(err);
         }
         else {
            def.resolve(err);
         }
      });
      console.log('pushing', pushed.name());
   }));
 }
}
 
Deferred.when.apply(null, promises).done(function() {
  console.log("All stored in firebase!");
}).fail(function() {
  Array.prototype.slice.call(arguments).forEach(function(err) {
      console.error(err);
  });
}).always(process.exit.bind(process));