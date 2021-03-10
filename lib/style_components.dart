part of megami;

abstract class _StyleComponent<T> {
  void merge(Declaration declaration, {String basePath});

  T build(BuildContext context);

  static Type typeOf(Declaration declaration) {
    switch (declaration.property) {
      case 'width':
      case 'height':
      case 'min-width':
      case 'min-height':
      case 'max-width':
      case 'max-height':
        return _ConstraintsComponent;
      case 'padding':
      case 'padding-top':
      case 'padding-right':
      case 'padding-bottom':
      case 'padding-left':
        return _PaddingComponent;
      case 'margin':
      case 'margin-top':
      case 'margin-right':
      case 'margin-bottom':
      case 'margin-left':
        return _MarginComponent;
      case 'background':
      case 'background-color':
      case 'background-image':
      case 'background-size':
      case 'background-repeat':
      case 'background-position':
        return _BackgroundComponent;
      case 'background-blend-mode':
        return _BackgroundBlendModeComponent;
      case 'border':
      case 'border-top':
      case 'border-top-color':
      case 'border-top-width':
      case 'border-right':
      case 'border-right-color':
      case 'border-right-width':
      case 'border-bottom':
      case 'border-bottom-color':
      case 'border-bottom-width':
      case 'border-left':
      case 'border-left-color':
      case 'border-left-width':
        return _BorderComponent;
      case 'border-radius':
      case 'border-top-left-radius':
      case 'border-top-right-radius':
      case 'border-bottom-right-radius':
      case 'border-bottom-left-radius':
        return _BorderRadiusComponent;
      case 'border-image':
      case 'border-image-source':
      case 'border-image-slice':
        return _BorderImageComponent;
      case 'box-shadow':
        return _BoxShadowComponent;
      case 'opacity':
        return _OpacityComponent;
      case 'filter':
        return _FilterComponent;
      case 'align':
        return _AlignComponent;
      case 'color':
        return _TextColorComponent;
      case 'text-align':
      case 'vertical-align':
        return _TextAlignComponent;
      case 'font':
      case 'font-family':
      case 'font-size':
      case 'font-variant':
      case 'font-weight':
      case 'font-style':
      case 'line-height':
        return _FontComponent;
      case 'transition':
      case 'transition-property':
      case 'transition-duration':
      case 'transition-timing-function':
        return _TransitionComponent;
      case 'overflow':
        return _OverFlowComponent;
      case 'transform':
      case 'transform-origin':
        return _TransformComponent;
      default:
        return null;
    }
  }

  static _StyleComponent create(Type type) {
    switch (type) {
      case _ConstraintsComponent:
        return _ConstraintsComponent();
      case _PaddingComponent:
        return _PaddingComponent();
      case _MarginComponent:
        return _MarginComponent();
      case _BackgroundComponent:
        return _BackgroundComponent();
      case _BackgroundBlendModeComponent:
        return _BackgroundBlendModeComponent();
      case _BorderComponent:
        return _BorderComponent();
      case _BorderRadiusComponent:
        return _BorderRadiusComponent();
      case _BorderImageComponent:
        return _BorderImageComponent();
      case _BoxShadowComponent:
        return _BoxShadowComponent();
      case _OpacityComponent:
        return _OpacityComponent();
      case _FilterComponent:
        return _FilterComponent();
      case _AlignComponent:
        return _AlignComponent();
      case _TextColorComponent:
        return _TextColorComponent();
      case _TextAlignComponent:
        return _TextAlignComponent();
      case _FontComponent:
        return _FontComponent();
      case _TransitionComponent:
        return _TransitionComponent();
      case _OverFlowComponent:
        return _OverFlowComponent();
      case _TransformComponent:
        return _TransformComponent();
      default:
        return null;
    }
  }

