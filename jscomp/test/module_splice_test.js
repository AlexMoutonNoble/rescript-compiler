'use strict';

var Mt = require("./mt.js");
var Block = require("../../lib/js/block.js");
var JoinClasses = require("./joinClasses");
var Caml_splice_call = require("../../lib/js/caml_splice_call.js");

var suites = [/* contents : [] */0];

var test_id = [/* contents */0];

function eq(loc, param) {
  var y = param[1];
  var x = param[0];
  test_id[/* contents */0] = test_id[/* contents */0] + 1 | 0;
  suites[/* contents */0] = /* :: */[
    /* tuple */[
      loc + (" id " + String(test_id[/* contents */0])),
      (function (param) {
          return /* Eq */Block.__(0, [
                    x,
                    y
                  ]);
        })
    ],
    suites[/* contents */0]
  ];
  return /* () */0;
}

function joinClasses(prim) {
  return Caml_splice_call.spliceApply(JoinClasses, [prim]);
}

var a = JoinClasses(1, 2, 3);

var pair = /* tuple */[
  a,
  6
];

console.log(pair);

eq("File \"module_splice_test.ml\", line 21, characters 5-12", pair);

Mt.from_pair_suites("Module_splice_test", suites[/* contents */0]);

exports.suites = suites;
exports.test_id = test_id;
exports.eq = eq;
exports.joinClasses = joinClasses;
exports.a = a;
/* a Not a pure module */
