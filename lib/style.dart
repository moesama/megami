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
      child: BlocBuilder<StyleCubit, StyleSheet>(
        builder: (context, state) => state == null ? Container() : builder.call(context),
      ),
    );
  }
}

class _ComputedStyle {
  final Map<Selector, DeclarationGroup> matched = {};
  final Map<Type, _StyleComponent> styles = {};
}

class _SelectorSection {
  _SelectorSection parent;
  final List<String> sections;
  final int index;

  _ComputedStyle _privateStyle;

  static final Map<_SelectorSection, _ComputedStyle> store = {};

  static _ComputedStyle getComputedStyle(_SelectorSection selector) =>
      store.entries.firstWhereOrNull((element) => element.key == selector)?.value;

  static _ComputedStyle createComputedStyle(_SelectorSection selector) {
    // use private style store if index is not 0
    if (selector.index != 0) {
      selector._privateStyle = _ComputedStyle();
      return selector._privateStyle;
    }
    return store.putIfAbsent(selector, () => _ComputedStyle());
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

  Widget _applyStyle(
          BuildContext context, StyleSheet stylesheet, Widget child) =>
      _StyleComponent.decorate(context, child,
          components: selector.computeStyle?.styles?.values);

  @override
  Widget build(BuildContext context) {
    _resolve(context);
    return BlocBuilder<StyleCubit, StyleSheet>(
        builder: (BuildContext context, StyleSheet state) {
      if (state != null) {
        state.resolve(selector);
        var child = builder.call(context);
        return _applyStyle(context, state, child);
      }
      return builder.call(context);
    });
  }
}

class _TextStyleWrapper extends StatelessWidget {
  final Widget Function(
      BuildContext context, TextStyle textStyle, TextAlign textAlign) builder;
  final _SelectorSection selector;
  final TextStyle defaultStyle;

  _TextStyleWrapper({Key key, this.builder, this.defaultStyle, this.selector})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _Style(
      selector: selector,
      builder: (context) {
        return _StyleComponent.decorateText(context, this,
            components: selector.computeStyle?.styles?.values);
      },
    );
  }
}