  static Widget decorate(BuildContext context, Widget widget,
      {Iterable<_StyleComponent> components}) {
    if (components == null || components.isEmpty) {
      return widget;
    }

    var res = widget;

    final transitions = components
            .whereType<_TransitionComponent>()
            .firstOrNull
            ?.build(context) ??
        {};
    final allTransition = transitions[_TransitionCompose.all];

    final textAlign =
        components.whereType<_TextAlignComponent>().firstOrNull?.build(context);

    final padding =
        components.whereType<_PaddingComponent>().firstOrNull?.build(context);

    if (res is Text) {
      final origin =
          (res as Text).style ?? Theme.of(context).textTheme.bodyText1;
      final textStyle = _merge(context, origin, components: components);
      res = (res as Text).copy(
        style: textStyle,
        textAlign: textAlign,
      );
    }
    if (res is TextField) {
      final origin =
          (res as TextField).style ?? Theme.of(context).textTheme.bodyText1;
      final textStyle = _merge(context, origin, components: components);
      res = (res as TextField).copy(
        style: textStyle,
        textAlign: textAlign,
        decoration: (res as TextField).decoration.copyWith(
          isCollapsed: true,
          contentPadding: padding,
          border: InputBorder.none,
        ),
      );
    } else if (padding != null) {
      final paddingTransition =
          transitions[_TransitionCompose.padding] ?? allTransition;
      if (paddingTransition != null) {
        res = AnimatedPadding(
          padding: padding,
          duration: paddingTransition.duration,
          curve: paddingTransition.curve,
          child: res,
        );
      } else {
        res = Padding(
          padding: padding,
          child: res,
        );
      }
    }

    final align =
        components.whereType<_AlignComponent>().firstOrNull?.build(context);
    final alignTransition =
        transitions[_TransitionCompose.align] ?? allTransition;
    if (align != null) {
      if (alignTransition != null) {
        res = AnimatedAlign(
          child: res,
          alignment: align,
          duration: alignTransition.duration,
          curve: alignTransition.curve,
        );
      } else {
        res = Align(
          child: res,
          alignment: align,
        );
      }
    }

    final background = components
            .whereType<_BorderImageComponent>()
            .firstOrNull
            ?.build(context) ??
        components
            .whereType<_BackgroundComponent>()
            .firstOrNull
            ?.build(context);
    final bgBlendMode = components
        .whereType<_BackgroundBlendModeComponent>()
        .firstOrNull
        ?.build(context);
    final border =
        components.whereType<_BorderComponent>().firstOrNull?.build(context);
    final borderUniform = border?.isUniform ?? true;
    final borderRadius = components
        .whereType<_BorderRadiusComponent>()
        .firstOrNull
        ?.build(context);
    final boxShadow =
        components.whereType<_BoxShadowComponent>().firstOrNull?.build(context);

    final decorationTransition =
        transitions[_TransitionCompose.decoration] ?? allTransition;

    final overflowHidden = components
            .whereType<_OverFlowComponent>()
            .firstOrNull
            ?.build(context) ??
        false;
    if (overflowHidden && (borderUniform || borderRadius == null)) {
      if (decorationTransition != null) {
        res = _AnimatedClipRRect(
          child: res,
          borderRadius: borderRadius ?? BorderRadius.zero,
          duration: decorationTransition.duration,
          curve: decorationTransition.curve,
        );
      } else {
        res = ClipRRect(
          child: res,
          borderRadius: borderRadius ?? BorderRadius.zero,
        );
      }
    }

    if (background != null ||
        border != null ||
        (boxShadow != null && !boxShadow.inset)) {
      final decoration = BoxDecoration(
        color: background?.color,
        image: background?.image,
        gradient: background?.gradient,
        border: border,
        borderRadius: borderUniform ? borderRadius : null,
        backgroundBlendMode: bgBlendMode,
        boxShadow: boxShadow != null && !boxShadow.inset
            ? [
                boxShadow.shadow(context),
              ]
            : [],
      );
      if (decorationTransition != null) {
        res = _AnimatedDecorationBox(
          child: res,
          decoration: decoration,
          duration: decorationTransition.duration,
          curve: decorationTransition.curve,
        );
      } else {
        res = DecoratedBox(
          child: res,
          decoration: decoration,
        );
      }
    }

    if (boxShadow != null && boxShadow.inset) {
      if (decorationTransition != null) {
        res = _AnimatedInnerShadow(
          child: res,
          boxShadow: [boxShadow.shadow(context)],
          duration: decorationTransition.duration,
          curve: decorationTransition.curve,
        );
      } else {
        res = InnerShadow(
          child: res,
          boxShadow: [boxShadow.shadow(context)],
        );
      }
    }

    final constraints = components
        .whereType<_ConstraintsComponent>()
        .firstOrNull
        ?.build(context);
    if (constraints != null) {
      final constraintsTransition =
          transitions[_TransitionCompose.constraints] ?? allTransition;
      if (constraintsTransition != null) {
        res = _AnimatedConstrainedBox(
          constraints: constraints,
          child: res,
          duration: constraintsTransition.duration,
          curve: constraintsTransition.curve,
        );
      } else {
        res = ConstrainedBox(
          constraints: constraints,
          child: res,
        );
      }
    }

    final opacityTransition =
        transitions[_TransitionCompose.opacity] ?? allTransition;
    final filter =
        components.whereType<_FilterComponent>().firstOrNull?.build(context);
    if (filter != null) {
      if (filter.dropShadow != null) {
        final dropShadowTransition =
            transitions[_TransitionCompose.dropShadow] ?? allTransition;
        if (dropShadowTransition != null) {
          res = DropShadow(
            child: res,
            boxShadow: [filter.dropShadow.shadow(context)],
          );
        } else {
          res = DropShadow(
            child: res,
            boxShadow: [filter.dropShadow.shadow(context)],
          );
        }
      }
      if (filter.blurFilter != null) {
        final blurTransition =
            transitions[_TransitionCompose.blurFilter] ?? allTransition;
        if (blurTransition != null) {
          res = ImageFiltered(
            child: res,
            imageFilter: filter.blurFilter,
          );
        } else {
          res = ImageFiltered(
            child: res,
            imageFilter: filter.blurFilter,
          );
        }
      }
      if (filter.colorMatrix != null) {
        final colorFilterTransition =
            transitions[_TransitionCompose.colorFilter] ?? allTransition;
        res = ColorFiltered(
          child: res,
          colorFilter: filter.colorMatrix.filter,
        );
      }
      if (filter.opacity != 1) {
        if (opacityTransition != null) {
          res = AnimatedOpacity(
            child: res,
            opacity: filter.opacity,
            duration: opacityTransition.duration,
            curve: opacityTransition.curve,
          );
        } else {
          res = Opacity(
            child: res,
            opacity: filter.opacity,
          );
        }
      }
    }

    final transform =
        components.whereType<_TransformComponent>().firstOrNull?.build(context);
    if (transform != null) {
      final transformTransition =
          transitions[_TransitionCompose.transform] ?? allTransition;
      if (transformTransition != null) {
        res = _AnimatedTransform(
          child: res,
          transform: transform.matrix,
          alignment: transform.origin ?? Alignment.center,
          duration: transformTransition.duration,
          curve: transformTransition.curve,
        );
      } else {
        res = Transform(
          child: res,
          transform: transform.matrix,
          alignment: transform.origin ?? Alignment.center,
        );
      }
    }

    final margin =
        components.whereType<_MarginComponent>().firstOrNull?.build(context);
    if (margin != null) {
      final marginTransition =
          transitions[_TransitionCompose.margin] ?? allTransition;
      if (marginTransition != null) {
        res = AnimatedPadding(
          padding: margin,
          duration: marginTransition.duration,
          curve: marginTransition.curve,
          child: res,
        );
      } else {
        res = Padding(
          padding: margin,
          child: res,
        );
      }
    }

    var opacity =
        components.whereType<_OpacityComponent>().firstOrNull?.build(context);
    if (opacity != null) {
      if (opacityTransition != null) {
        res = AnimatedOpacity(
          child: res,
          opacity: opacity,
          duration: opacityTransition.duration,
          curve: opacityTransition.curve,
        );
      } else {
        res = Opacity(
          child: res,
          opacity: opacity,
        );
      }
    }

    if (align != null && !(res is Align)) {
      if (alignTransition != null) {
        res = AnimatedAlign(
          child: res,
          alignment: align,
          duration: alignTransition.duration,
          curve: alignTransition.curve,
        );
      } else {
        res = Align(
          child: res,
          alignment: align,
        );
      }
    }

    return res;
  }

