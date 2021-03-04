part of megami;

class StyleCubit extends Cubit<List<StyleSheet>> {
  StyleCubit({List<StyleSheet> state}) : super(state);

  void addStyle(String key, String style, {String basePath = ''}) {
    final stylesheet = parse(style)
      ..basePath = basePath
      ..key = key;
    final list = state?.toList(growable: true) ?? [];
    list.add(stylesheet);
    emit(list);
  }

  void removeStyle(String key) {
    final list = state?.toList(growable: true);
    list?.removeWhere((element) => element.key == key);
    emit(list);
  }

  void addCss(String key, String path) async {
    var uri = Uri.parse(path);
    final basePath = path.substring(0, path.lastIndexOf('/'));
    switch (uri.scheme) {
      case 'file':
        final stylesheet = await File(uri.toFilePath()).readAsString();
        addStyle(key, stylesheet, basePath: basePath);
        break;
      case 'asset':
        final stylesheet =
            await rootBundle.loadString(uri.toString().substring(8));
        addStyle(key, stylesheet, basePath: basePath);
        break;
    }
  }
}
