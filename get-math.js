#!/usr/bin/env phantomjs

// Usage: ./get-math.js json_db file1 [file2 ...]
//  json_db: the JSON file that will contain the database
//    (existing file will be overwritten if math has changed in the source);
//  file1, file2, ...: the input files to search for LaTeX strings.

// This extracts LaTeX from given files and converts it to MathML using
// MathJax. It then builds up a database of key/value pairs mapping from 
// LaTeX to MathML. The result is a JSON object that is written to json_db. 
// LaTeX must be delimited by \( \) (inline) or \[ \] (display math).

// (c) 2014 Andres Raba, GNU GPL v.3.

var page = require("webpage").create(),
    system = require('system'),
    fs = require('fs');

var loadPage = function(url) {
  page.open(url, function (status) {
    if (status !== 'success') {
        console.log('Failed to open the url: ' + url);
        page.close(); phantom.exit();
    }
    else {
      page.onAlert = function (msg) {  // intercept alerts
        if (msg === "Listening") {
          page.evaluate(inject);  // inject an outside object into page context
          page.evaluate(function () {
            Object.keys(window.texobj).forEach(function (latex) {
              ConvertToMML(latex);
            });
            ConversionEnd();
          });
        } 
        else if (msg === "End") {
          var mathml = page.evaluate(function () {
            return window.mathml;
          });
          Object.keys(mathml).forEach(function (latex) {
            texobj[latex] = mathml[latex];
          });
          var jsonObj = JSON.stringify(texobj, function(k,v){return v;}, 2);
          fs.write(db, jsonObj, 'w');
          page.close(); phantom.exit();
        } 
        else {
          console.log("Unrecognized message: " + msg);
          page.close(); phantom.exit();
        } 
      };      
    }
  });
}

// Will hold extracted LaTeX fragments as keys:
var texobj = {};  

// LaTeX is enclosed in \( \) or \[ \] delimiters,
// first pair for inline, second for display math:
var pattern = /\\\([\s\S]+?\\\)|\\\[[\s\S]+?\\\]/g;

if (system.args.length <= 2) {
  console.log("Usage: ./get-math.js json_db file1 [file2 ...]");
  page.close(); phantom.exit();
}
else {
  var db = system.args[1];
  var args = system.args.slice(2);
  args.forEach(function (arg) {
    try {
      var file = fs.read(arg);
    }
    catch(error) {
      console.log(error);
      page.close(); phantom.exit();
    }
    var matched;
    while ((matched = pattern.exec(file)) != null) {
      texobj[matched[0]] = "";
    }
  });
  if (fs.exists(db)) {
    var oldmath = JSON.parse(fs.read(db));  // reuse the old MathML database
  }
  else {
    var oldmath = {};
  }
  var delta = {};  // collect here only Latex that has changed
  Object.keys(texobj).forEach(function (latex) {
    texobj[latex] = oldmath[latex] || (delta[latex] = "");
  });
  if (Object.keys(delta).length > 0) {  // some Latex has changed
    // A way to inject an object into the sandboxed page context, taken from:
    // http://stackoverflow.com/questions/8753169/copying-data-from-one-page-to-another-using-phantomjs
    var inject = new Function("window.texobj = " + JSON.stringify(delta));
    loadPage('mathcell.xhtml'); // conversion to MathML happens here
  }
  else {
    page.close(); phantom.exit();
  }
}