  static Widget decorateText(BuildContext context, _TextStyleWrapper wrapper,
      {Iterable<_StyleComponent> components}) {
    var textAlign = components
        ?.whereType<_TextAlignComponent>()
        ?.firstOrNull
        ?.build(context);
    var textStyle =
        _merge(context, wrapper.defaultStyle, components: components);
    return wrapper.builder(context, textStyle, textAlign);
  }

  static TabBar decorateTabIndicator(BuildContext context, TabBar tabBar,
      {Iterable<_StyleComponent> components}) {
    if (components == null || components.isEmpty) {
      return tabBar;
    }
    final padding =
        components.whereType<_PaddingComponent>().firstOrNull?.build(context);
    final background = components
            .whereType<_BorderImageComponent>()
            .firstOrNull
            ?.build(context) ??
        components
            .whereType<_BackgroundComponent>()
            .firstOrNull
            ?.build(context);
    final bgBlendMode = components
        .whereType<_BackgroundBlendModeComponent>()
        .firstOrNull
        ?.build(context);
    final border =
        components.whereType<_BorderComponent>().firstOrNull?.build(context);
    final borderUniform = border?.isUniform ?? true;
    final borderRadius = components
        .whereType<_BorderRadiusComponent>()
        .firstOrNull
        ?.build(context);
    final boxShadow =
        components.whereType<_BoxShadowComponent>().firstOrNull?.build(context);

    if (background != null ||
        border != null ||
        (boxShadow != null && !boxShadow.inset)) {
      return tabBar.copy(
          indicator: PaddingBoxDecoration(
        color: background?.color,
        image: background?.image,
        gradient: background?.gradient,
        border: border,
        borderRadius: borderUniform ? borderRadius : null,
        backgroundBlendMode: bgBlendMode,
        boxShadow: boxShadow != null && !boxShadow.inset
            ? [
                boxShadow.shadow(context),
              ]
            : [],
        insets: padding,
      ));
    }
    return tabBar;
  }

  static TabBar decorateTabControl(BuildContext context, TabBar tabBar,
      {Iterable<_StyleComponent> components, bool selected = false}) {
    if (components == null || components.isEmpty) {
      return tabBar;
    }
    final padding =
        components.whereType<_PaddingComponent>().firstOrNull?.build(context);
    final origin = Theme.of(context).textTheme.bodyText1;
    var textColor = components
        ?.whereType<_TextColorComponent>()
        ?.firstOrNull
        ?.build(context);
    final textStyle =
        _merge(context, origin, components: components, excludeColor: true);
    return selected
        ? tabBar.copy(
            labelStyle: textStyle,
            labelColor: textColor,
            labelPadding: padding,
          )
        : tabBar.copy(
            unselectedLabelStyle: textStyle,
            unselectedLabelColor: textColor,
            labelPadding: padding,
          );
  }
  
  // static TextField decorateTextFieldHint(BuildContext context, TextField textField,
  //     {Iterable<_StyleComponent> components}) {
  //   if (components == null || components.isEmpty) {
  //     return textField;
  //   }
  //   final textAlign = components.whereType<_TextAlignComponent>().firstOrNull?.build(context);
  //   final origin = textField.style ?? Theme.of(context).textTheme.bodyText1;
  //   final textStyle = _merge(context, origin, components: components);
  //   return textField.copy(
  //     decoration: textField.decoration.copyWith(
  //       hintStyle: textStyle
  //     ),
  //   );
  // }

  static TextStyle _merge(BuildContext context, TextStyle origin,
      {Iterable<_StyleComponent> components, bool excludeColor = false}) {
    var textColor = excludeColor
        ? null
        : components
            ?.whereType<_TextColorComponent>()
            ?.firstOrNull
            ?.build(context);
    var font =
        components?.whereType<_FontComponent>()?.firstOrNull?.build(context);
    var fontWeight = font?.font?.weight ?? origin.fontWeight;
    var fontSize =
        font?.font?.size?.dimension(context, fontSize: origin.fontSize) ??
            origin.fontSize;
    return origin.copyWith(
      color: textColor,
      fontSize: fontSize,
      fontFamily: font?.font?.fontsAsString,
      fontStyle: font?.font?.style,
      fontWeight: fontWeight,
      height: (font?.font?.lineHeight?.dimension(context, fontSize: fontSize) ??
              fontSize) /
          fontSize,
    );
  }
}

class _BackgroundCompose {
  final Color color;
  final DecorationImage image;
  final Gradient gradient;
  final Rect centerSlice;

  _BackgroundCompose({this.color, this.image, this.gradient, this.centerSlice});
}

class _ShadowCompose {
  final Color color;
  final Dimen offsetX;
  final Dimen offsetY;
  final Dimen blur;
  final Dimen spread;
  final bool inset;

  _ShadowCompose(
      {this.color,
      this.offsetX,
      this.offsetY,
      this.blur,
      this.spread,
      this.inset = false});

  BoxShadow shadow(BuildContext context) => BoxShadow(
        color: color,
        offset: Offset(offsetX?.dimension(context) ?? 0.0,
            offsetY?.dimension(context) ?? 0.0),
        blurRadius: blur?.dimension(context) ?? 0.0,
        spreadRadius: spread?.dimension(context) ?? 0.0,
      );
}

