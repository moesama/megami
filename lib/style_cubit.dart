part of megami;

class StyleCubit extends Cubit<StyleSheet> {
  StyleCubit({StyleSheet state}) : super(state);

  void setStyle(String style) {
    var stylesheet = parse(style);
    // var exps = ((stylesheet.topLevels.first as RuleSet).declarationGroup.declarations.first as Declaration).expression.expressions;
    // var term = (exps.first as FunctionTerm).params.expressions;
    // print(term.toDebugString());
    emit(stylesheet);
  }

  void setCss(String path) async {
    var uri = Uri.parse(path);
    switch (uri.scheme) {
      case 'file':
        final stylesheet = await File(uri.toFilePath()).readAsString();
        setStyle(stylesheet);
        break;
      case 'asset':
        final stylesheet = await rootBundle.loadString(uri.toString().substring(8));
        setStyle(stylesheet);
        break;
    }
  }
}