part of megami;

final StyleCubit styleCubit = StyleCubit();

class StyledScaffold extends StatelessWidget {
  final StyleCubit? style;
  final WidgetBuilder builder;
  final Widget? placeholder;

  const StyledScaffold(
      {Key? key, required this.builder, this.style, this.placeholder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = style ?? styleCubit;
    return BlocProvider<StyleCubit>(
      create: (BuildContext context) => cubit,
      child: BlocBuilder<StyleCubit, List<StyleSheet>>(
        builder: (context, state) =>
            state.isEmpty ? placeholder ?? Container() : builder.call(context),
      ),
    );
  }
}

class _ComputedStyle {
  final Map<Selector, DeclarationGroup> matched = {};
  final Map<Type, StyleComponent> styles = {};
  final Map<PseudoElementSelector, Map<Type, StyleComponent>> elementStyles =
      {};

  List<StyleComponent> getComponentsByElements(List<String> elements) =>
      elementStyles.entries
          .where((e) => elements.contains(e.key.name.trim()))
          .map((e) => e.value.values)
          .expand((e) => e)
          .toList();
}

class _SelectorSection {
  _SelectorSection? parent;
  final List<String> sections;
  final int index;

  _ComputedStyle? _privateStyle;

  static final Map<_SelectorSection, _ComputedStyle> store = {};

  static _ComputedStyle? getComputedStyle(_SelectorSection selector) =>
      store.entries
          .firstWhereOrNull((element) => element.key == selector)
          ?.value;

  static _ComputedStyle createComputedStyle(_SelectorSection selector) {
    var style = _ComputedStyle();
    store[selector.copy()] = style;
    return style;
  }

  static void reset() {
    store.clear();
  }

  _ComputedStyle? get computeStyle => _privateStyle ?? getComputedStyle(this);

  _SelectorSection({this.parent, required List<String> sections, this.index = -1})
      : sections = sections.toList(growable: true) {
    this.sections.sort((a, b) => a.compareTo(b));
  }

  _SelectorSection copy(
      {_SelectorSection? parent, List<String>? sections, int? index}) =>
      _SelectorSection(
        parent: parent?.copy() ?? this.parent?.copy(),
        sections: sections ?? this.sections.toList(),
        index: index ?? this.index,
      );

  @override
  String toString() {
    return 'SelectorSection: $sections , index: $index';
  }

  @override
  bool operator ==(Object other) {
    var res = super == other;
    if (!res && other is _SelectorSection) {
      return parent == other.parent &&
          index == other.index &&
          ListEquality<String>().equals(sections, other.sections);
    }
    return res;
  }
}

class _Style extends StatelessWidget {
  final _SelectorSection selector;
  final Widget? child;
  final WidgetBuilder? builder;

  _Style({Key? key, this.child, this.builder, required this.selector})
      : super(key: key) {
    assert(child != null || builder != null);
  }

  static void _resolve(_SelectorSection selector, List<StyleSheet> styles) {
    var store = _SelectorSection.getComputedStyle(selector);
    if (store == null) {
      store = _SelectorSection.createComputedStyle(selector);
      styles.forEach((stylesheet) {
        stylesheet.ruleSets.forEach((ruleSet) {
          var matched = ruleSet.selectorGroup.selectors
              .where((s) => s.match(selector));
          matched.forEach((selector) {
            store!.matched[selector] = ruleSet.declarationGroup;
          });
        });
      });

      var sortedEntries =
      store.matched.entries.where((e) => !e.key.isElement).toList();
      sortedEntries.sort((a, b) => a.key.weight.compareTo(b.key.weight));
      store.styles.clear();
      store.styles.addAll(_merge(sortedEntries.map((e) => e.value)));
      sortedEntries =
          store.matched.entries.where((e) => e.key.isElement).toList();
      sortedEntries.sort((a, b) => a.key.weight.compareTo(b.key.weight));
      store.elementStyles.clear();
      final elements = {
        for (var e in sortedEntries)
          e.key.simpleSelectorSequences.last.simpleSelector
          as PseudoElementSelector:
          sortedEntries
              .where((element) => element.key == e.key)
              .map((e) => e.value)
              .toList()
      };
      elements.forEach((key, value) {
        store!.elementStyles[key] = _merge(value);
      });
    }
  }

  Widget _applyStyle(
      BuildContext context, Widget child, _ComputedStyle? style) {
    var res = child;
    if (child is TabBar) {
      res = StyleComponent.decorateTabIndicator(context, res as TabBar,
          components: style?.getComponentsByElements(['tab-indicator']));
      res = StyleComponent.decorateTabControl(context, res,
          components: style?.getComponentsByElements(['tab-control']));
      res = StyleComponent.decorateTabControl(context, res,
          selected: true,
          components: style?.getComponentsByElements(['tab-control-selected']));
    }
    // if (child is TextField) {
    //   res = _StyleComponent.decorateTextFieldHint(context, res,
    //       components: selector.computeStyle
    //           ?.getComponentsByElements(['hint']));
    // }
    return StyleComponent.decorate(context, res,
        components: style?.styles.values);
  }

  @override
  Widget build(BuildContext context) {
    context._resolveTree(selector);
    return BlocBuilder<StyleCubit, List<StyleSheet>>(
        builder: (BuildContext context, List<StyleSheet> state) {
      if (state.isNotEmpty) {
        _resolve(selector, state);
        return _applyStyle(context, builder?.call(context) ?? child!, selector.computeStyle);
      }
      return builder?.call(context) ?? child ?? Container();
    });
  }
}

class _PreferredSizeStyle extends _Style implements PreferredSizeWidget {
  final Size Function() sizeProvider;

  _PreferredSizeStyle({
    Key? key,
    required this.sizeProvider,
    required Widget child,
    required _SelectorSection selector,
  }) : super(key: key, child: child, selector: selector);

  @override
  Size get preferredSize => sizeProvider();
}

class _TextStyleWrapper extends StatelessWidget {
  final Widget Function(
      BuildContext context, TextStyle? textStyle, TextAlign? textAlign) builder;
  final _SelectorSection selector;
  final TextStyle? defaultStyle;

  _TextStyleWrapper(
      {Key? key,
      required this.builder,
      required this.selector,
      this.defaultStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _Style(
        selector: selector,
        builder: (context) => StyleComponent.decorateText(context, this,
            components: selector.computeStyle?.styles.values),
      );
}