class _FilterCompose {
  final ColorMatrix colorMatrix;
  final _ShadowCompose dropShadow;
  final ui.ImageFilter blurFilter;
  final double opacity;

  _FilterCompose(
      {this.colorMatrix, this.dropShadow, this.blurFilter, this.opacity});
}

class _TransitionCompose {
  static final all = 'all';
  static final decoration = 'decoration';
  static final padding = 'padding';
  static final margin = 'margin';
  static final constraints = 'constraints';
  static final opacity = 'opacity';
  static final colorFilter = 'color-filter';
  static final blurFilter = 'blur-filter';
  static final dropShadow = 'drop-shadow';
  static final transform = 'transform';
  static final align = 'align';
  static final color = 'color';
  static final textAlign = 'text-align';

  final String target;
  final Duration duration;
  final Curve curve;

  _TransitionCompose(this.target, this.duration, this.curve);
}

class _TransformCompose {
  final Matrix4 matrix;
  final Alignment origin;
  final bool isSkew;

  _TransformCompose({this.matrix, this.origin, this.isSkew});
}

class _ConstraintsComponent extends _StyleComponent<BoxConstraints> {
  Dimen _width;
  Dimen _height;
  Dimen _minWidth;
  Dimen _minHeight;
  Dimen _maxWidth;
  Dimen _maxHeight;

  @override
  void merge(Declaration declaration, {String basePath}) {
    if (declaration.expression.expressions.isEmpty) return;
    if (!Dimen.isDimen(declaration.expression.expressions.first)) return;
    var exp = declaration.expression.expressions.first as LiteralTerm;
    var dimen = Dimen.fromLiteral(exp);
    switch (declaration.property) {
      case 'width':
        _width = dimen;
        break;
      case 'height':
        _height = dimen;
        break;
      case 'min-width':
        _minWidth = dimen;
        break;
      case 'min-height':
        _minHeight = dimen;
        break;
      case 'max-width':
        _maxWidth = dimen;
        break;
      case 'max-height':
        _maxHeight = dimen;
        break;
    }
  }

  @override
  BoxConstraints build(BuildContext context) => BoxConstraints(
        minWidth:
            _minWidth?.dimension(context) ?? _width?.dimension(context) ?? 0.0,
        minHeight: _minHeight?.dimension(context) ??
            _height?.dimension(context) ??
            0.0,
        maxWidth: _maxWidth?.dimension(context) ??
            _width?.dimension(context) ??
            double.infinity,
        maxHeight: _maxHeight?.dimension(context) ??
            _height?.dimension(context) ??
            double.infinity,
      );
}

class _PaddingComponent extends _StyleComponent<EdgeInsets> {
  final _Vector4<Dimen> _padding = _Vector4();

  @override
  void merge(Declaration declaration, {String basePath}) {
    var sizes = (declaration.expression)
        .expressions
        .whereType<LiteralTerm>()
        .where((e) => Dimen.isDimen(e))
        .map((e) => Dimen.fromLiteral(e))
        .toList();
    switch (declaration.property) {
      case 'padding-top':
        _padding.top = sizes.isEmpty ? null : sizes[0];
        break;
      case 'padding-right':
        _padding.right = sizes.isEmpty ? null : sizes[0];
        break;
      case 'padding-bottom':
        _padding.bottom = sizes.isEmpty ? null : sizes[0];
        break;
      case 'padding-left':
        _padding.left = sizes.isEmpty ? null : sizes[0];
        break;
      case 'padding':
        _padding.fill(sizes);
        break;
    }
  }

  @override
  EdgeInsets build(BuildContext context) {
    return EdgeInsets.only(
      top: _padding.top != null ? _padding.top.dimension(context) : 0,
      right: _padding.right != null ? _padding.right.dimension(context) : 0,
      bottom: _padding.bottom != null ? _padding.bottom.dimension(context) : 0,
      left: _padding.left != null ? _padding.left.dimension(context) : 0,
    );
  }
}

class _MarginComponent extends _StyleComponent<EdgeInsets> {
  final _Vector4<Dimen> _margin = _Vector4();

  @override
  void merge(Declaration declaration, {String basePath}) {
    var sizes = declaration.expression.expressions
        .whereType<LiteralTerm>()
        .where((e) => Dimen.isDimen(e))
        .map((e) => Dimen.fromLiteral(e))
        .toList();
    switch (declaration.property) {
      case 'margin-top':
        _margin.top = sizes.isEmpty ? null : sizes[0];
        break;
      case 'margin-right':
        _margin.right = sizes.isEmpty ? null : sizes[0];
        break;
      case 'margin-bottom':
        _margin.bottom = sizes.isEmpty ? null : sizes[0];
        break;
      case 'margin-left':
        _margin.left = sizes.isEmpty ? null : sizes[0];
        break;
      case 'margin':
        _margin.fill(sizes);
        break;
    }
  }

  @override
  EdgeInsets build(BuildContext context) => EdgeInsets.only(
        top: _margin.top != null ? _margin.top.dimension(context) : 0,
        right: _margin.right != null ? _margin.right.dimension(context) : 0,
        bottom: _margin.bottom != null ? _margin.bottom.dimension(context) : 0,
        left: _margin.left != null ? _margin.left.dimension(context) : 0,
      );
}

class _BackgroundComponent extends _StyleComponent<_BackgroundCompose> {
  Color _color;
  Uri _uri;
  BoxFit _fit = BoxFit.none;
  ImageRepeat _repeat = ImageRepeat.noRepeat;
  Alignment _alignment = Alignment.center;
  Gradient _gradient;

  @override
  void merge(Declaration declaration, {String basePath}) {
    _mergeColor(declaration);
    _mergeImage(declaration, basePath);
    _mergeGradient(declaration);
  }

  void _mergeColor(Declaration declaration) {
    switch (declaration.property) {
      case 'background':
      case 'background-color':
        var color = _ColorHelper.fromExp(declaration.expression);
        if (color != null) {
          _color = color;
        }
        break;
    }
  }

