'use strict';

var Curry = require("../../lib/js/curry.js");

var v = /* record */[/* contents */0];

function gen(param) {
  v[/* contents */0] = v[/* contents */0] + 1 | 0;
  return v[/* contents */0];
}

var h = /* record */[/* contents */0];

var a = 0;

var c = /* record */[/* contents */0];

var not_real_escape = a;

function real_escape(f, v) {
  return Curry._1(f, c);
}

var u = h;

exports.u = u;
exports.gen = gen;
exports.not_real_escape = not_real_escape;
exports.real_escape = real_escape;
/* No side effect */
