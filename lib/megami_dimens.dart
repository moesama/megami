part of megami;

enum DimenUnit { PX, PT, SP, EM, REM, PH, PV, VH, VW, VMIN, VMAX }

enum DimenAxis { HORIZONTAL, VERTICAL }

class Dimen {
  final num size;
  final DimenUnit unit;

  const Dimen(this.size, this.unit);

  const Dimen.zero()
      : size = 0,
        unit = DimenUnit.PT;

  static Dimen? fromLength(LengthTerm? term) {
    if (term == null) return null;
    switch (term.unit) {
      case TokenKind.UNIT_LENGTH_PX:
        return Dimen(term.value, DimenUnit.PX);
      default:
        return Dimen(term.value, DimenUnit.PT);
    }
  }

  static Dimen? fromRem(RemTerm? term) {
    if (term == null) return null;
    return Dimen(term.value, DimenUnit.REM);
  }

  static Dimen? fromViewport(ViewportTerm? term) {
    if (term == null) return null;
    switch (term.unit) {
      case TokenKind.UNIT_VIEWPORT_VH:
        return Dimen(term.value, DimenUnit.VH);
      case TokenKind.UNIT_VIEWPORT_VW:
        return Dimen(term.value, DimenUnit.VW);
      case TokenKind.UNIT_VIEWPORT_VMIN:
        return Dimen(term.value, DimenUnit.VMIN);
      case TokenKind.UNIT_VIEWPORT_VMAX:
        return Dimen(term.value, DimenUnit.VMAX);
      default:
        return Dimen(term.value, DimenUnit.VW);
    }
  }

  static Dimen? fromUnit(UnitTerm? term) {
    if (term == null) return null;
    switch (term.runtimeType) {
      case LengthTerm:
        return fromLength(term as LengthTerm);
      case RemTerm:
        return fromRem(term as RemTerm);
      case ViewportTerm:
        return fromViewport(term as ViewportTerm);
      default:
        return null;
    }
  }

  static Dimen? fromEm(EmTerm? term) {
    if (term == null) return null;
    return Dimen(term.value, DimenUnit.EM);
  }

  static Dimen? fromPercent(PercentageTerm? term,
      {DimenAxis axis = DimenAxis.HORIZONTAL}) {
    if (term == null) return null;
    switch (axis) {
      case DimenAxis.HORIZONTAL:
        return Dimen(term.value, DimenUnit.PH);
      case DimenAxis.VERTICAL:
        return Dimen(term.value, DimenUnit.PV);
    }
  }

  static Dimen? fromLiteral(LiteralTerm? term) {
    if (term == null) return null;
    if (term is UnitTerm) return fromUnit(term);
    if (term is PercentageTerm) return fromPercent(term);
    if (term is EmTerm) return fromEm(term);
    return null;
  }

  static Dimen fromNum(NumberTerm term) {
    return Dimen(term.value.toDouble(), DimenUnit.PT);
  }

  static bool isDimen(Expression expression) =>
      expression is UnitTerm ||
      expression is PercentageTerm ||
      expression is EmTerm;

  double dimension(BuildContext context, {double? fontSize = 0.0}) {
    switch (unit) {
      case DimenUnit.PT:
        return size.toDouble();
      case DimenUnit.PX:
        return size / Dimens.pixelRatio;
      case DimenUnit.SP:
        return size * Dimens.textScaleFactor;
      case DimenUnit.EM:
        var fs = fontSize ?? 0;
        if (fs == 0) fs = Theme.of(context).textTheme.bodyText1?.fontSize ?? 0;
        return size * fs * Dimens.textScaleFactor;
      case DimenUnit.REM:
        var fs = Theme.of(context).textTheme.bodyText1?.fontSize ?? 0;
        return size * fs * Dimens.textScaleFactor;
      case DimenUnit.PH:
        try {
          return size * (context.findRenderObject()?.paintBounds.width ?? 0);
        } catch (e) {
          return 0;
        }
      case DimenUnit.PV:
        try {
          return size * (context.findRenderObject()?.paintBounds.height ?? 0);
        } catch (e) {
          return 0;
        }
      case DimenUnit.VH:
        return size / 100 * Dimens.screenHeight;
      case DimenUnit.VW:
        return size / 100 * Dimens.screenWidth;
      case DimenUnit.VMIN:
        return size / 100 * min(Dimens.screenWidth, Dimens.screenHeight);
      case DimenUnit.VMAX:
        return size / 100 * max(Dimens.screenWidth, Dimens.screenHeight);
      default:
        return size.toDouble();
    }
  }

  Dimen operator *(num scale) => Dimen(size * scale, unit);
}

class Dimens {
  static double get screenWidth {
    var mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.size.width;
  }

  static double get screenHeight {
    var mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.size.height;
  }

  static double get pixelRatio {
    var mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.devicePixelRatio;
  }

  static double get designRatio {
    var mediaQuery = MediaQueryData.fromWindow(ui.window);
    print(mediaQuery.size);
    return min(mediaQuery.size.width, mediaQuery.size.height) / 360;
  }

  static double get textScaleFactor {
    var mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.textScaleFactor;
  }

  static double get navigationBarHeight {
    var mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.top + kToolbarHeight;
  }

  static double get topSafeHeight {
    var mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.top;
  }

  static double get bottomSafeHeight {
    var mediaQuery = MediaQueryData.fromWindow(ui.window);
    return mediaQuery.padding.bottom;
  }
}