  void _mergeImage(Declaration declaration, String basePath) {
    switch (declaration.property) {
      case 'background':
      case 'background-image':
        var uri = _UriHelper.fromExp(declaration.expression);
        if (uri != null) {
          _uri = uri.toAbsolute(basePath: basePath);
        }
        break;
    }
    switch (declaration.property) {
      case 'background':
      case 'background-size':
        var fit = _BoxFitHelper.fromExp(declaration.expression);
        if (fit != null) {
          _fit = fit;
        }
        break;
    }
    switch (declaration.property) {
      case 'background':
      case 'background-repeat':
        var repeat = _ImageRepeatHelper.fromExp(declaration.expression);
        if (repeat != null) {
          _repeat = repeat;
        }
        break;
    }
    switch (declaration.property) {
      case 'background':
      case 'background-position':
        _alignment = _AlignmentHelper.fromExp(declaration.expression);
        break;
    }
  }

  void _mergeGradient(Declaration declaration) {
    switch (declaration.property) {
      case 'background':
      case 'background-image':
        var gradient = _GradientHelper.fromExp(declaration.expression);
        if (gradient != null) {
          _gradient = gradient;
        }
        break;
    }
  }

  @override
  _BackgroundCompose build(BuildContext context) {
    DecorationImage image;
    if (_uri != null) {
      final provider = _uri.toImage();
      if (provider != null) {
        image = DecorationImage(
            image: provider, fit: _fit, repeat: _repeat, alignment: _alignment);
      }
    }
    return _BackgroundCompose(color: _color, image: image, gradient: _gradient);
  }
}

class _BackgroundBlendModeComponent extends _StyleComponent<BlendMode> {
  BlendMode _blendMode;

  @override
  void merge(Declaration declaration, {String basePath}) {
    _blendMode = _BlendModeHelper.fromExp(declaration.expression);
  }

  @override
  BlendMode build(BuildContext context) => _blendMode;
}

class _BorderComponent extends _StyleComponent<Border> {
  final _Vector4<Dimen> _width = _Vector4<Dimen>();
  final _Vector4<Color> _color = _Vector4<Color>().all(Colors.black);

  @override
  void merge(Declaration declaration, {String basePath}) {
    _mergeWidth(declaration);
    _mergeColor(declaration);
  }

  void _mergeWidth(Declaration declaration) {
    var sizes = declaration.expression.expressions
        .whereType<LiteralTerm>()
        .where((e) => Dimen.isDimen(e))
        .map((e) => Dimen.fromLiteral(e))
        .toList();
    switch (declaration.property) {
      case 'border-top':
      case 'border-top-width':
        _width.top = sizes.isEmpty ? null : sizes[0];
        break;
      case 'border-right':
      case 'border-right-width':
        _width.right = sizes.isEmpty ? null : sizes[0];
        break;
      case 'border-bottom':
      case 'border-bottom-width':
        _width.bottom = sizes.isEmpty ? null : sizes[0];
        break;
      case 'border-left':
      case 'border-left-width':
        _width.left = sizes.isEmpty ? null : sizes[0];
        break;
      case 'border':
        _width.fill(sizes);
        break;
    }
  }

  void _mergeColor(Declaration declaration) {
    var color = _ColorHelper.fromExp(declaration.expression);
    switch (declaration.property) {
      case 'border-top':
      case 'border-top-color':
        _color.top = color ?? _color.top;
        break;
      case 'border-right':
      case 'border-right-color':
        _color.right = color ?? _color.right;
        break;
      case 'border-bottom':
      case 'border-bottom-color':
        _color.bottom = color ?? _color.bottom;
        break;
      case 'border-left':
      case 'border-left-color':
        _color.left = color ?? _color.left;
        break;
      case 'border':
        if (color != null) {
          _color.all(color);
        }
        break;
    }
  }

  @override
  Border build(BuildContext context) => Border(
        top: _width.top != null
            ? BorderSide(
                color: _color.top, width: _width.top.dimension(context))
            : BorderSide.none,
        right: _width.right != null
            ? BorderSide(
                color: _color.right, width: _width.right.dimension(context))
            : BorderSide.none,
        bottom: _width.bottom != null
            ? BorderSide(
                color: _color.bottom, width: _width.bottom.dimension(context))
            : BorderSide.none,
        left: _width.left != null
            ? BorderSide(
                color: _color.left, width: _width.left.dimension(context))
            : BorderSide.none,
      );
}

class _BorderRadiusComponent extends _StyleComponent<BorderRadiusGeometry> {
  final _Vector4<Dimen> _radiusX = _Vector4<Dimen>();
  final _Vector4<Dimen> _radiusY = _Vector4<Dimen>();

