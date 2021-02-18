import 'dart:io';
import 'dart:math';

import 'css/visitor.dart';
import 'package:flutter/material.dart';
import 'megami_colors.dart';
import 'megami_dimens.dart';
import 'megami_utils.dart';
import 'style_exts.dart';

abstract class StyleComponent<T> {
  StyleComponent<T> merge(Declaration declaration);

  T build(BuildContext context);

  static Type typeOf(Declaration declaration) {
    switch (declaration.property) {
      case 'padding':
      case 'padding-top':
      case 'padding-right':
      case 'padding-bottom':
      case 'padding-left':
        return PaddingComponent;
      case 'margin':
      case 'margin-top':
      case 'margin-right':
      case 'margin-bottom':
      case 'margin-left':
        return MarginComponent;
      case 'background':
      case 'background-color':
      case 'background-image':
      case 'background-image-size':
      case 'background-image-repeat':
      case 'background-image-position':
        return BackgroundComponent;
      case 'background-blend-mode':
        return BackgroundBlendModeComponent;
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
        return BorderComponent;
      case 'border-radius':
        return BorderRadiusComponent;
      case 'border-image':
      case 'border-image-source':
      case 'border-image-slice':
        return BorderImageComponent;
      default:
        return null;
    }
  }

  static StyleComponent create(Type type) {
    switch (type) {
      case PaddingComponent:
        return PaddingComponent();
      case MarginComponent:
        return MarginComponent();
      case BackgroundComponent:
        return BackgroundComponent();
      case BackgroundBlendModeComponent:
        return BackgroundBlendModeComponent();
      case BorderComponent:
        return BorderComponent();
      case BorderRadiusComponent:
        return BorderRadiusComponent();
      case BorderImageComponent:
        return BorderImageComponent();
      default:
        return null;
    }
  }

  static Widget decorate(BuildContext context, Widget widget,
      Iterable<StyleComponent> components) {
    var res = widget;
    var padding = components.firstOrNull<PaddingComponent>()?.build(context);
    if (padding != null) {
      if (res is TextField) {
        res = (res as TextField).copy(
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: padding,
            border: InputBorder.none,
          ),
        );
      } else {
        res = Padding(
          padding: padding,
          child: res,
        );
      }
    }
    var background =
        components.firstOrNull<BorderImageComponent>()?.build(context) ??
            components.firstOrNull<BackgroundComponent>()?.build(context);
    var bgBlendMode =
        components.firstOrNull<BackgroundBlendModeComponent>()?.build(context);
    var border = components.firstOrNull<BorderComponent>()?.build(context);
    var borderUniform = border?.isUniform ?? true;
    var borderRadius =
        components.firstOrNull<BorderRadiusComponent>()?.build(context);
    res = DecoratedBox(
      decoration: BoxDecoration(
        color: background?.color,
        image: background?.image,
        border: components.firstOrNull<BorderComponent>()?.build(context),
        borderRadius: borderUniform ? borderRadius : null,
        backgroundBlendMode: bgBlendMode,
      ),
      child: res,
    );
    var margin = components.firstOrNull<MarginComponent>()?.build(context);
    if (margin != null) {
      res = Padding(
        padding: margin,
        child: res,
      );
    }
    return res;
  }
}

class BackgroundCompose {
  final Color color;
  final DecorationImage image;
  final Gradient gradient;
  final Rect centerSlice;

  BackgroundCompose({this.color, this.image, this.gradient, this.centerSlice});
}

class PaddingComponent extends StyleComponent<EdgeInsets> {
  final Vector4<Dimen> _padding = Vector4();

