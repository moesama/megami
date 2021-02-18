import 'dart:math';

import 'package:megami/megami_colors.dart';

import 'css/parser.dart';
import 'css/visitor.dart';
import 'package:flutter/material.dart';

extension IterableExt on Iterable {
  T firstOrNull<T>() {
    try {
      return firstWhere((element) => element is T);
    } catch (e) {
      return null;
    }
  }
}

class Vector4<T> {
  T top;
  T right;
  T bottom;
  T left;

  Vector4({this.top, this.right, this.bottom, this.left});

  Vector4<T> all(T value) {
    top = bottom = right = left = value;
    return this;
  }

  Vector4<T> symmetric(T vertical, T horizontal) {
    top = bottom = vertical;
    right = left = horizontal;
    return this;
  }

  Vector4<T> symmetricH(T top, T horizontal, T bottom) {
    this.top = top;
    right = left = horizontal;
    this.bottom = bottom;
    return this;
  }

  Vector4<T> fill(List<T> values) {
    switch (values.length) {
      case 0:
        return this;
      case 1:
        return all(values[0]);
      case 2:
        return symmetric(values[0], values[1]);
      case 3:
        return symmetricH(values[0], values[1], values[2]);
      default:
        top = values[0];
        right = values[1];
        bottom = values[2];
        left = values[3];
        return this;
    }
  }
}

class UriHelper {
  static Uri from(UriTerm term) => Uri.parse(term.value);

  static Uri fromExp(Expression expression) {
    if (expression is UriTerm) return from(expression);
    if (expression is Expressions) {
      var uriTerm = expression.expressions.reversed.firstOrNull<UriTerm>();
      return uriTerm != null ? from(uriTerm) : null;
    }
    return null;
  }
}

class BoxFitHelper {
  static BoxFit from(LiteralTerm term) {
    switch (term.value.toString().toLowerCase().trim()) {
      case 'cover':
        return BoxFit.cover;
      case 'contain':
        return BoxFit.contain;
      case 'fill':
        return BoxFit.fill;
      case 'fit-width':
        return BoxFit.fitWidth;
      case 'fit-height':
        return BoxFit.fitHeight;
      case 'scale-down':
        return BoxFit.scaleDown;
      default:
        return null;
    }
  }

  static BoxFit fromExp(Expression expression) {
    if (expression is LiteralTerm) return from(expression);
    if (expression is Expressions) {
      for (var term in expression.expressions.reversed) {
        if (term is LiteralTerm) {
          var fit = from(term);
          if (fit != null) return fit;
        }
      }
    }
    return null;
  }
}

class ImageRepeatHelper {
  static ImageRepeat from(LiteralTerm term) {
    switch (term.value.toString().toLowerCase().trim()) {
      case 'repeat':
        return ImageRepeat.repeat;
      case 'repeat-x':
        return ImageRepeat.repeatX;
      case 'repeat-y':
        return ImageRepeat.repeatY;
      case 'no-repeat':
        return ImageRepeat.noRepeat;
      default:
        return null;
    }
  }

  static ImageRepeat fromExp(Expression expression) {
    if (expression is LiteralTerm) return from(expression);
    if (expression is Expressions) {
      for (var term in expression.expressions.reversed) {
        if (term is LiteralTerm) {
          var repeat = from(term);
          if (repeat != null) return repeat;
        }
      }
    }
    return null;
  }
}

class GradientHelper {
  static Gradient from(FunctionTerm term) {
    if (term.params.expressions.isEmpty) return null;
    GradientTransform transform;
    var endAlignment = Alignment.topCenter;
    switch (term.value) {
      case 'linear-gradient':
        var dir = term.resolvedParams.first;
        if (dir is AngleTerm) {
          transform = GradientTransformHelper.from(dir);
        } else if (dir is Expressions && dir.expressions.isNotEmpty) {
          var begin = dir.expressions.first;
          if (begin is LiteralTerm && begin.value == 'to') {
            endAlignment = AlignmentHelper.fromExp(dir);
          }
        }
        var colors =
            term.resolvedParams.sublist(1).map((e) => ColorHelper.fromExp(e));
        return LinearGradient(
          colors: colors,
          begin: Alignment(-endAlignment.x, -endAlignment.y),
          end: endAlignment,
          transform: transform,
        );
    }
  }
}

