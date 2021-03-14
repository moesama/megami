part of megami;

class _ColorHelper {
  static Color fromHex(HexColorTerm term) => term.value;

  static Color? fromExps(Expressions? exps) {
    if (exps?.expressions.isNotEmpty != true) return null;
    Color? color;
    for (var exp in exps!.expressions) {
      switch (exp.runtimeType) {
        case HexColorTerm:
          color = fromHex(exp as HexColorTerm);
          break;
      }
      if (color != null) return color;
    }
    return null;
  }

  static Color? fromExp(Expression? exp) {
    switch (exp?.runtimeType) {
      case HexColorTerm:
        return fromHex(exp as HexColorTerm);
      case Expressions:
        return fromExps(exp as Expressions);
      default:
        return null;
    }
  }
}
