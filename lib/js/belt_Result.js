'use strict';

var Block = require("./block.js");
var Curry = require("./curry.js");

function getExn(x) {
  if (!x.tag) {
    return x._0;
  }
  throw new Error("getExn");
}

function mapWithDefaultU(opt, $$default, f) {
  if (opt.tag) {
    return $$default;
  } else {
    return f(opt._0);
  }
}

function mapWithDefault(opt, $$default, f) {
  return mapWithDefaultU(opt, $$default, Curry.__1(f));
}

function mapU(opt, f) {
  if (opt.tag) {
    return /* Error */{
            tag: 1,
            _0: opt._0
          };
  } else {
    return /* Ok */{
            tag: 0,
            _0: f(opt._0)
          };
  }
}

function map(opt, f) {
  return mapU(opt, Curry.__1(f));
}

function flatMapU(opt, f) {
  if (opt.tag) {
    return /* Error */{
            tag: 1,
            _0: opt._0
          };
  } else {
    return f(opt._0);
  }
}

function flatMap(opt, f) {
  return flatMapU(opt, Curry.__1(f));
}

function getWithDefault(opt, $$default) {
  if (opt.tag) {
    return $$default;
  } else {
    return opt._0;
  }
}

function isOk(param) {
  if (param.tag) {
    return false;
  } else {
    return true;
  }
}

function isError(param) {
  if (param.tag) {
    return true;
  } else {
    return false;
  }
}

function eqU(a, b, f) {
  if (a.tag) {
    if (b.tag) {
      return true;
    } else {
      return false;
    }
  } else if (b.tag) {
    return false;
  } else {
    return f(a._0, b._0);
  }
}

function eq(a, b, f) {
  return eqU(a, b, Curry.__2(f));
}

function cmpU(a, b, f) {
  if (a.tag) {
    if (b.tag) {
      return 0;
    } else {
      return -1;
    }
  } else if (b.tag) {
    return 1;
  } else {
    return f(a._0, b._0);
  }
}

function cmp(a, b, f) {
  return cmpU(a, b, Curry.__2(f));
}

exports.getExn = getExn;
exports.mapWithDefaultU = mapWithDefaultU;
exports.mapWithDefault = mapWithDefault;
exports.mapU = mapU;
exports.map = map;
exports.flatMapU = flatMapU;
exports.flatMap = flatMap;
exports.getWithDefault = getWithDefault;
exports.isOk = isOk;
exports.isError = isError;
exports.eqU = eqU;
exports.eq = eq;
exports.cmpU = cmpU;
exports.cmp = cmp;
/* No side effect */