  @override
  void merge(Declaration declaration, {String basePath}) {
    var exps = (declaration.expression).expressions;
    var indexOfOp = exps.indexWhere((element) => element is OperatorSlash);
    switch (declaration.property) {
      case 'border-radius':
        List<LiteralTerm> sizesX;
        List<LiteralTerm> sizesY;
        if (indexOfOp < 0) {
          sizesX = sizesY = exps
              .where((e) => Dimen.isDimen(e))
              .map((e) => e as LiteralTerm)
              .toList();
        } else {
          sizesX = exps
              .sublist(0, indexOfOp)
              .where((e) => Dimen.isDimen(e))
              .map((e) => e as LiteralTerm)
              .toList();
          sizesY = exps
              .sublist(indexOfOp + 1)
              .where((e) => Dimen.isDimen(e))
              .map((e) => e as LiteralTerm)
              .toList();
        }
        _radiusX.fill(sizesX.map((e) => Dimen.fromLiteral(e)).toList());
        _radiusY.fill(sizesY.map((e) => Dimen.fromLiteral(e)).toList());
        break;
      case 'border-top-left-radius':
        if (indexOfOp < 0) {
          final r = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          if (r != null) {
            _radiusX.top = _radiusY.top = Dimen.fromLiteral(r);
          }
        } else {
          final rX = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          _radiusX.top = Dimen.fromLiteral(rX);
          final rY = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          _radiusY.top = Dimen.fromLiteral(rY);
        }
        break;
      case 'border-top-right-radius':
        if (indexOfOp < 0) {
          final r = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          if (r != null) {
            _radiusX.right = _radiusY.right = Dimen.fromLiteral(r);
          }
        } else {
          final rX = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          _radiusX.right = Dimen.fromLiteral(rX);
          final rY = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          _radiusY.right = Dimen.fromLiteral(rY);
        }
        break;
      case 'border-bottom-right-radius':
        if (indexOfOp < 0) {
          final r = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          if (r != null) {
            _radiusX.bottom = _radiusY.bottom = Dimen.fromLiteral(r);
          }
        } else {
          final rX = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          _radiusX.bottom = Dimen.fromLiteral(rX);
          final rY = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          _radiusY.bottom = Dimen.fromLiteral(rY);
        }
        break;
      case 'border-bottom-left-radius':
        if (indexOfOp < 0) {
          final r = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          if (r != null) {
            _radiusX.left = _radiusY.left = Dimen.fromLiteral(r);
          }
        } else {
          final rX = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          _radiusX.left = Dimen.fromLiteral(rX);
          final rY = exps
              .whereType<LiteralTerm>()
              .where((e) => Dimen.isDimen(e))
              .firstOrNull;
          _radiusY.left = Dimen.fromLiteral(rY);
        }
        break;
    }
  }

  @override
  BorderRadiusGeometry build(BuildContext context) {
    return BorderRadius.only(
      topLeft: Radius.elliptical(
          _radiusX.top.dimension(context), _radiusY.top.dimension(context)),
      topRight: Radius.elliptical(
          _radiusX.right.dimension(context), _radiusY.right.dimension(context)),
      bottomRight: Radius.elliptical(_radiusX.bottom.dimension(context),
          _radiusY.bottom.dimension(context)),
      bottomLeft: Radius.elliptical(
          _radiusX.left.dimension(context), _radiusY.left.dimension(context)),
    );
  }
}

class _BorderImageComponent extends _StyleComponent<_BackgroundCompose> {
  Uri _uri;
  final _Vector4<Dimen> _centerSlice = _Vector4();

  @override
  void merge(Declaration declaration, {String basePath}) {
    switch (declaration.property) {
      case 'border-image':
      case 'border-image-source':
        var uri = _UriHelper.fromExp(declaration.expression);
        if (uri != null) {
          _uri = uri.toAbsolute(basePath: basePath);
        }
        break;
    }
    switch (declaration.property) {
      case 'border-image':
      case 'border-image-slice':
        var sizes = (declaration.expression)
            .expressions
            .whereType<UnitTerm>()
            .where((e) => Dimen.isDimen(e))
            .map((e) => Dimen.fromLiteral(e))
            .toList();
        _centerSlice.fill(sizes);
    }
  }

  @override
  _BackgroundCompose build(BuildContext context) {
    DecorationImage image;
    if (_uri != null) {
      final provider = _uri.toImage();
      if (provider != null) {
        image = DecorationImage(
          image: provider,
          centerSlice: Rect.fromLTRB(
            _centerSlice.left?.dimension(context) ?? 0,
            _centerSlice.top?.dimension(context) ?? 0,
            _centerSlice.right?.dimension(context) ?? 0,
            _centerSlice.bottom?.dimension(context) ?? 0,
          ),
        );
      }
    }
    return _BackgroundCompose(image: image);
  }
}

class _BoxShadowComponent extends _StyleComponent<_ShadowCompose> {
  Color _color;
  Dimen _offsetX;
  Dimen _offsetY;
  Dimen _blur;
  Dimen _spread;
  bool _inset = false;

  @override
  void merge(Declaration declaration, {String basePath}) => _merge(declaration.expression);

  void _merge(Expressions expressions) {
    var exps = expressions.expressions;
    if (exps.length < 2) return;
    _color = _ColorHelper.fromExps(expressions) ?? Colors.black;
    _inset =
        exps.last is LiteralTerm && (exps.last as LiteralTerm).text == 'inset';
    if (Dimen.isDimen(exps.first)) {
      _offsetX = Dimen.fromLiteral(exps.first as LiteralTerm);
    } else {
      return;
    }
    if (Dimen.isDimen(exps[1])) {
      _offsetY = Dimen.fromLiteral(exps[1] as LiteralTerm);
    } else {
      return;
    }
    if (exps.length >= 3 && Dimen.isDimen(exps[2])) {
      _blur = Dimen.fromLiteral(exps[2] as LiteralTerm);
    } else {
      return;
    }
    if (exps.length >= 4 && Dimen.isDimen(exps[3])) {
      _spread = Dimen.fromLiteral(exps[3] as LiteralTerm);
    } else {
      return;
    }
  }

  @override
  _ShadowCompose build(BuildContext context) => _ShadowCompose(
        color: _color,
        offsetX: _offsetX,
        offsetY: _offsetY,
        blur: _blur,
        spread: _spread,
        inset: _inset,
      );
}

class _OpacityComponent extends _StyleComponent<double> {
  double _opacity = 1.0;

  @override
  void merge(Declaration declaration, {String basePath}) {
    if (declaration.expression.expressions.isEmpty) return;
    var exp = declaration.expression.expressions.first;
    if (exp is NumberTerm || exp is PercentageTerm) {
      _opacity = exp.asDouble.clamp(0.0, 1.0);
    }
  }

  @override
  double build(BuildContext context) => _opacity;
}

class _FilterComponent extends _StyleComponent<_FilterCompose> {
  ColorMatrix _colorMatrix;
  _BoxShadowComponent _dropShadow;
  Dimen _blurRadius;
  double _opacity = 1.0;

