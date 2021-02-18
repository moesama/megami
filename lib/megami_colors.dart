import 'package:flutter/material.dart';

import 'css/visitor.dart';

class ColorHelper {
  static Color fromHex(HexColorTerm term) => term.value;

  static Color fromExps(Expressions exps) {
    if (exps.expressions.isEmpty) return null;
    Color color;
    for (var exp in exps.expressions) {
      switch (exp.runtimeType) {
        case HexColorTerm:
          color = fromHex(exp);
          break;
      }
      if (color != null) return color;
    }
    return null;
  }

  static Color fromExp(Expression exp) {
    switch (exp.runtimeType) {
      case HexColorTerm:
        return fromHex(exp);
      case Expressions:
        return fromExps(exp);
      default:
        return null;
    }
  }
}
