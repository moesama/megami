part of megami;

final StyleCubit styleCubit = StyleCubit();

class StyledScaffold extends StatelessWidget {
  final StyleCubit style;
  final WidgetBuilder builder;

  const StyledScaffold({Key key, @required this.builder, this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = style ?? styleCubit;
    return BlocProvider<StyleCubit>(
      create: (BuildContext context) => cubit,
      child: BlocBuilder<StyleCubit, List<StyleSheet>>(
        builder: (context, state) =>
            state == null ? Container() : builder.call(context),
      ),
    );
  }
}

class _ComputedStyle {
  final Map<Selector, DeclarationGroup> matched = {};
  final Map<Type, _StyleComponent> styles = {};
  final Map<PseudoElementSelector, Map<Type, _StyleComponent>> elementStyles =
      {};

  List<_StyleComponent> getComponentsByElements(List<String> elements) =>
      elementStyles.entries
          .where((e) => elements.contains(e.key.name.trim()))
          .map((e) => e.value.values)
          .expand((e) => e)
          .toList();
}

class _SelectorSection {
  _SelectorSection parent;
  final List<String> sections;
  final int index;

  _ComputedStyle _privateStyle;

  static final Map<_SelectorSection, _ComputedStyle> store = {};

  static _ComputedStyle getComputedStyle(_SelectorSection selector) =>
      store.entries
          .firstWhereOrNull((element) => element.key == selector)
          ?.value;

  static _ComputedStyle createComputedStyle(_SelectorSection selector) {
    // use private style store if index is not 0
    if (selector.index >= 0) {
      selector._privateStyle = _ComputedStyle();
      return selector._privateStyle;
    }
    return store.putIfAbsent(selector, () => _ComputedStyle());
  }

  static void reset() {
    store.clear();
  }

  _ComputedStyle get computeStyle => _privateStyle ?? getComputedStyle(this);

  _SelectorSection({this.parent, this.sections, this.index});

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
  final WidgetBuilder builder;

  _Style({Key key, this.builder, this.selector}) : super(key: key);

  void _resolve(BuildContext context) {
    context.visitAncestorElements((element) {
      if (element.widget is _Style) {
        selector.parent = (element.widget as _Style).selector;
        return false;
      }
      return true;
    });
  }

  Widget _applyStyle(BuildContext context, Widget child) {
    var res = child;
    if (child is TabBar) {
      res = _StyleComponent.decorateTabIndicator(context, res,
          components: selector.computeStyle
              ?.getComponentsByElements(['tab-indicator']));
      res = _StyleComponent.decorateTabControl(context, res,
          components:
              selector.computeStyle?.getComponentsByElements(['tab-control']));
      res = _StyleComponent.decorateTabControl(context, res,
          selected: true,
          components: selector.computeStyle
              ?.getComponentsByElements(['tab-control-selected']));
    }
    return _StyleComponent.decorate(context, res,
        components: selector.computeStyle?.styles?.values);
  }

  @override
  Widget build(BuildContext context) {
    _resolve(context);
    return BlocBuilder<StyleCubit, List<StyleSheet>>(
        builder: (BuildContext context, List<StyleSheet> state) {
      if (state != null && state.isNotEmpty) {
        resolve(state);
        var child = builder.call(context);
        return _applyStyle(context, child);
      }
      return builder.call(context);
    });
  }

  void resolve(List<StyleSheet> styles,
      {String basePath = '', bool append = false}) {
    var store = _SelectorSection.getComputedStyle(selector);
    if (store == null) {
      store = _SelectorSection.createComputedStyle(selector);
      styles.forEach((stylesheet) {
        stylesheet.ruleSets.forEach((ruleSet) {
          var matched = ruleSet.selectorGroup.selectors
              .where((element) => element.match(selector));
          matched.forEach((element) {
            store.matched[element] = ruleSet.declarationGroup;
          });
        });
        var sortedEntries =
            store.matched.entries.where((e) => !e.key.isElement).toList();
        sortedEntries.sort((a, b) => a.key.weight.compareTo(b.key.weight));
        store.styles.clear();
        store.styles.addAll(
            _merge(sortedEntries.map((e) => e.value), basePath: basePath));
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
          store.elementStyles[key] = _merge(value, basePath: basePath);
        });
      });
    }
  }
}

class _PreferredSizeStyle extends _Style implements PreferredSizeWidget {
  final Size Function() sizeProvider;

  _PreferredSizeStyle({
    Key key,
    @required this.sizeProvider,
    WidgetBuilder builder,
    _SelectorSection selector,
  }) : super(key: key, builder: builder, selector: selector);

  @override
  Size get preferredSize => sizeProvider();
}

class _TextStyleWrapper extends StatelessWidget {
  final Widget Function(
      BuildContext context, TextStyle textStyle, TextAlign textAlign) builder;
  final _SelectorSection selector;
  final TextStyle defaultStyle;

  _TextStyleWrapper({Key key, this.builder, this.defaultStyle, this.selector})
      : super(key: key);

  @override
  Widget build(BuildContext context) => _Style(
        selector: selector,
        builder: (context) => _StyleComponent.decorateText(context, this,
            components: selector.computeStyle?.styles?.values),
      );
}
