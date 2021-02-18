import 'css/visitor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'style_components.dart';
import 'style_cubit.dart';
import 'style_exts.dart';

final StyleCubit styleCubit = StyleCubit();

class StyledScaffold extends StatelessWidget {
  final WidgetBuilder builder;

  const StyledScaffold({Key key, @required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocProvider<StyleCubit>(
        create: (BuildContext context) => styleCubit,
        child: builder.call(context),
      );
}

class SelectorSection {
  SelectorSection parent;
  final Map<Selector, DeclarationGroup> matched = {};
  final Map<Type, StyleComponent> computeStyle = {};
  final List<String> sections;
  final int index;

  SelectorSection({this.sections, this.index});

  @override
  String toString() {
    return 'SelectorSection: $sections , index: $index';
  }
}

class Style extends StatelessWidget {
  final SelectorSection selector;
  final WidgetBuilder builder;

  Style({Key key, this.builder, this.selector}) : super(key: key);

  void _resolve(BuildContext context) {
    context.visitAncestorElements((element) {
      if (element.widget is Style) {
        selector.parent = (element.widget as Style).selector;
        return false;
      }
      return true;
    });
  }

  Widget _applyStyle(
      BuildContext context, StyleSheet stylesheet, Widget child) {
    var widget = child;
    widget =
        StyleComponent.decorate(context, widget, selector.computeStyle.values);
    return widget;
  }

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

