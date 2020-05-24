'use strict';

var Mt = require("./mt.js");
var Block = require("../../lib/js/block.js");
var Js_null = require("../../lib/js/js_null.js");
var Caml_option = require("../../lib/js/caml_option.js");

var suites_000 = /* tuple */[
  "toOption - empty",
  (function (param) {
      return /* Eq */{
              tag: 0,
              _0: undefined,
              _1: undefined
            };
    })
];

var suites_001 = /* :: */{
  _0: /* tuple */[
    "toOption - 'a",
    (function (param) {
        return /* Eq */{
                tag: 0,
                _0: Caml_option.some(undefined),
                _1: Caml_option.some(undefined)
              };
      })
  ],
  _1: /* :: */{
    _0: /* tuple */[
      "return",
      (function (param) {
          return /* Eq */{
                  tag: 0,
                  _0: "something",
                  _1: Caml_option.null_to_opt("something")
                };
        })
    ],
    _1: /* :: */{
      _0: /* tuple */[
        "test - empty",
        (function (param) {
            return /* Eq */{
                    tag: 0,
                    _0: true,
                    _1: true
                  };
          })
      ],
      _1: /* :: */{
        _0: /* tuple */[
          "test - 'a",
          (function (param) {
              return /* Eq */{
                      tag: 0,
                      _0: false,
                      _1: false
                    };
            })
        ],
        _1: /* :: */{
          _0: /* tuple */[
            "bind - empty",
            (function (param) {
                return /* StrictEq */{
                        tag: 2,
                        _0: null,
                        _1: Js_null.bind(null, (function (v) {
                                return v;
                              }))
                      };
              })
          ],
          _1: /* :: */{
            _0: /* tuple */[
              "bind - 'a",
              (function (param) {
                  return /* StrictEq */{
                          tag: 2,
                          _0: 4,
                          _1: Js_null.bind(2, (function (n) {
                                  return (n << 1);
                                }))
                        };
                })
            ],
            _1: /* :: */{
              _0: /* tuple */[
                "iter - empty",
                (function (param) {
                    var hit = {
                      contents: false
                    };
                    Js_null.iter(null, (function (param) {
                            hit.contents = true;
                            
                          }));
                    return /* Eq */{
                            tag: 0,
                            _0: false,
                            _1: hit.contents
                          };
                  })
              ],
              _1: /* :: */{
                _0: /* tuple */[
                  "iter - 'a",
                  (function (param) {
                      var hit = {
                        contents: 0
                      };
                      Js_null.iter(2, (function (v) {
                              hit.contents = v;
                              
                            }));
                      return /* Eq */{
                              tag: 0,
                              _0: 2,
                              _1: hit.contents
                            };
                    })
                ],
                _1: /* :: */{
                  _0: /* tuple */[
                    "fromOption - None",
                    (function (param) {
                        return /* Eq */{
                                tag: 0,
                                _0: null,
                                _1: Js_null.fromOption(undefined)
                              };
                      })
                  ],
                  _1: /* :: */{
                    _0: /* tuple */[
                      "fromOption - Some",
                      (function (param) {
                          return /* Eq */{
                                  tag: 0,
                                  _0: 2,
                                  _1: Js_null.fromOption(2)
                                };
                        })
                    ],
                    _1: /* [] */0
                  }
                }
              }
            }
          }
        }
      }
    }
  }
};

var suites = /* :: */{
  _0: suites_000,
  _1: suites_001
};

Mt.from_pair_suites("Js_null_test", suites);

exports.suites = suites;
/*  Not a pure module */
