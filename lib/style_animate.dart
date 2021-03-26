part of megami;

class _AnimatedDecorationBox extends ImplicitlyAnimatedWidget {
  /// The [curve] and [duration] arguments must not be null.
  _AnimatedDecorationBox({
    Key? key,
    required this.decoration,
    this.position = DecorationPosition.background,
    required this.child,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  })  : assert(decoration.debugAssertIsValid()),
        super(
          key: key,
          curve: curve,
          duration: duration,
          onEnd: onEnd,
        );

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The decoration to paint behind the [child].
  ///
  /// A shorthand for specifying just a solid color is available in the
  /// constructor: set the `color` argument instead of the `decoration`
  /// argument.
  final Decoration decoration;

  final DecorationPosition position;

  @override
  _AnimatedDecorationBoxState createState() => _AnimatedDecorationBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<Decoration>('bg', decoration, defaultValue: null));
    // TODO: debug [position]?
  }
}

class _AnimatedDecorationBoxState
    extends AnimatedWidgetBaseState<_AnimatedDecorationBox> {
  DecorationTween? _decoration;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _decoration = visitor(_decoration, widget.decoration,
        (dynamic value) => DecorationTween(begin: value)) as DecorationTween;
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: _decoration?.evaluate(animation) ?? widget.decoration,
      position: widget.position,
      child: widget.child,
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<DecorationTween>('bg', _decoration,
        defaultValue: null));
  }
}

class _AnimatedInnerShadow extends ImplicitlyAnimatedWidget {
  /// The [curve] and [duration] arguments must not be null.
  _AnimatedInnerShadow({
    Key? key,
    required this.boxShadow,
    required this.child,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  }) : super(
          key: key,
          curve: curve,
          duration: duration,
          onEnd: onEnd,
        );

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// The decoration to paint behind the [child].
  ///
  /// A shorthand for specifying just a solid color is available in the
  /// constructor: set the `color` argument instead of the `decoration`
  /// argument.
  final List<BoxShadow> boxShadow;

  @override
  _AnimatedInnerShadowState createState() => _AnimatedInnerShadowState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<List<BoxShadow>>('shadow', boxShadow,
        defaultValue: null));
    // TODO: debug [position]?
  }
}

class _AnimatedInnerShadowState
    extends AnimatedWidgetBaseState<_AnimatedInnerShadow> {
  _BoxShadowTween? _boxShadow;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _boxShadow = visitor(_boxShadow, widget.boxShadow,
        (dynamic value) => _BoxShadowTween(begin: value)) as _BoxShadowTween;
  }

  @override
  Widget build(BuildContext context) => InnerShadow(
      boxShadow: _boxShadow?.evaluate(animation) ?? widget.boxShadow,
      child: widget.child,
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<_BoxShadowTween>('shadow', _boxShadow,
        defaultValue: null));
  }
}

class _AnimatedConstrainedBox extends ImplicitlyAnimatedWidget {
  /// The [curve] and [duration] arguments must not be null.
  _AnimatedConstrainedBox({
    Key? key,
    required this.constraints,
    required this.child,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  })  : assert(constraints.debugAssertIsValid()),
        super(
          key: key,
          curve: curve,
          duration: duration,
          onEnd: onEnd,
        );

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  /// Additional constraints to apply to the child.
  ///
  /// The constructor `width` and `height` arguments are combined with the
  /// `constraints` argument to set this property.
  ///
  /// The [padding] goes inside the constraints.
  final BoxConstraints constraints;

  @override
  _AnimatedConstrainedBoxState createState() => _AnimatedConstrainedBoxState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>(
        'constraints', constraints,
        defaultValue: null, showName: false));
  }
}

class _AnimatedConstrainedBoxState
    extends AnimatedWidgetBaseState<_AnimatedConstrainedBox> {
  BoxConstraintsTween? _constraints;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _constraints = visitor(_constraints, widget.constraints,
        (dynamic value) => BoxConstraintsTween(begin: value)) as BoxConstraintsTween;
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: _constraints?.evaluate(animation) ?? widget.constraints,
    child: widget.child,
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<BoxConstraintsTween>(
        'constraints', _constraints,
        showName: false, defaultValue: null));
  }
}

class _AnimatedTransform extends ImplicitlyAnimatedWidget {
  /// Creates a container that animates its parameters implicitly.
  ///
  /// The [curve] and [duration] arguments must not be null.
  _AnimatedTransform({
    Key? key,
    required this.transform,
    this.origin,
    this.alignment,
    this.transformHitTests = true,
    required this.child,
    Curve curve = Curves.linear,
    required Duration duration,
  }) : super(
          key: key,
          curve: curve,
          duration: duration,
        );

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  final Offset? origin;

