part of megami;

extension _SelectorExt on Selector {
  bool match(_SelectorSection selector) {
    var strict = true;
    var matched = simpleSelectorSequences.reversed.fold(selector,
        (previousValue, element) {
      if (previousValue == null) return null;
      strict = previousValue == selector ||
          element.isCombinatorGreater ||
          element.isCombinatorPlus;
      var matched = element.match(previousValue as _SelectorSection, strict);
      return matched;
    });
    return matched != null;
  }

  bool get isElement =>
      simpleSelectorSequences.lastOrNull != null &&
      simpleSelectorSequences.last.simpleSelector is PseudoElementSelector;

  int get weight => simpleSelectorSequences.fold(
      0, (previousValue, element) => previousValue + element.weight);
}

extension _SelectorSequenceExt on SimpleSelectorSequence {
  _SelectorSection? match(_SelectorSection? selector, bool strict) {
    var matched = selector?.sections
            .any((element) => simpleSelector.match(element, selector.index)) ??
        false;
    if (matched) {
      if (isCombinatorGreater || isCombinatorDescendant)
        return selector!.parent;
      if (isCombinatorPlus) return selector!.index > 0 ? selector : null;
      return selector;
    } else if (!strict && selector!.parent != null) {
      return match(selector.parent, strict);
    }
    return null;
  }

  int get weight =>
      simpleSelector.weight + combinator - TokenKind.COMBINATOR_NONE;
}

extension _SimpleSelectorExt on SimpleSelector {
  bool match(String selector, int index) {
    if (isWildcard) return true;
    switch (runtimeType) {
      case IdSelector:
        return '#$name' == selector;
      case ClassSelector:
        return '.$name' == selector;
      case ElementSelector:
        return name == selector;
      case NamespaceSelector:
        return name == selector;
      case PseudoClassSelector:
        return (this as PseudoClassSelector).match(selector, index);
      case PseudoClassFunctionSelector:
        return (this as PseudoClassFunctionSelector).match(selector, index);
      case PseudoElementSelector:
        switch (name) {
          case 'tab-control':
          case 'tab-control-selected':
          case 'tab-indicator':
            return true;
        }
        return false;
      default:
        return false;
    }
  }

  int get weight {
    switch (runtimeType) {
      case IdSelector:
        return 100;
      case ClassSelector:
        return 10;
      case ElementSelector:
        return 1;
      case NamespaceSelector:
        return 1;
      case PseudoClassSelector:
        return 1;
      case PseudoClassFunctionSelector:
        return 1;
      default:
        return 0;
    }
  }
}

extension _PseudoClassSelectorExt on PseudoClassSelector {
  bool match(String selector, int index) {
    switch (name) {
      case 'first-child':
        return index == 0;
    }
    return false;
  }
}

extension _PseudoClassFunctionSelectorExt on PseudoClassFunctionSelector {
  bool match(String selector, int index) {
    switch (name) {
      case 'nth-child':
        if (expression.expressions.isEmpty) {
          return false;
        } else {
          return expression.expressions
                  .whereType<LiteralTerm>()
                  .firstOrNull
                  ?.value ==
              index + 1;
        }
    }
    return false;
  }
}

extension _ExpressionExt on Expression {
  num get asNum {
    if (this is NumberTerm) {
      return (this as NumberTerm).value;
    }
    if (this is PercentageTerm) {
      return (this as PercentageTerm).value / 100.0;
    }
    if (this is UnitTerm) {
      return (this as UnitTerm).value;
    }
    return 0;
  }

  int get asInt => asNum.floor();

  double get asDouble => asNum.toDouble();
}

extension _TextExt on Text {
  Text copy({
    String? data,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
  }) =>
      Text(
        data ?? this.data!,
        style: style ?? this.style,
        strutStyle: strutStyle ?? this.strutStyle,
        textAlign: textAlign ?? this.textAlign,
        locale: locale ?? this.locale,
        maxLines: maxLines ?? this.maxLines,
        overflow: overflow ?? this.overflow,
        semanticsLabel: semanticsLabel ?? this.semanticsLabel,
        softWrap: softWrap ?? this.softWrap,
        textDirection: textDirection ?? this.textDirection,
        textScaleFactor: textScaleFactor ?? this.textScaleFactor,
        textWidthBasis: textWidthBasis ?? this.textWidthBasis,
        textHeightBehavior: textHeightBehavior ?? this.textHeightBehavior,
      );
}

