'use strict';

var Arg = require("../../lib/js/arg.js");
var Block = require("../../lib/js/block.js");

function anno_fun(arg) {
  
}

var usage_msg = "Usage:\n";

var compile = {
  contents: false
};

var test = {
  contents: true
};

var arg_spec_000 = /* tuple */[
  "-c",
  /* Set */{
    tag: 2,
    _0: compile
  },
  " Compile"
];

var arg_spec_001 = /* :: */{
  _0: /* tuple */[
    "-d",
    /* Clear */{
      tag: 3,
      _0: test
    },
    " Test"
  ],
  _1: /* [] */0
};

var arg_spec = /* :: */{
  _0: arg_spec_000,
  _1: arg_spec_001
};

Arg.parse(arg_spec, anno_fun, usage_msg);

exports.anno_fun = anno_fun;
exports.usage_msg = usage_msg;
exports.compile = compile;
exports.test = test;
exports.arg_spec = arg_spec;
/*  Not a pure module */
