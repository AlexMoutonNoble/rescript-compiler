'use strict';

var Block = require("../../lib/js/block.js");

function f(param) {
  return /* Format */{
          _0: /* Int */{
            tag: 4,
            _0: /* Int_d */0,
            _1: /* No_padding */0,
            _2: /* No_precision */0,
            _3: /* String */{
              tag: 2,
              _0: /* No_padding */0,
              _1: /* End_of_format */0
            }
          },
          _1: "%d%s"
        };
}

exports.f = f;
/* No side effect */
