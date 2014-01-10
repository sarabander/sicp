#!/usr/bin/env phantomjs

// Usage: ./put-math.js json_db file1 [file2 ...]
//  json_db: existing JSON file that contains the MathML database;
//  file1, file2, ...: the output files to modify.

// This replaces all the LaTeX markup in given output files with MathML. 
// It does it by searching for LaTeX strings delimited by \( \) or \[ \] 
// and looks up the mapping from LaTeX to MathML in the JSON database.

// (c) 2014 Andres Raba, GNU GPL v.3.

var system = require('system'),
    fs = require('fs');

// LaTeX is enclosed in \( \) or \[ \] delimiters,
// first pair for inline, second for display math:
var pattern = /\\\([\s\S]+?\\\)|\\\[[\s\S]+?\\\]/g;

if (system.args.length <= 2) {
  console.log("Usage: ./put-math.js json_db file1 [file2 ...]");
  phantom.exit();
} 
else {
  var db = system.args[1];          // JSON database
  var args = system.args.slice(2);  // file1, file2, ...
  try {
    var mathml = JSON.parse(fs.read(db));
  } 
  catch(error) {
    console.log(error);
    phantom.exit();
  }
  args.forEach(function (arg) {
    try {
      var file = fs.read(arg);
      // Replace LaTeX with MathML or paint LaTeX blue
      // if mapping not found in JSON database:
      var file = file.replace(pattern, function (latex) {
        return mathml[latex] || "<span style='color:blue'>" + latex + "</span>";
      });
      fs.write(arg, file, 'w');
    }
    catch(error) {
      console.log(error);
    }
  });
  phantom.exit();
}
