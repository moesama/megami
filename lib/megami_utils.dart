part of megami;

double _degToRadian(double degree) => degree * pi / 180;

double _gradToRadian(double grad) => grad * pi / 200;

double _turnToRadian(double turn) => turn * pi * 2;

class _Vector4<T> {
  T? top;
  T? right;
  T? bottom;
  T? left;

  _Vector4({this.top, this.right, this.bottom, this.left});

  _Vector4<T> all(T value) {
    top = bottom = right = left = value;
    return this;
  }

  _Vector4<T> symmetric(T vertical, T horizontal) {
    top = bottom = vertical;
    right = left = horizontal;
    return this;
  }

  _Vector4<T> symmetricH(T top, T horizontal, T bottom) {
    this.top = top;
    right = left = horizontal;
    this.bottom = bottom;
    return this;
  }

  _Vector4<T> fill(List<T>? values) {
    if (values == null) return this;
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

class _UriHelper {
  static Uri? from(UriTerm term) => Uri.tryParse(term.value);

  static Uri? fromExp(Expression? expression) {
    if (expression is UriTerm) return from(expression);
    if (expression is Expressions) {
      var uriTerm =
          expression.expressions.reversed.whereType<UriTerm>().firstOrNull;
      return uriTerm != null ? from(uriTerm) : null;
    }
    return null;
  }
}

class _BoxFitHelper {
  static BoxFit? from(LiteralTerm term) {
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

  static BoxFit? fromExp(Expression? expression) {
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

class _ImageRepeatHelper {
  static ImageRepeat? from(LiteralTerm term) {
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

  static ImageRepeat? fromExp(Expression? expression) {
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

class _GradientHelper {
  static Gradient? from(FunctionTerm term) {
    if (term.params.expressions.isEmpty) return null;
    GradientTransform? transform;
    var colorStart = 1;
    switch (term.value) {
      case 'linear-gradient':
        var endAlignment = Alignment.topCenter;
        var dir = term.resolvedParams.first;
        if (dir is AngleTerm) {
          transform = _GradientTransformHelper.from(dir);
        } else if (dir is Expressions && dir.expressions.isNotEmpty) {
          var begin = dir.expressions.firstOrNull;
          if (begin != null &&
              begin is LiteralTerm &&
              begin.value.toString() == 'to') {
            endAlignment = _AlignmentHelper.fromExp(dir);
          }
        } else {
          colorStart = 0;
        }
        var colors = term.resolvedParams
            .sublist(colorStart)
            .map((e) => _ColorHelper.fromExp(e))
            .whereNotNull()
            .toList();
        var stops = _GradientStopHelper.fromExps(
            term.resolvedParams.sublist(colorStart));
        return LinearGradient(
          colors: colors,
          stops: stops,
          begin: Alignment(-endAlignment.x, -endAlignment.y),
          end: endAlignment,
          transform: transform,
        );
      case 'radial-gradient':
        var props = term.resolvedParams.first;
        var center = Alignment.center;
        var radius = 1.0;
        if (props is LiteralTerm ||
            (props is Expressions && props.expressions.isNotEmpty)) {
          center = _AlignmentHelper.fromExp(props);
          radius = _GradientRadiusHelper.fromExp(props, center);
        }
        if (props is HexColorTerm) {
          colorStart = 0;
        }
        var colors = term.resolvedParams
            .sublist(colorStart)
            .map((e) => _ColorHelper.fromExp(e))
            .whereNotNull()
            .toList();
        var stops = _GradientStopHelper.fromExps(
            term.resolvedParams.sublist(colorStart));
        return RadialGradient(
          center: center,
          radius: radius,
          colors: colors,
          stops: stops,
        );
      default:
        return null;
    }
  }

  static Gradient? fromExp(Expression? expression) {
    if (expression is FunctionTerm) return from(expression);
    if (expression is Expressions) {
      for (var term in expression.expressions.reversed) {
        if (term is FunctionTerm) {
          var gradient = from(term);
          if (gradient != null) return gradient;
        }
      }
    }
    return null;
  }
}

class _AlignmentHelper {
  static Alignment fromExp(Expression? expression) {
    var align = <double>[0, 0];
    var count = 0;
    if (expression is Expressions) {
      for (var term in expression.expressions) {
        if (count >= 2) break;
        if (term is LiteralTerm) {
          switch (term.value.toString().toLowerCase().trim()) {
            case 'center':
            case 'middle':
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
        if (term is PercentageTerm) {
          align[count] = ((term.value as num).toDouble() / 100.0).clamp(-1, 1);
          count++;
        }
        if (term is NumberTerm) {
          align[count] = (term.value as num).toDouble().clamp(-1, 1);
          count++;
        }
      }
    } else if (expression is LiteralTerm) {
      switch (expression.value.toString().toLowerCase().trim()) {
        case 'center':
        case 'middle':
          align[0] = align[1] = 0;
          break;
        case 'top':
          align[1] = -1;
          break;
        case 'right':
          align[0] = 1;
          break;
        case 'bottom':
          align[1] = 1;
          break;
        case 'left':
          align[0] = -1;
          break;
      }
    }
    return Alignment(align[0], align[1]);
  }

  static TextAlign? taFromExp(Expression? expression) {
    var term = expression;
    if (expression is Expressions && expression.expressions.isNotEmpty) {
      term = expression.expressions.first;
    }
    if (term is LiteralTerm) {
      switch (term.value.toString().toLowerCase().trim()) {
        case 'center':
          return TextAlign.center;
        case 'left':
          return TextAlign.left;
        case 'right':
          return TextAlign.right;
        case 'justify':
          return TextAlign.justify;
        case 'start':
          return TextAlign.start;
        case 'end':
          return TextAlign.end;
      }
    }
    return null;
  }
}

class _BlendModeHelper {
  static BlendMode? from(LiteralTerm term) {
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

  static BlendMode? fromExp(Expression? expression) {
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

class _AngleHelper {
  static double radiansFrom(AngleTerm term) {
    var radians = term.value as num;
    switch (term.unit) {
      case TokenKind.UNIT_ANGLE_DEG:
        radians = _degToRadian(radians.toDouble());
        break;
      case TokenKind.UNIT_ANGLE_GRAD:
        radians = _gradToRadian(radians.toDouble());
        break;
      case TokenKind.UNIT_ANGLE_TURN:
        radians = _turnToRadian(radians.toDouble());
        break;
    }
    return radians.toDouble();
  }
}

class _GradientTransformHelper {
  static GradientTransform from(AngleTerm term) {
    var radians = _AngleHelper.radiansFrom(term);
    return GradientRotation(radians);
  }

  static GradientTransform? fromExp(Expression expression) {
    if (expression is AngleTerm) {
      return from(expression);
    }
    return null;
  }
}

class _GradientStopHelper {
  static List<double> fromExps(List<Expression> expressions) {
    var stopMap = <int, double>{};
    for (var i = 0; i < expressions.length; i++) {
      if (!(expressions[i] is Expressions)) {
        continue;
      }
      var exps = expressions[i] as Expressions;
      var per = exps.expressions.whereType<PercentageTerm>().firstOrNull;
      if (per != null) {
        stopMap[i] = per.value / 100.0;
      }
    }
    return resolveStops(stopMap, expressions.length);
  }

  static List<double> resolveStops(Map<int, double> source, int size) {
    var result = <double>[];
    source.forEach((key, value) {
      if (result.isEmpty && key > 0) {
        result.addAll(List.filled(key, 0.0));
      }
      var deltaKey = key - result.length + 1;
      var deltaValue = value - result.last;
      if (deltaKey > 0 && deltaValue > 0) {
        var step = deltaValue / deltaKey;
        for (var i = 0; i < deltaKey; i++) {
          result.add(result.last + step);
        }
      }
    });
    if (result.isEmpty && size > 0) {
      result.add(0.0);
    }
    if (result.length < size) {
      var deltaKey = size - result.length;
      var deltaValue = 1.0 - result.last;
      if (deltaKey > 0 && deltaValue > 0) {
        var step = deltaValue / deltaKey;
        for (var i = 0; i < deltaKey; i++) {
          result.add(result.last + step);
        }
      }
    }
    return result;
  }
}

class _GradientRadiusHelper {
  static const FARTHEST_CORNER =
      'farthest-corner'; //(默认) : 指定径向渐变的半径长度为从圆心到离圆心最远的角
  static const CLOSEST_SIDE = 'closest-side'; //：指定径向渐变的半径长度为从圆心到离圆心最近的边
  static const CLOSEST_CORNER = 'closest-corner'; //： 指定径向渐变的半径长度为从圆心到离圆心最近的角
  static const FARTHEST_SIDE = 'farthest-side'; //：指定径向渐变的半径长度为从圆心到离圆心最远的边

  static double fromExp(Expression expression, Alignment center) {
    var type = FARTHEST_CORNER;
    if (expression is LiteralTerm) {
      type = expression.value.toString();
    } else if (expression is Expressions && expression.expressions.isNotEmpty) {
      var exp = expression.expressions.first;
      if (exp is LiteralTerm) {
        type = exp.value.toString();
      }
    }
    switch (type) {
      case CLOSEST_SIDE:
        return 1.0;
      case CLOSEST_CORNER:
        return pow(pow(1 - center.x.abs(), 2) + pow(1 - center.y.abs(), 2), 0.5)
            .toDouble();
      case FARTHEST_SIDE:
        return 2.0 - min(center.x.abs(), center.y.abs());
      default:
        return pow(pow(1 + center.x.abs(), 2) + pow(1 + center.y.abs(), 2), 0.5)
            .toDouble();
    }
  }
}

class _DurationHelper {
  static Duration? fromExp(Expression? expression) {
    if (expression != null && expression is TimeTerm) {
      switch (expression.unit) {
        case TokenKind.UNIT_TIME_MS:
          return Duration(milliseconds: expression.asInt);
        case TokenKind.UNIT_TIME_S:
          return Duration(
              seconds: expression.asInt,
              milliseconds:
                  ((expression.asDouble - expression.asInt) * 1000).floor());
      }
    }
    return null;
  }
}

class _CurveHelper {
  static Curve? fromExp(Expression? expression) {
    if (expression == null) return null;
    if (expression is LiteralTerm) {
      switch (expression.text.trim()) {
        case 'linear':
          return Curves.linear;
        case 'ease':
          return Curves.ease;
        case 'ease-in':
          return Curves.easeIn;
        case 'ease-out':
          return Curves.easeOut;
        case 'ease-in-out':
          return Curves.easeInOut;
      }
    } else if (expression is FunctionTerm &&
        expression.value == 'cubic-bezier') {
      final params = expression.resolvedParams
          .whereType<NumberTerm>()
          .map((e) => e.asDouble)
          .toList();
      if (params.length == 4) {
        return Cubic(params[0], params[1], params[2], params[3]);
      }
    }
    return null;
  }
}

class InnerShadow extends SingleChildRenderObjectWidget {
  final List<BoxShadow> boxShadow;

  const InnerShadow({
    Key? key,
    this.boxShadow = const <BoxShadow>[],
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = _RenderInnerShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderInnerShadow renderObject) {
    renderObject.boxShadow = boxShadow;
  }
}

class _RenderInnerShadow extends RenderProxyBox {
  late List<BoxShadow> boxShadow;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (child == null || child!.paintBounds.isEmpty) return;
    final bounds = offset & size;

    context.canvas.saveLayer(bounds, Paint());
    child!.paint(context, offset);

    for (final shadow in boxShadow) {
      final shadowRect = bounds.inflate(shadow.blurSigma);
      final shadowPaint = Paint()
        ..blendMode = BlendMode.srcATop
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcOut)
        ..imageFilter = ui.ImageFilter.blur(
            sigmaX: shadow.blurSigma, sigmaY: shadow.blurSigma);
      final scaleX = (child!.paintBounds.width - shadow.spreadRadius * 2) /
          child!.paintBounds.width;
      final scaleY = (child!.paintBounds.height - shadow.spreadRadius * 2) /
          child!.paintBounds.height;
      context.canvas
        ..saveLayer(shadowRect, shadowPaint)
        ..translate(offset.dx + shadow.offset.dx + shadow.spreadRadius,
            offset.dy + shadow.offset.dy + shadow.spreadRadius)
        ..scale(scaleX, scaleY);
      child!.paint(context, Offset.zero);
      context.canvas.restore();
    }

    context.canvas.restore();
  }
}

class DropShadow extends SingleChildRenderObjectWidget {
  final List<BoxShadow> boxShadow;

  const DropShadow({
    Key? key,
    this.boxShadow = const <BoxShadow>[],
    Widget? child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = _RenderDropShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderDropShadow renderObject) {
    renderObject.boxShadow = boxShadow;
  }
}

class _RenderDropShadow extends RenderProxyBox {
  late List<BoxShadow> boxShadow;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || child!.paintBounds.isEmpty) {
      super.paint(context, offset);
      return;
    }
    final bounds = offset & size;

    for (final shadow in boxShadow) {
      final shadowRect = bounds.inflate(shadow.blurSigma + shadow.spreadRadius);
      final shadowPaint = Paint()
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcIn)
        ..imageFilter = ui.ImageFilter.blur(
          sigmaX: shadow.blurSigma,
          sigmaY: shadow.blurSigma,
        );
      final scaleX = (child!.paintBounds.width + shadow.spreadRadius * 2) /
          child!.paintBounds.width;
      final scaleY = (child!.paintBounds.height + shadow.spreadRadius * 2) /
          child!.paintBounds.height;
      context.canvas
        ..saveLayer(shadowRect, shadowPaint)
        ..translate(offset.dx + shadow.offset.dx - shadow.spreadRadius,
            offset.dy + shadow.offset.dy - shadow.spreadRadius)
        ..scale(scaleX, scaleY);
      child!.paint(context, Offset.zero);
      context.canvas.restore();
    }
    super.paint(context, offset);
  }
}

class _BoxShadowTween extends Tween<List<BoxShadow>> {
  _BoxShadowTween({List<BoxShadow>? begin, List<BoxShadow>? end})
      : super(begin: begin, end: end);

  @override
  List<BoxShadow> lerp(double t) => BoxShadow.lerpList(begin, end, t)!;
}

class ColorMatrix {
  static final lumR = 0.213;
  static final lumG = 0.715;
  static final lumB = 0.072;

  ColorMatrix({List<double>? src}) : _list = src ?? List.filled(20, 0.0);

  final List<double> _list;

  List<double> get data => _list.toList(growable: false);

  ColorFilter get filter => ColorFilter.matrix(data);

  double get(int row, int column) => _list[row * 5 + column];

  ColorMatrix set(int row, int column, double value) {
    _list[row * 5 + column] = value;
    return this;
  }

  /// Set this colormatrix to identity:
  /// <pre>
  /// [ 1 0 0 0 0   - red vector
  /// 0 1 0 0 0   - green vector
  /// 0 0 1 0 0   - blue vector
  /// 0 0 0 1 0 ] - alpha vector
  /// </pre>
  void reset() {
    clear();
    set(0, 0, 1).set(1, 1, 1).set(2, 2, 1).set(3, 3, 1);
  }

  void clear() {
    _list.fillRange(0, _list.length, 0);
  }

  /// Assign the array of doubles into this matrix, copying all of its values.
  void setMatrix(List<double> src) {
    _list.setAll(0, src);
  }

  /// Set this colormatrix to scale by the specified values.
  ColorMatrix _setScale(
      double rScale, double gScale, double bScale, double aScale) {
    clear();
    set(0, 0, rScale).set(1, 1, gScale).set(2, 2, bScale).set(3, 3, aScale);
    return this;
  }

  /// Set the rotation on a color axis by the specified values.
  /// <p>
  /// <code>axis=0</code> correspond to a rotation around the RED color
  /// <code>axis=1</code> correspond to a rotation around the GREEN color
  /// <code>axis=2</code> correspond to a rotation around the BLUE color
  /// </p>
  ColorMatrix _setRotate(int axis, double degrees) {
    reset();
    final radians = degrees * pi / 180;
    final cosine = cos(radians);
    final sine = sin(radians);
    switch (axis) {
      // Rotation around the red color
      case 0:
        _list[6] = _list[12] = cosine;
        _list[7] = sine;
        _list[11] = -sine;
        break;
      // Rotation around the green color
      case 1:
        _list[0] = _list[12] = cosine;
        _list[2] = -sine;
        _list[10] = sine;
        break;
      // Rotation around the blue color
      case 2:
        _list[0] = _list[6] = cosine;
        _list[1] = sine;
        _list[5] = -sine;
        break;
      default:
        throw StateError('');
    }
    return this;
  }

  /// Set this colormatrix to the concatenation of the two specified
  /// colormatrices, such that the resulting colormatrix has the same effect
  /// as applying matB and then applying matA.
  /// <p>
  /// It is legal for either matA or matB to be the same colormatrix as this.
  /// </p>
  ColorMatrix setConcat(ColorMatrix matA, ColorMatrix matB) {
    List<double> tmp;
    if (matA == this || matB == this) {
      tmp = List.filled(20, 0.0);
    } else {
      tmp = _list;
    }

    final a = matA._list;
    final b = matB._list;
    var index = 0;
    for (var j = 0; j < 20; j += 5) {
      for (var i = 0; i < 4; i++) {
        tmp[index++] = a[j + 0] * b[i + 0] +
            a[j + 1] * b[i + 5] +
            a[j + 2] * b[i + 10] +
            a[j + 3] * b[i + 15];
      }
      tmp[index++] = a[j + 0] * b[4] +
          a[j + 1] * b[9] +
          a[j + 2] * b[14] +
          a[j + 3] * b[19] +
          a[j + 4];
    }

    if (tmp != _list) {
      setMatrix(tmp);
    }
    return this;
  }

  /// Concat this colormatrix with the specified prematrix.
  /// <p>
  /// This is logically the same as calling setConcat(this, prematrix);
  /// </p>
  ColorMatrix preConcat(ColorMatrix preMatrix) {
    return setConcat(this, preMatrix);
  }

  /// Concat this colormatrix with the specified postmatrix.
  /// <p>
  /// This is logically the same as calling setConcat(postmatrix, this);
  /// </p>
  ColorMatrix postConcat(ColorMatrix postMatrix) {
    return setConcat(postMatrix, this);
  }

  ///////////////////////////////////////////////////////////////////////////
  static ColorMatrix brightness(double bright) {
    final matrix = ColorMatrix();
    matrix.reset();
    final br = (bright - 1).clamp(-1, 1) * 255;
    return matrix.set(0, 4, br.toDouble()).set(1, 4, br.toDouble()).set(2, 4, br.toDouble());
  }

  static ColorMatrix saturation(double sat) {
    final matrix = ColorMatrix();
    matrix.reset();

    final invSat = 1 - sat;
    final R = lumR * invSat;
    final G = lumG * invSat;
    final B = lumB * invSat;

    matrix._list[0] = R + sat;
    matrix._list[1] = G;
    matrix._list[2] = B;
    matrix._list[5] = R;
    matrix._list[6] = G + sat;
    matrix._list[7] = B;
    matrix._list[10] = R;
    matrix._list[11] = G;
    matrix._list[12] = B + sat;
    return matrix;
  }

  static ColorMatrix contrast(double contrast) {
    final matrix = ColorMatrix();
    final br = ((1 - contrast) * 255 / 2).clamp(-255, 255);
    matrix._setScale(contrast, contrast, contrast, 1.0);
    return matrix.set(0, 4, br.toDouble()).set(1, 4, br.toDouble()).set(2, 4, br.toDouble());
  }

  static ColorMatrix grayscale(double scale) =>
      saturation((1 - scale).clamp(0, 1));

  static ColorMatrix hueRotate(double radians) {
    final cosine = cos(radians);
    final sine = sin(radians);
    final matrix = ColorMatrix(src: <double>[
      lumR + cosine * (1 - lumR) + sine * (-lumR),
      lumG + cosine * (-lumG) + sine * (-lumG),
      lumB + cosine * (-lumB) + sine * (1 - lumB),
      0,
      0,
      lumR + cosine * (-lumR) + sine * (0.143),
      lumG + cosine * (1 - lumG) + sine * (0.140),
      lumB + cosine * (-lumB) + sine * (-0.283),
      0,
      0,
      lumR + cosine * (-lumR) + sine * (lumR - 1),
      lumG + cosine * (-lumG) + sine * (lumG),
      lumB + cosine * (1 - lumB) + sine * (lumB),
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ]);
    return matrix;
  }

  static ColorMatrix invert(double factor) {
    final matrix = ColorMatrix();
    matrix.reset();
    final iv = 1 - factor * 2;
    final br = (255 * factor).clamp(-255, 255);
    return matrix
        .set(0, 0, iv)
        .set(1, 1, iv)
        .set(2, 2, iv)
        .set(0, 4, br.toDouble())
        .set(1, 4, br.toDouble())
        .set(2, 4, br.toDouble());
  }

  static ColorMatrix sepia(double factor) {
    final matrix = ColorMatrix(src: <double>[
      0.393,
      0.769,
      0.189,
      0,
      0,
      0.349,
      0.686,
      0.168,
      0,
      0,
      0.272,
      0.534,
      0.131,
      0,
      0,
      0,
      0,
      0,
      1,
      0
    ]);
    return matrix._factor(factor);
  }

  ColorMatrix _factor(double factor) {
    if (factor == 0) {
      reset();
      return this;
    }
    // r
    _list[0] += _list[0].sign * (1 - _list[0].abs()) * (1 - factor);
    _list[1] *= factor;
    _list[2] *= factor;
    _list[3] *= factor;
    _list[4] = (_list[4] * factor).clamp(-255, 255);
    // g
    _list[5] *= factor;
    _list[6] += _list[6].sign * (1 - _list[6].abs()) * (1 - factor);
    _list[7] *= factor;
    _list[8] *= factor;
    _list[9] = (_list[9] * factor).clamp(-255, 255);
    // b
    _list[10] *= factor;
    _list[11] *= factor;
    _list[12] += _list[12].sign * (1 - _list[12].abs()) * (1 - factor);
    _list[13] *= factor;
    _list[14] = (_list[14] * factor).clamp(-255, 255);
    // a
    _list[15] *= factor;
    _list[16] *= factor;
    _list[17] *= factor;
    _list[18] += _list[18].sign * (1 - _list[18].abs()) * (1 - factor);
    _list[19] = (_list[19] * factor).clamp(-255, 255);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorMatrix &&
          runtimeType == other.runtimeType &&
          const ListEquality<double>().equals(_list, other._list);

  @override
  int get hashCode => const ListEquality<double>().hash(_list);
}
