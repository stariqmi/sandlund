var page = require('webpage').create();
 
page.open('test.html', function (s) {
    console.log(s);
    phantom.exit();
});