extension _TextFieldExt on TextField {
  TextField copy(
          {TextEditingController? controller,
          FocusNode? focusNode,
          InputDecoration? decoration,
          TextInputType? keyboardType,
          TextInputAction? textInputAction,
          TextCapitalization? textCapitalization,
          TextStyle? style,
          StrutStyle? strutStyle,
          TextAlign? textAlign,
          TextAlignVertical? textAlignVertical,
          TextDirection? textDirection,
          bool? readOnly,
          ToolbarOptions? toolbarOptions,
          bool? showCursor,
          bool? autofocus,
          String? obscuringCharacter,
          bool? obscureText,
          bool? autocorrect,
          SmartDashesType? smartDashesType,
          SmartQuotesType? smartQuotesType,
          bool? enableSuggestions,
          int? maxLines,
          int? minLines,
          bool? expands,
          int? maxLength,
          bool? maxLengthEnforced,
          void Function(String)? onChanged,
          void Function()? onEditingComplete,
          void Function(String)? onSubmitted,
          void Function(String, Map<String, dynamic>)? onAppPrivateCommand,
          List<TextInputFormatter>? inputFormatters,
          bool? enabled,
          double? cursorWidth,
          double? cursorHeight,
          Radius? cursorRadius,
          Color? cursorColor,
          ui.BoxHeightStyle? selectionHeightStyle,
          ui.BoxWidthStyle? selectionWidthStyle,
          Brightness? keyboardAppearance,
          EdgeInsets? scrollPadding,
          DragStartBehavior? dragStartBehavior,
          bool? enableInteractiveSelection,
          TextSelectionControls? selectionControls,
          void Function()? onTap,
          MouseCursor? mouseCursor,
          InputCounterWidgetBuilder? buildCounter,
          ScrollController? scrollController,
          ScrollPhysics? scrollPhysics,
          Iterable<String>? autofillHints,
          String? restorationId}) =>
      TextField(
        controller: controller ?? this.controller,
        focusNode: focusNode ?? this.focusNode,
        decoration: decoration ?? this.decoration,
        keyboardType: keyboardType ?? this.keyboardType,
        textInputAction: textInputAction ?? this.textInputAction,
        textCapitalization: textCapitalization ?? this.textCapitalization,
        style: style ?? this.style,
        strutStyle: strutStyle ?? this.strutStyle,
        textAlign: textAlign ?? this.textAlign,
        textAlignVertical: textAlignVertical ?? this.textAlignVertical,
        textDirection: textDirection ?? this.textDirection,
        readOnly: readOnly ?? this.readOnly,
        toolbarOptions: toolbarOptions ?? this.toolbarOptions,
        showCursor: showCursor ?? this.showCursor,
        autofocus: autofocus ?? this.autofocus,
        obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
        obscureText: obscureText ?? this.obscureText,
        autocorrect: autocorrect ?? this.autocorrect,
        smartDashesType: smartDashesType ?? this.smartDashesType,
        smartQuotesType: smartQuotesType ?? this.smartQuotesType,
        enableSuggestions: enableSuggestions ?? this.enableSuggestions,
        maxLines: maxLines ?? this.maxLines,
        minLines: minLines ?? this.minLines,
        expands: expands ?? this.expands,
        maxLength: maxLength ?? this.maxLength,
        maxLengthEnforced: maxLengthEnforced ?? this.maxLengthEnforced,
        onChanged: onChanged ?? this.onChanged,
        onEditingComplete: onEditingComplete ?? this.onEditingComplete,
        onSubmitted: onSubmitted ?? this.onSubmitted,
        onAppPrivateCommand: onAppPrivateCommand ?? this.onAppPrivateCommand,
        inputFormatters: inputFormatters ?? this.inputFormatters,
        enabled: enabled ?? this.enabled,
        cursorWidth: cursorWidth ?? this.cursorWidth,
        cursorHeight: cursorHeight ?? this.cursorHeight,
        cursorRadius: cursorRadius ?? this.cursorRadius,
        cursorColor: cursorColor ?? this.cursorColor,
        selectionHeightStyle: selectionHeightStyle ?? this.selectionHeightStyle,
        selectionWidthStyle: selectionWidthStyle ?? this.selectionWidthStyle,
        keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
        scrollPadding: scrollPadding ?? this.scrollPadding,
        dragStartBehavior: dragStartBehavior ?? this.dragStartBehavior,
        enableInteractiveSelection:
            enableInteractiveSelection ?? this.enableInteractiveSelection,
        selectionControls: selectionControls ?? this.selectionControls,
        onTap: onTap ?? this.onTap,
        mouseCursor: mouseCursor ?? this.mouseCursor,
        buildCounter: buildCounter ?? this.buildCounter,
        scrollController: scrollController ?? this.scrollController,
        scrollPhysics: scrollPhysics ?? this.scrollPhysics,
        autofillHints: autofillHints ?? this.autofillHints,
        restorationId: restorationId ?? this.restorationId,
      );
}