  @override
  void merge(Declaration declaration, {String basePath}) {
    declaration.expression.expressions
        .whereType<FunctionTerm>()
        .forEach((element) {
      _merge(element);
    });
  }

  void _merge(FunctionTerm exp) {
    ColorMatrix matrix;
    switch (exp.text) {
      case 'blur':
        final term =
            exp.params.expressions.whereType<LiteralTerm>().firstOrNull;
        if (term != null) {
          _blurRadius = Dimen.fromLiteral(term);
        }
        break;
      case 'brightness':
        matrix =
            _makeColorMatrix(exp, (factor) => ColorMatrix.brightness(factor));
        break;
      case 'contrast':
        matrix =
            _makeColorMatrix(exp, (factor) => ColorMatrix.contrast(factor));
        break;
      case 'drop-shadow':
        _dropShadow ??= _BoxShadowComponent();
        _dropShadow._merge(exp.params);
        break;
      case 'grayscale':
        matrix =
            _makeColorMatrix(exp, (factor) => ColorMatrix.grayscale(factor));
        break;
      case 'hue-rotate':
        matrix =
            _makeHueRotate(exp, (radians) => ColorMatrix.hueRotate(radians));
        break;
      case 'invert':
        matrix = _makeColorMatrix(exp, (factor) => ColorMatrix.invert(factor));
        break;
      case 'opacity':
        final p = exp.params.expressions.firstOrNull;
        if (p != null && (p is NumberTerm || p is PercentageTerm)) {
          _opacity = p.asDouble.clamp(0.0, 1.0);
        }
        break;
      case 'saturate':
        matrix =
            _makeColorMatrix(exp, (factor) => ColorMatrix.saturation(factor));
        break;
      case 'sepia':
        matrix = _makeColorMatrix(exp, (factor) => ColorMatrix.sepia(factor));
        break;
    }
    _colorMatrix = _colorMatrix != null && matrix != null
        ? _colorMatrix.postConcat(matrix)
        : (_colorMatrix ?? matrix);
  }

  ColorMatrix _makeColorMatrix(
      FunctionTerm term, ColorMatrix Function(double factor) builder) {
    final p = term.params.expressions.firstOrNull;
    if (p != null && (p is NumberTerm || p is PercentageTerm)) {
      return builder(p.asDouble);
    }
    return null;
  }

  ColorMatrix _makeHueRotate(
      FunctionTerm term, ColorMatrix Function(double radians) builder) {
    final p = term.params.expressions.firstOrNull;
    if (p != null) {
      if (p is AngleTerm) {
        var radians = p.value as num;
        switch (p.unit) {
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
        return builder(radians);
      }
    }
    return null;
  }

  @override
  _FilterCompose build(BuildContext context) => _FilterCompose(
        colorMatrix: _colorMatrix,
        dropShadow: _dropShadow?.build(context),
        blurFilter: _blurRadius != null
            ? ui.ImageFilter.blur(
                sigmaX: _blurRadius.dimension(context),
                sigmaY: _blurRadius.dimension(context),
              )
            : null,
        opacity: _opacity,
      );
}

class _AlignComponent extends _StyleComponent<Alignment> {
  Alignment _alignment;

  @override
  void merge(Declaration declaration, {String basePath}) {
    _alignment = _AlignmentHelper.fromExp(declaration.expression);
  }

  @override
  Alignment build(BuildContext context) => _alignment;
}

/// Text stuff
class _TextColorComponent extends _StyleComponent<Color> {
  Color _color;

  @override
  void merge(Declaration declaration, {String basePath}) {
    switch (declaration.property) {
      case 'color':
        var color = _ColorHelper.fromExp(declaration.expression);
        if (color != null) {
          _color = color;
        }
        break;
    }
  }

  @override
  Color build(BuildContext context) => _color;
}

class _TextAlignComponent extends _StyleComponent<TextAlign> {
  TextAlign _alignment;

  @override
  void merge(Declaration declaration, {String basePath}) {
    _alignment = _AlignmentHelper.taFromExp(declaration.expression);
  }

  @override
  TextAlign build(BuildContext context) => _alignment;
}

class _FontComponent extends _StyleComponent<FontExpression> {
  FontExpression _font;

  @override
  void merge(Declaration declaration, {String basePath}) {
    if (declaration.hasDartStyle && declaration.dartStyle.isFont) {
      _font = declaration.dartStyle as FontExpression;
    }
  }

  @override
  FontExpression build(BuildContext context) => _font;
}

class _TransitionComponent
    extends _StyleComponent<Map<String, _TransitionCompose>> {
  final List<String> _targets = [];
  final List<Duration> _durations = [];
  final List<Curve> _curves = [];

  @override
  void merge(Declaration declaration, {String basePath}) {
    switch (declaration.property) {
      case 'transition':
        declaration.expression.resolvedExpressions
            .whereType<Expressions>()
            .forEach((element) {
          if (_mergeTarget(element)) {
            _mergeDuration(element);
            _mergeCurve(element);
          }
        });
        break;
      case 'transition-property':
        _mergeTarget(declaration.expression);
        break;
      case 'transition-duration':
        _mergeDuration(declaration.expression);
        break;
      case 'transition-timing-function':
        _mergeCurve(declaration.expression);
        break;
    }
  }

  bool _mergeTarget(Expressions expressions) {
    final targetTerm = expressions.expressions.firstOrNull;
    if (targetTerm != null && targetTerm is LiteralTerm) {
      _targets.add(targetTerm.text.trim());
      return true;
    }
    return false;
  }

  void _mergeDuration(Expressions expressions) {
    final term = expressions.expressions.whereType<TimeTerm>().firstOrNull;
    final duration = _DurationHelper.fromExp(term);
    if (duration != null) _durations.add(duration);
  }

  void _mergeCurve(Expressions expressions) {
    final term = expressions.expressions.reversed
        .where((element) => element is LiteralTerm || element is FunctionTerm)
        .firstOrNull;
    final curve = _CurveHelper.fromExp(term);
    if (curve != null) _curves.add(curve);
  }

  @override
  Map<String, _TransitionCompose> build(BuildContext context) {
    final res = <String, _TransitionCompose>{};
    final count = min(_targets.length, _durations.length);
    for (var i = 0; i < count; i++) {
      res[_targets[i]] = _TransitionCompose(_targets[i], _durations[i],
          i < _curves.length ? _curves[i] : Curves.ease);
    }
    return res;
  }
}

class _OverFlowComponent extends _StyleComponent<bool> {
  bool _overflowHidden = false;

