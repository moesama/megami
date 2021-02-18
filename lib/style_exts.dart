import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'css/visitor.dart';
import 'package:flutter/material.dart';

import 'style.dart';
import 'style_components.dart';

extension StyleSheetExt on StyleSheet {
  void resolve(SelectorSection selector) {
    ruleSets.forEach((ruleSet) {
      var matched = ruleSet.selectorGroup.match(selector);
      matched.forEach((element) {
        selector.matched[element] = ruleSet.declarationGroup;
      });
    });
    selector.computeStyle.clear();
    selector.computeStyle.addAll(merge(selector.matched.values.toList()));
  }
}

extension SelectorGroupExt on SelectorGroup {
  Iterable<Selector> match(SelectorSection selector) {
    return selectors.where((element) {
      return element.match(selector);
    });
  }
}

extension SelectorExt on Selector {
  bool match(SelectorSection selector) {
    var strict = true;
    var matched = simpleSelectorSequences.reversed.fold(selector,
        (previousValue, element) {
      var matched = element.match(previousValue);
      var res = strict ? matched : matched ?? previousValue;
      strict = element.isCombinatorGreater;
      return res;
    });
    return matched != null;
  }
}

extension SelectorSequenceExt on SimpleSelectorSequence {
  SelectorSection match(SelectorSection selector) {
    var matched = selector?.sections
            ?.any((element) => simpleSelector.match(element, selector.index)) ??
        false;
    if ((isCombinatorGreater || isCombinatorDescendant) && matched) {
      return selector.parent;
    }
    if (isCombinatorPlus && matched) {
      return selector.index > 0 ? selector : null;
    }
    return matched ? selector : null;
  }
}

extension SimpleSelectorExt on SimpleSelector {
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
      default:
        return false;
    }
  }
}

extension PseudoClassSelectorExt on PseudoClassSelector {
  bool match(String selector, int index) {
    switch (name) {
      case 'first-child':
        return index == 0;
    }
    return false;
  }
}

extension PseudoClassFunctionSelectorExt on PseudoClassFunctionSelector {
  bool match(String selector, int index) {
    switch (name) {
      case 'nth-child':
        if (expression.expressions.isEmpty) {
          return false;
        } else {
          return (expression.expressions.first as LiteralTerm).value ==
              index + 1;
        }
    }
    return false;
  }
}

extension ExpressionExt on Expression {
  num get asNum {
    if (this is NumberTerm) {
      return (this as NumberTerm).value;
    }
    return 0;
  }

  int get asInt => asNum.toInt();

  double get asDouble => asNum.toDouble();
}

extension TextExt on Text {
  Text copy({
    String data,
    TextStyle style,
    StrutStyle strutStyle,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    TextWidthBasis textWidthBasis,
    TextHeightBehavior textHeightBehavior,
  }) =>
      Text(
        data ?? this.data,
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

extension TextFieldExt on TextField {
  TextField copy(
          {TextEditingController controller,
          FocusNode focusNode,
          InputDecoration decoration = const InputDecoration(),
          TextInputType keyboardType,
          TextInputAction textInputAction,
          TextCapitalization textCapitalization = TextCapitalization.none,
          TextStyle style,
          StrutStyle strutStyle,
          TextAlign textAlign = TextAlign.start,
          TextAlignVertical textAlignVertical,
          TextDirection textDirection,
          bool readOnly = false,
          ToolbarOptions toolbarOptions,
          bool showCursor,
          bool autofocus = false,
          String obscuringCharacter = '•',
          bool obscureText = false,
          bool autocorrect = true,
          SmartDashesType smartDashesType,
          SmartQuotesType smartQuotesType,
          bool enableSuggestions = true,
          int maxLines = 1,
          int minLines,
          bool expands = false,
          int maxLength,
          bool maxLengthEnforced = true,
          MaxLengthEnforcement maxLengthEnforcement,
          void Function(String) onChanged,
          void Function() onEditingComplete,
          void Function(String) onSubmitted,
          void Function(String, Map<String, dynamic>) onAppPrivateCommand,
          List<TextInputFormatter> inputFormatters,
          bool enabled,
          double cursorWidth = 2.0,
          double cursorHeight,
          Radius cursorRadius,
          Color cursorColor,
          ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
          ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
          Brightness keyboardAppearance,
          EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
          DragStartBehavior dragStartBehavior = DragStartBehavior.start,
          bool enableInteractiveSelection = true,
          TextSelectionControls selectionControls,
          void Function() onTap,
          MouseCursor mouseCursor,
          Widget Function(BuildContext,
                  {int currentLength, bool isFocused, int maxLength})
              buildCounter,
          ScrollController scrollController,
          ScrollPhysics scrollPhysics,
          Iterable<String> autofillHints,
          String restorationId}) =>
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
        maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
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

Map<Type, StyleComponent> merge(List<DeclarationGroup> groups) {
  return groups.fold(<Type, StyleComponent>{},
      (Map<Type, StyleComponent> previousValue, group) {
    group.declarations.map((e) => e as Declaration).forEach((declaration) {
      var type = StyleComponent.typeOf(declaration);
      if (type != null) {
        var component =
            previousValue.putIfAbsent(type, () => StyleComponent.create(type));
        component.merge(declaration);
      }
    });
    return previousValue;
  });
}

extension StyleExt on Widget {
  Widget styled(dynamic selectors, {int index = 0}) {
    if (selectors is String) {
      var section = SelectorSection(sections: [selectors], index: index);
      return Style(
        selector: section,
        builder: (context) => this,
      );
    }
    if (selectors is List) {
      var section = SelectorSection(sections: selectors, index: index);
      return Style(
        selector: section,
        builder: (context) => this,
      );
    }
    return this;
  }
}