extension TabBarExt on TabBar {
  TabBar copy({
    List<Widget>? tabs,
    TabController? controller,
    bool? isScrollable,
    Color? indicatorColor,
    double? indicatorWeight,
    EdgeInsetsGeometry? indicatorPadding,
    Decoration? indicator,
    TabBarIndicatorSize? indicatorSize,
    Color? labelColor,
    TextStyle? labelStyle,
    EdgeInsetsGeometry? labelPadding,
    Color? unselectedLabelColor,
    TextStyle? unselectedLabelStyle,
    DragStartBehavior? dragStartBehavior,
    MaterialStateProperty<Color?>? overlayColor,
    MouseCursor? mouseCursor,
    bool? enableFeedback,
    ValueChanged<int>? onTap,
    ScrollPhysics? physics,
  }) =>
      TabBar(
        tabs: tabs ?? this.tabs,
        controller: controller ?? this.controller,
        isScrollable: isScrollable ?? this.isScrollable,
        indicatorColor: indicatorColor ?? this.indicatorColor,
        indicatorWeight: indicatorWeight ?? this.indicatorWeight,
        indicatorPadding: indicatorPadding ?? this.indicatorPadding,
        indicator: indicator ?? this.indicator,
        indicatorSize: indicatorSize ?? this.indicatorSize,
        labelColor: labelColor ?? this.labelColor,
        labelStyle: labelStyle ?? this.labelStyle,
        labelPadding: labelPadding ?? this.labelPadding,
        unselectedLabelColor: unselectedLabelColor ?? this.unselectedLabelColor,
        unselectedLabelStyle: unselectedLabelStyle ?? this.unselectedLabelStyle,
        dragStartBehavior: dragStartBehavior ?? this.dragStartBehavior,
        overlayColor: overlayColor ?? this.overlayColor,
        mouseCursor: mouseCursor ?? this.mouseCursor,
        enableFeedback: enableFeedback ?? this.enableFeedback,
        onTap: onTap ?? this.onTap,
        physics: physics ?? this.physics,
      );
}

Map<Type, _StyleComponent> _merge(Iterable<DeclarationGroup> groups) {
  return groups.fold(<Type, _StyleComponent>{},
      (Map<Type, _StyleComponent> previousValue, group) {
    group.declarations.whereType<Declaration>().forEach((declaration) {
      var type = _StyleComponent.typeOf(declaration);
      if (type != null) {
        var component = previousValue.putIfAbsent(
            type, () => _StyleComponent.create(type)!);
        component.merge(declaration, basePath: group.basePath);
      }
    });
    return previousValue;
  });
}

extension StyleExt on Widget {
  Widget styled(dynamic selectors, {int index = -1}) {
    if (selectors is String) {
      var section = _SelectorSection(sections: [selectors], index: index);
      return this is PreferredSizeWidget
          ? _PreferredSizeStyle(
              sizeProvider: () => (this as PreferredSizeWidget).preferredSize,
              selector: section,
              builder: (context) => this,
            )
          : _Style(
              selector: section,
              builder: (context) => this,
            );
    }
    if (selectors is List) {
      var section =
          _SelectorSection(sections: selectors as List<String>, index: index);
      return this is PreferredSizeWidget
          ? _PreferredSizeStyle(
              sizeProvider: () => (this as PreferredSizeWidget).preferredSize,
              selector: section,
              builder: (context) => this,
            )
          : _Style(
              selector: section,
              builder: (context) => this,
            );
    }
    return this;
  }
}