  @override
  PaddingComponent merge(Declaration declaration) {
    var sizes = (declaration.expression)
        .expressions
        .whereType<UnitTerm>()
        .map((e) => Dimen.fromUnit(e))
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
    return this;
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

class MarginComponent extends StyleComponent<EdgeInsets> {
  final Vector4<Dimen> _margin = Vector4();

  @override
  MarginComponent merge(Declaration declaration) {
    var sizes = declaration.expression
        .expressions
        .whereType<UnitTerm>()
        .map((e) => Dimen.fromUnit(e))
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
    return this;
  }

  @override
  EdgeInsets build(BuildContext context) {
    return EdgeInsets.only(
      top: _margin.top != null ? _margin.top.dimension(context) : 0,
      right: _margin.right != null ? _margin.right.dimension(context) : 0,
      bottom: _margin.bottom != null ? _margin.bottom.dimension(context) : 0,
      left: _margin.left != null ? _margin.left.dimension(context) : 0,
    );
  }
}

class BackgroundComponent extends StyleComponent<BackgroundCompose> {
  Color _color;
  Uri _uri;
  BoxFit _fit = BoxFit.none;
  ImageRepeat _repeat = ImageRepeat.noRepeat;
  Alignment _alignment = Alignment.center;
  Gradient _gradient;

  @override
  BackgroundComponent merge(Declaration declaration) {
    _mergeColor(declaration);
    _mergeImage(declaration);
    return this;
  }

  void _mergeColor(Declaration declaration) {
    switch (declaration.property) {
      case 'background':
      case 'background-color':
        var color = ColorHelper.fromExp(declaration.expression);
        if (color != null) {
          _color = color;
        }
        break;
    }
  }

  void _mergeImage(Declaration declaration) {
    switch (declaration.property) {
      case 'background':
      case 'background-image':
        var uri = UriHelper.fromExp(declaration.expression);
        if (uri != null) {
          _uri = uri;
        }
        // var gradient =
        break;
    }
    switch (declaration.property) {
      case 'background':
      case 'background-image-size':
        var fit = BoxFitHelper.fromExp(declaration.expression);
        if (fit != null) {
          _fit = fit;
        }
        break;
    }
    switch (declaration.property) {
      case 'background':
      case 'background-image-repeat':
        var repeat = ImageRepeatHelper.fromExp(declaration.expression);
        if (repeat != null) {
          _repeat = repeat;
        }
        break;
    }
    switch (declaration.property) {
      case 'background':
      case 'background-image-position':
        _alignment = AlignmentHelper.fromExp(declaration.expression);
        break;
    }
  }

  @override
  BackgroundCompose build(BuildContext context) {
    DecorationImage image;
    if (_uri != null) {
      ImageProvider provider;
      switch (_uri.scheme) {
        case 'http':
        case 'https':
          provider = NetworkImage(_uri.toString());
          break;
        case 'file':
          provider = FileImage(File(_uri.toFilePath()));
          break;
        case 'asset':
          provider = AssetImage(_uri.path);
          break;
      }
      if (provider != null) {
        image = DecorationImage(
            image: provider, fit: _fit, repeat: _repeat, alignment: _alignment);
      }
    }
    return BackgroundCompose(color: _color, image: image);
  }
}

class BackgroundBlendModeComponent extends StyleComponent<BlendMode> {
  BlendMode _blendMode;

  @override
  BackgroundBlendModeComponent merge(Declaration declaration) {
    switch (declaration.property) {
      case 'background-blend-mode':
        _blendMode = BlendModeHelper.fromExp(declaration.expression);
        break;
    }
    return this;
  }

  @override
  BlendMode build(BuildContext context) => _blendMode;
}

class BorderComponent extends StyleComponent<Border> {
  final Vector4<Dimen> _width = Vector4<Dimen>();
  final Vector4<Color> _color = Vector4<Color>().all(Colors.black);

  @override
  BorderComponent merge(Declaration declaration) {
    _mergeWidth(declaration);
    _mergeColor(declaration);
    return this;
  }

  void _mergeWidth(Declaration declaration) {
    var sizes = declaration.expression
        .expressions
        .whereType<UnitTerm>()
        .map((e) => Dimen.fromUnit(e))
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
    var color = ColorHelper.fromExp(declaration.expression);
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
  Border build(BuildContext context) {
    return Border(
      top: _width.top != null
          ? BorderSide(color: _color.top, width: _width.top.dimension(context))
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
}

class BorderRadiusComponent extends StyleComponent<BorderRadiusGeometry> {
  final Vector4<Dimen> _radiusX = Vector4<Dimen>();
  final Vector4<Dimen> _radiusY = Vector4<Dimen>();

  @override
  BorderRadiusComponent merge(Declaration declaration) {
    var exps = (declaration.expression).expressions;
    var indexOfOp = exps.indexWhere((element) => element is OperatorSlash);
    List<LiteralTerm> sizesX;
    List<LiteralTerm> sizesY;
    if (indexOfOp < 0) {
      sizesX = sizesY = exps
          .where((element) => Dimen.isDimen(element))
          .map((e) => e as LiteralTerm)
          .toList();
    } else {
      sizesX = exps
          .sublist(0, indexOfOp)
          .where((element) => Dimen.isDimen(element))
          .map((e) => e as LiteralTerm)
          .toList();
      sizesY = exps
          .sublist(indexOfOp + 1)
          .where((element) => Dimen.isDimen(element))
          .map((e) => e as LiteralTerm)
          .toList();
    }
    _radiusX.fill(sizesX.map((e) => Dimen.fromLiteral(e)).toList());
    _radiusY.fill(sizesY.map((e) => Dimen.fromLiteral(e)).toList());
    return this;
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

class BorderImageComponent extends StyleComponent<BackgroundCompose> {
  Uri _uri;
  final Vector4<Dimen> _centerSlice = Vector4();

  @override
  BorderImageComponent merge(Declaration declaration) {
    switch (declaration.property) {
      case 'border-image':
      case 'border-image-source':
        var uri = UriHelper.fromExp(declaration.expression);
        if (uri != null) {
          _uri = uri;
        }
        break;
    }
    switch (declaration.property) {
      case 'border-image':
      case 'border-image-slice':
        var sizes = (declaration.expression)
            .expressions
            .whereType<UnitTerm>()
            .map((e) => Dimen.fromUnit(e))
            .toList();
        _centerSlice.fill(sizes);
    }
    return this;
  }

  @override
  BackgroundCompose build(BuildContext context) {
    DecorationImage image;
    if (_uri != null) {
      ImageProvider provider;
      switch (_uri.scheme) {
        case 'http':
        case 'https':
          provider = NetworkImage(_uri.toString());
          break;
        case 'file':
          provider = FileImage(File(_uri.toFilePath()));
          break;
        case 'asset':
          provider = AssetImage(_uri.path);
          break;
      }
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
    return BackgroundCompose(image: image);
  }
}
