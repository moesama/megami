import 'dart:math';

import 'css/parser.dart';
import 'css/visitor.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

enum DimenUnit { PX, PT, SP, EM, PH, PV, VH, VW, VMIN, VMAX }

enum DimenAxis { HORIZONTAL, VERTICAL }

class Dimen {
  final num size;
  final DimenUnit unit;

  const Dimen(this.size, this.unit);

  static Dimen fromLength(LengthTerm term) {
    if (term == null) return null;
    switch (term.unit) {
      case TokenKind.UNIT_LENGTH_PX:
        return Dimen(term.value, DimenUnit.PX);
      default:
        return Dimen(term.value, DimenUnit.PT);
    }
  }

  static Dimen fromRem(RemTerm term) {
    if (term == null) return null;
    return Dimen(term.value, DimenUnit.EM);
  }

  static Dimen fromViewport(ViewportTerm term) {
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

  static Dimen fromUnit(UnitTerm term) {
    if (term == null) return null;
    switch (term.runtimeType) {
      case LengthTerm:
        return fromLength(term);
      case RemTerm:
        return fromRem(term);
      case ViewportTerm:
        return fromViewport(term);
      default:
        return null;
    }
  }

  static Dimen fromEm(EmTerm term) {
    if (term == null) return null;
    return Dimen(term.value, DimenUnit.EM);
  }

  static Dimen fromPercent(PercentageTerm term, {DimenAxis axis = DimenAxis.HORIZONTAL}) {
    if (term == null) return null;
    switch (axis) {
      case DimenAxis.HORIZONTAL:
        return Dimen(term.value, DimenUnit.PH);
      case DimenAxis.VERTICAL:
        return Dimen(term.value, DimenUnit.PV);
    }
    return null;
  }

  static Dimen fromLiteral(LiteralTerm term) {
    if (term == null) return null;
    if (term is UnitTerm) return fromUnit(term);
    if (term is PercentageTerm) return fromPercent(term);
    if (term is EmTerm) return fromEm(term);
    return null;
  }

  static bool isDimen(Expression expression) =>
      expression is UnitTerm ||
      expression is PercentageTerm ||
      expression is EmTerm;

  double dimension(BuildContext context) {
    switch (unit) {
      case DimenUnit.PT:
        return size.toDouble();
      case DimenUnit.PX:
        return size / Dimens.pixelRatio;
      case DimenUnit.SP:
        return size * Dimens.textScaleFactor;
      case DimenUnit.EM:
        return size * Theme.of(context).textTheme.bodyText1.fontSize * Dimens.textScaleFactor;
      case DimenUnit.PH:
        try {
          return size * (context.findRenderObject()?.paintBounds?.width ?? 0);
        } catch (e) {}
        return 0;
      case DimenUnit.PV:
        try {
          return size * (context.findRenderObject()?.paintBounds?.height ?? 0);
        } catch (e) {}
        return 0;
      case DimenUnit.VH:
        return size * Dimens.screenHeight;
      case DimenUnit.VW:
        return size * Dimens.screenWidth;
      case DimenUnit.VMIN:
        return size * min(Dimens.screenWidth, Dimens.screenHeight);
      case DimenUnit.VMAX:
        return size * max(Dimens.screenWidth, Dimens.screenHeight);
      default:
        return size.toDouble();
    }
  }
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