enum TextStyleType {
  HEAD1,
  HEAD2,
  HEAD3,
  HEAD4,
  HEAD5,
  HEAD6,
  SUBTITLE1,
  SUBTITLE2,
  BODY1,
  BODY2,
  CAPTION,
  BUTTON,
  OVERLINE,
}

extension BuildContextExt on BuildContext {
  Widget? styledText(dynamic selectors,
      {int index = -1,
      TextStyleType defaultStyleType = TextStyleType.BODY1,
      required Widget Function(
              BuildContext context, TextStyle? textStyle, TextAlign? textAlign)
          builder}) {
    var defaultTextStyle = _textStyleFromType(defaultStyleType);
    if (selectors is String) {
      var section = _SelectorSection(sections: [selectors], index: index);
      return _TextStyleWrapper(
        selector: section,
        defaultStyle: defaultTextStyle,
        builder: builder,
      );
    }
    if (selectors is List) {
      var section =
          _SelectorSection(sections: selectors as List<String>, index: index);
      return _TextStyleWrapper(
        selector: section,
        defaultStyle: defaultTextStyle,
        builder: builder,
      );
    }
    return null;
  }

  TextStyle? _textStyleFromType(TextStyleType? type) {
    var textTheme = Theme.of(this).textTheme;
    switch (type) {
      case TextStyleType.BODY1:
        return textTheme.bodyText1;
      case TextStyleType.BODY2:
        return textTheme.bodyText2;
      case TextStyleType.HEAD1:
        return textTheme.headline1;
      case TextStyleType.HEAD2:
        return textTheme.headline2;
      case TextStyleType.HEAD3:
        return textTheme.headline3;
      case TextStyleType.HEAD4:
        return textTheme.headline4;
      case TextStyleType.HEAD5:
        return textTheme.headline5;
      case TextStyleType.HEAD6:
        return textTheme.headline6;
      case TextStyleType.SUBTITLE1:
        return textTheme.subtitle1;
      case TextStyleType.SUBTITLE2:
        return textTheme.subtitle2;
      case TextStyleType.CAPTION:
        return textTheme.caption;
      case TextStyleType.BUTTON:
        return textTheme.button;
      case TextStyleType.OVERLINE:
        return textTheme.overline;
      default:
        return textTheme.bodyText1;
    }
  }
}

extension UriExt on Uri {
  Uri? toAbsolute({String basePath = ''}) {
    switch (scheme) {
      case 'http':
      case 'https':
      case 'file':
      case 'asset':
        return this;
      default:
        return Uri.tryParse('$basePath/${toString()}');
    }
  }

  ImageProvider? toImage() {
    ImageProvider? provider;
    switch (scheme) {
      case 'http':
      case 'https':
        if (path.toLowerCase().endsWith('.svg')) {
          provider = Svg.network(toString());
        } else {
          provider = NetworkImage(toString());
        }
        break;
      case 'file':
        if (path.toLowerCase().endsWith('.svg')) {
          provider = Svg.file(toFilePath());
        } else {
          provider = FileImage(File(toFilePath()));
        }
        break;
      case 'asset':
        if (path.toLowerCase().endsWith('.svg')) {
          provider = Svg.asset(toString().substring(8));
        } else {
          provider = AssetImage(toString().substring(8));
        }
        break;
    }
    return provider;
  }

  double getScale() {
    final fileName = path.split('/').lastOrNull;
    if (fileName == null) return Dimens.pixelRatio;
    final atIndex = fileName.lastIndexOf('@');
    if (atIndex < 0) return Dimens.pixelRatio;
    final sub = fileName.substring(atIndex).split('\.').firstOrNull;
    switch (sub) {
      case '@1x':
        return 1;
      case '@2x':
        return 2;
      case '@3x':
        return 3;
      default:
        return Dimens.pixelRatio;
    }
  }
}