  @override
  void merge(Declaration declaration, {String basePath}) {
    _overflowHidden = declaration.expression.expressions
            .whereType<LiteralTerm>()
            .firstOrNull
            ?.text ==
        'hidden';
  }

  @override
  bool build(BuildContext context) => _overflowHidden;
}

class _TransformComponent extends _StyleComponent<_TransformCompose> {
  Matrix4 _matrix;
  Alignment _origin;

  bool _isTranslate = false;
  bool _isSkew = false;

  final List<Dimen> _translate = List.filled(3, const Dimen.zero());

  @override
  void merge(Declaration declaration, {String basePath}) {
    switch (declaration.property) {
      case 'transform':
        _mergeMatrix(declaration);
        break;
      case 'transform-origin':
        _mergeOrigin(declaration);
        break;
    }
  }

  void _mergeMatrix(Declaration declaration) {
    if (declaration.expression.expressions
            .whereType<LiteralTerm>()
            .firstOrNull
            ?.text ==
        'none') {
      _matrix = Matrix4.identity();
      return;
    }
    final exp = declaration.expression.expressions
        .whereType<FunctionTerm>()
        .firstOrNull;
    if (exp == null) return;
    final params = exp.resolvedParams
        .whereType<NumberTerm>()
        .map((e) => e.asDouble)
        .toList();
    final dimens = exp.resolvedParams
        .whereType<LiteralTerm>()
        .where((element) => Dimen.isDimen(element))
        .map((e) => Dimen.fromLiteral(e))
        .toList();
    final radians = exp.resolvedParams
        .whereType<AngleTerm>()
        .map((e) => _AngleHelper.radiansFrom(e))
        .toList();
    switch (exp.value) {
      case 'matrix':
        if (params.length == 6) {
          _matrix = Matrix4.identity()
            ..row0.x = params[0]
            ..row0.y = params[1]
            ..row0.z = params[2]
            ..row1.x = params[3]
            ..row1.y = params[4]
            ..row1.z = params[5];
        }
        break;
      case 'matrix3d':
        if (params.length == 16) {
          _matrix = Matrix4.fromList(params);
        }
        break;
      case 'translate':
        if (dimens.length == 2) {
          _translate.setRange(0, 2, dimens);
        }
        _isTranslate = true;
        break;
      case 'translate3d':
        if (dimens.length == 3) {
          _translate.setRange(0, 3, dimens);
        }
        _isTranslate = true;
        break;
      case 'translateX':
        if (dimens.length == 1) {
          _translate[0] = dimens[0];
        }
        _isTranslate = true;
        break;
      case 'translateY':
        if (dimens.length == 1) {
          _translate[1] = dimens[0];
        }
        _isTranslate = true;
        break;
      case 'translateZ':
        if (dimens.length == 1) {
          _translate[2] = dimens[0];
        }
        _isTranslate = true;
        break;
      case 'scale':
        if (params.length == 2) {
          _matrix = Matrix4.diagonal3Values(params[0], params[1], 0);
        }
        break;
      case 'scale3d':
        if (params.length == 3) {
          _matrix = Matrix4.diagonal3Values(max(params[0], 0.000001),
              max(params[1], 0.000001), max(params[2], 0.000001));
        }
        break;
      case 'scaleX':
        if (params.length == 1) {
          _matrix = Matrix4.diagonal3Values(max(params[0], 0.000001), 1, 1);
        }
        break;
      case 'scaleY':
        if (params.length == 1) {
          _matrix = Matrix4.diagonal3Values(1, max(params[0], 0.000001), 1);
        }
        break;
      case 'scaleZ':
        if (params.length == 1) {
          _matrix = Matrix4.diagonal3Values(1, 1, max(params[0], 0.000001));
        }
        break;
      case 'rotate':
      case 'rotateZ':
        if (radians.length == 1) {
          _matrix = Matrix4.rotationZ(radians[0]);
        }
        break;
      case 'rotate3d':
        if (radians.length == 3) {
          _matrix = Matrix4.identity()
            ..rotate3(vector.Vector3(radians[0], radians[1], radians[2]));
        }
        break;
      case 'rotateX':
        if (radians.length == 1) {
          _matrix = Matrix4.rotationX(radians[0]);
        }
        break;
      case 'rotateY':
        if (radians.length == 1) {
          _matrix = Matrix4.rotationY(radians[0]);
        }
        break;
      case 'skew':
        if (radians.length == 2) {
          _matrix = Matrix4.skew(radians[0], radians[1]);
          _isSkew = true;
        }
        break;
      case 'skewX':
        if (radians.length == 1) {
          _matrix = Matrix4.skewX(radians[0]);
          _isSkew = true;
        }
        break;
      case 'skewY':
        if (radians.length == 1) {
          _matrix = Matrix4.skewY(radians[0]);
          _isSkew = true;
        }
        break;
    }
  }

  void _mergeOrigin(Declaration declaration) {
    _origin = _AlignmentHelper.fromExp(declaration.expression);
  }

  @override
  _TransformCompose build(BuildContext context) {
    if (_isTranslate) {
      _matrix = Matrix4.translationValues(
        _translate[0].dimension(context),
        _translate[1].dimension(context),
        _translate[2].dimension(context),
      );
    }
    return _TransformCompose(
      matrix: _matrix,
      origin: _origin,
      isSkew: _isSkew,
    );
  }
}