  final AlignmentGeometry? alignment;

  final bool transformHitTests;

  /// The transformation matrix to apply before painting the container.
  final Matrix4 transform;

  @override
  _AnimatedTransformState createState() => _AnimatedTransformState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AlignmentGeometry>(
        'alignment', alignment,
        showName: false, defaultValue: null));
    properties.add(ObjectFlagProperty<Matrix4>.has('transform', transform));
    // TODO: debug [origin], [transformHitTest]?
  }
}

class _AnimatedTransformState
    extends AnimatedWidgetBaseState<_AnimatedTransform> {
  AlignmentGeometryTween? _alignment;
  Matrix4Tween? _transform;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _alignment = visitor(_alignment, widget.alignment,
        (dynamic value) => AlignmentGeometryTween(begin: value)) as AlignmentGeometryTween;
    _transform = visitor(_transform, widget.transform,
        (dynamic value) => Matrix4Tween(begin: value)) as Matrix4Tween;
  }

  @override
  Widget build(BuildContext context) => Transform(
      transform: _transform?.evaluate(animation) ?? widget.transform,
      alignment: _alignment?.evaluate(animation) ?? widget.alignment,
      origin: widget.origin,
      transformHitTests: widget.transformHitTests,
    child: widget.child,
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(DiagnosticsProperty<AlignmentGeometryTween>(
        'alignment', _alignment,
        showName: false, defaultValue: null));
    description
        .add(ObjectFlagProperty<Matrix4Tween>.has('transform', _transform));
  }
}

class _AnimatedClipRRect extends ImplicitlyAnimatedWidget {
  /// The [curve] and [duration] arguments must not be null.
  _AnimatedClipRRect({
    Key? key,
    required this.borderRadius,
    this.clipper,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  }) : super(
          key: key,
          curve: curve,
          duration: duration,
          onEnd: onEnd,
        );

  /// The [child] contained by the container.
  ///
  /// If null, and if the [constraints] are unbounded or also null, the
  /// container will expand to fill all available space in its parent, unless
  /// the parent provides unbounded constraints, in which case the container
  /// will attempt to be as small as possible.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  final BorderRadius borderRadius;
  final CustomClipper<RRect>? clipper;
  final Clip clipBehavior;

  @override
  _AnimatedClipRRectState createState() => _AnimatedClipRRectState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    //TODO: debug [topLeft], [topRight], [bottomLeft], [bottomRight]
  }
}

class _AnimatedClipRRectState
    extends AnimatedWidgetBaseState<_AnimatedClipRRect> {
  Tween<BorderRadius>? _borderRadius;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _borderRadius = visitor(_borderRadius, widget.borderRadius,
        (dynamic value) => BorderRadiusTween(begin: value)) as BorderRadiusTween;
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
      clipper: widget.clipper,
      clipBehavior: widget.clipBehavior,
      borderRadius: _borderRadius?.evaluate(animation) ?? widget.borderRadius,
    child: widget.child,
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    //TODO: debug [_topLeft], [_topRight], [_bottomLeft], [_bottomRight]
  }
}

class _AnimatedBackgroundBlur extends ImplicitlyAnimatedWidget {
  /// Creates a widget that animates its opacity implicitly.
  ///
  /// The [opacity] argument must not be null and must be between 0.0 and 1.0,
  /// inclusive. The [curve] and [duration] arguments must not be null.
  const _AnimatedBackgroundBlur({
    Key? key,
    required this.child,
    required this.sigma,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  })  : assert(sigma >= 0.0),
        super(
          key: key,
          curve: curve,
          duration: duration,
          onEnd: onEnd,
        );

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.child}
  final Widget child;

  final double sigma;

  @override
  _AnimatedBackgroundBlurState createState() => _AnimatedBackgroundBlurState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('background blur', sigma));
  }
}

class _AnimatedBackgroundBlurState
    extends ImplicitlyAnimatedWidgetState<_AnimatedBackgroundBlur> {
  Tween<double>? _sigma;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _sigma = visitor(
        _sigma, widget.sigma, (dynamic value) => Tween<double>(begin: value)) as Tween<double>;
  }

  @override
  Widget build(BuildContext context) => BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: _sigma?.evaluate(animation) ?? widget.sigma,
        sigmaY: _sigma?.evaluate(animation) ?? widget.sigma,
      ),
      child: widget.child,
    );
}

