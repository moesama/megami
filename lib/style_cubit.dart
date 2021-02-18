import 'css/parser.dart';
import 'css/visitor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StyleCubit extends Cubit<StyleSheet> {
  StyleCubit({StyleSheet state}) : super(state);

  void setStyle(String style) {
    var stylesheet = parse(style);
    // var exps = ((stylesheet.topLevels.first as RuleSet).declarationGroup.declarations.first as Declaration).expression.expressions;
    // var term = (exps.first as FunctionTerm).params.expressions;
    // print(term.toDebugString());
    emit(stylesheet);
  }
}