class AlignmentHelper {
  static Alignment fromExp(Expression expression) {
    var align = <double>[0, 0];
    var count = 0;
    if (expression is Expressions) {
      for (var term in expression.expressions) {
        if (count >= 2) break;
        if (term is LiteralTerm) {
          switch (term.value.toString().toLowerCase().trim()) {
            case 'center':
              if (align[0] != 0) {
                align[1] = 0;
              } else if (align[1] != 0) {
                align[0] = 0;
              }
              count++;
              break;
            case 'top':
              align[1] = -1;
              count++;
              break;
            case 'right':
              align[0] = 1;
              count++;
              break;
            case 'bottom':
              align[1] = 1;
              count++;
              break;
            case 'left':
              align[0] = -1;
              count++;
              break;
          }
        }
        if (term is NumberTerm) {
          align[count] = (term.value as num).toDouble().clamp(-1, 1);
          count++;
        }
      }
    }
    return Alignment(align[0], align[1]);
  }
}

class BlendModeHelper {
  static BlendMode from(LiteralTerm term) {
    switch (term.value.toString().toLowerCase().trim()) {
      case 'clear':
        return BlendMode.clear;
      case 'src':
        return BlendMode.src;
      case 'dst':
        return BlendMode.dst;
      case 'src-over':
        return BlendMode.srcOver;
      case 'dst-over':
        return BlendMode.dstOver;
      case 'src-in':
        return BlendMode.srcIn;
      case 'dst-in':
        return BlendMode.dstIn;
      case 'src-out':
        return BlendMode.srcOut;
      case 'dst-out':
        return BlendMode.dstOut;
      case 'src-atop':
        return BlendMode.srcATop;
      case 'dst-atop':
        return BlendMode.dstATop;
      case 'xor':
        return BlendMode.xor;
      case 'plus':
        return BlendMode.plus;
      case 'modulate':
        return BlendMode.modulate;
      case 'screen':
        return BlendMode.screen;
      case 'overlay':
        return BlendMode.overlay;
      case 'darken':
        return BlendMode.darken;
      case 'lighten':
        return BlendMode.lighten;
      case 'color-dodge':
        return BlendMode.colorDodge;
      case 'color-burn':
        return BlendMode.colorBurn;
      case 'hard-light':
        return BlendMode.hardLight;
      case 'soft-light':
        return BlendMode.softLight;
      case 'difference':
        return BlendMode.difference;
      case 'exclusion':
        return BlendMode.exclusion;
      case 'multiply':
        return BlendMode.multiply;
      case 'hue':
        return BlendMode.hue;
      case 'saturation':
        return BlendMode.saturation;
      case 'color':
        return BlendMode.color;
      case 'luminosity':
        return BlendMode.luminosity;
      default:
        return null;
    }
  }

  static BlendMode fromExp(Expression expression) {
    if (expression is Expressions) {
      for (var term in expression.expressions.reversed) {
        if (term is LiteralTerm) {
          var bm = from(term);
          if (bm != null) return bm;
        }
      }
    }
    return null;
  }
}

class GradientTransformHelper {
  static GradientTransform from(AngleTerm term) {
    var radians = term.value;
    switch (term.unit) {
      case TokenKind.UNIT_ANGLE_DEG:
        radians = degToRadian(term.value);
        break;
      case TokenKind.UNIT_ANGLE_GRAD:
        radians = gradToRadian(term.value);
        break;
      case TokenKind.UNIT_ANGLE_TURN:
        radians = turnToRadian(term.value);
        break;
    }
    return GradientRotation(radians);
  }

  static GradientTransform fromExp(Expression expression) {
    if (expression is AngleTerm) {
      return from(expression);
    }
    return null;
  }

  static double degToRadian(double degree) => degree * pi / 180;

  static double gradToRadian(double grad) => grad * pi / 200;

  static double turnToRadian(double turn) => turn * pi * 2;
}
