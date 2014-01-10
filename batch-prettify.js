#!/usr/bin/env phantomjs

// Usage: ./batch-prettify.js file1 [file2 ...]
// It prettifies Scheme code in the HTML files.

// (c) 2014 Andres Raba, GNU GPL v.3.

// Heads of the files should have these scripts:
// <script class="prettifier" src="js/highlight/prettify.js" type="text/javascript"></script>
// <script class="prettifier" src="js/highlight/lang-lisp.js" type="text/javascript"></script>

// General structure of the program follows this example:
// https://github.com/ariya/phantomjs/blob/master/examples/follow.js

var system = require('system'),
    fs = require('fs');

// Put command-line arguments to an array, filter out nonexistent files.
if (system.args.length <= 1) {
  console.log("Usage: ./batch-prettify.js file1 [file2 ...]");
  phantom.exit();
} 
else {
  var files = system.args.slice(1);
  files = files.filter(function (file) {
    if (fs.exists(file)) { return true; }
    else { console.log('No such file: ' + file); return false; }
  });
}

// Open the file as webpage and run prettifier over it.
function loadpage(file, callback) {
  var page = require('webpage').create();
  page.onAlert = function (doc) {
    fs.write(file, doc, 'w');
    page.close();
    callback.apply();
  };
  page.open(file, function (status) {
    if (status !== 'success') {
      console.log('Failed to open file: ' + file);
    }
    else {
      page.evaluate(function () {
        prettyPrint(function () {
          // When prettified, remove the scripts from document,
          var scripts = document.getElementsByClassName('prettifier');
          var scripts_length = scripts.length;
          for (var i = 0; i < scripts_length; i++) {
            scripts[0].parentNode.removeChild(scripts[0]);
          };
          // and send the processed page as alert to onAlert handler.
          alert('<!DOCTYPE ' + document.doctype.name + '>\n'
            + document.childNodes[1].outerHTML);
        });
      });
    }
  });
};

// Recursively process all the files
function process() {
  if (files.length > 0) {
    var file = files.shift();
    loadpage(file, process);
  } 
  else {
    phantom.exit();
  }
}

process();