// class _AnimatedText extends ImplicitlyAnimatedWidget {
//   /// Creates a container that animates its parameters implicitly.
//   ///
//   /// The [curve] and [duration] arguments must not be null.
//   _AnimatedText(
//     this.data, {
//     Key key,
//     this.locale,
//     this.maxLines,
//     this.overflow,
//     this.semanticsLabel,
//     this.softWrap,
//     this.strutStyle,
//     this.style,
//     this.textAlign,
//     this.textDirection,
//     this.textScaleFactor,
//     this.textWidthBasis,
//     Curve curve = Curves.linear,
//     @required Duration duration,
//     VoidCallback onEnd,
//   }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);
//
//   final String data;
//   final TextStyle style;
//   final StrutStyle strutStyle;
//   final TextAlign textAlign;
//   final TextDirection textDirection;
//   final Locale locale;
//   final bool softWrap;
//   final TextOverflow overflow;
//   final double textScaleFactor;
//   final int maxLines;
//   final String semanticsLabel;
//   final TextWidthBasis textWidthBasis;
//
//   @override
//   _AnimatedTextState createState() => _AnimatedTextState();
//
//   @override
//   void debugFillProperties(DiagnosticPropertiesBuilder properties) {
//     super.debugFillProperties(properties);
//     // TODO: denug variables
//   }
// }
//
// class _AnimatedTextState extends AnimatedWidgetBaseState<_AnimatedText> {
//   Tween<double> _textScaleFactor;
//   Tween<double> _fontSize;
//   Tween<double> _letterSpacing;
//   Tween<double> _wordSpacing;
//   Tween<double> _height;
//   Tween<double> _decorationThickness;
//   Tween<int> _maxLines;
//   ColorTween _color;
//   ColorTween _decorationColor;
//
//   // TODO: animate background and foreground?
//
//   @override
//   void forEachTween(TweenVisitor<dynamic> visitor) {
//     _textScaleFactor = visitor(_textScaleFactor, widget.textScaleFactor,
//         (dynamic value) => Tween<double>(begin: value));
//     _fontSize = visitor(_fontSize, widget.style?.fontSize,
//         (dynamic value) => Tween<double>(begin: value));
//     _letterSpacing = visitor(_letterSpacing, widget.style?.letterSpacing,
//         (dynamic value) => Tween<double>(begin: value));
//     _wordSpacing = visitor(_wordSpacing, widget.style?.wordSpacing,
//         (dynamic value) => Tween<double>(begin: value));
//     _height = visitor(_height, widget.style?.height,
//         (dynamic value) => Tween<double>(begin: value));
//     _decorationThickness = visitor(
//         _decorationThickness,
//         widget.style?.decorationThickness,
//         (dynamic value) => Tween<double>(begin: value));
//     _maxLines = visitor(_maxLines, widget.maxLines,
//         (dynamic value) => Tween<int>(begin: value));
//     _color = visitor(_color, widget.style?.color,
//         (dynamic value) => ColorTween(begin: value));
//     _decorationColor = visitor(_decorationColor, widget.style?.decorationColor,
//         (dynamic value) => ColorTween(begin: value));
//   }
//
//   @override
//   Widget build(BuildContext context) => Text(
//         widget.data,
//         style: widget.style?.copyWith(
//           fontSize: _fontSize?.evaluate(animation),
//           letterSpacing: _letterSpacing?.evaluate(animation),
//           wordSpacing: _wordSpacing?.evaluate(animation),
//           height: _height?.evaluate(animation),
//           decorationThickness: _decorationThickness?.evaluate(animation),
//           color: _color?.evaluate(animation),
//           decorationColor: _decorationColor?.evaluate(animation),
//         ),
//         strutStyle: widget.strutStyle,
//         textAlign: widget.textAlign,
//         textDirection: widget.textDirection,
//         locale: widget.locale,
//         softWrap: widget.softWrap,
//         overflow: widget.overflow,
//         textScaleFactor: _textScaleFactor?.evaluate(animation),
//         maxLines: _maxLines?.evaluate(animation),
//         semanticsLabel: widget.semanticsLabel,
//         textWidthBasis: widget.textWidthBasis,
//       );
//
//   @override
//   void debugFillProperties(DiagnosticPropertiesBuilder description) {
//     super.debugFillProperties(description);
//     // TODO: debug variables
//   }
// }
