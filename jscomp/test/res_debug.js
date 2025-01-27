'use strict';

var Curry = require("../../lib/js/curry.js");
var Caml_obj = require("../../lib/js/caml_obj.js");
var Caml_option = require("../../lib/js/caml_option.js");

function f($$window, a, b) {
  return $$window.location(a, b);
}

var v0 = {
  x: 3,
  z: 2
};

var newrecord = Caml_obj.obj_dup(v0);

newrecord.x = 3;

function testMatch(v) {
  var y = v.y;
  if (y !== undefined) {
    return y;
  } else {
    return 42;
  }
}

function optionMap(x, f) {
  if (x !== undefined) {
    return Caml_option.some(Curry._1(f, Caml_option.valFromOption(x)));
  }
  
}

var ok_name = optionMap(undefined, (function (x) {
        return x;
      }));

var ok = {
  name: ok_name
};

var bad_name = optionMap(undefined, (function (x) {
        return x;
      }));

var bad = {
  name: bad_name
};

function identity(x) {
  return x;
}

var name1 = "ReScript";

var ok1 = {
  name: name1
};

var bad1 = {
  name: name1
};

var v2 = newrecord;

var v1 = {
  x: 3,
  z: 3
};

var h = /* '\522' */128522;

var hey = "hello, 世界";

var name;

exports.f = f;
exports.v0 = v0;
exports.v2 = v2;
exports.v1 = v1;
exports.testMatch = testMatch;
exports.h = h;
exports.hey = hey;
exports.optionMap = optionMap;
exports.name = name;
exports.ok = ok;
exports.bad = bad;
exports.identity = identity;
exports.name1 = name1;
exports.ok1 = ok1;
exports.bad1 = bad1;
/*  Not a pure module */
