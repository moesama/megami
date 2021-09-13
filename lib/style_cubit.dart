part of megami;

class CssBundle {
  final String key;
  final String path;

  const CssBundle(this.key, this.path);

  String get basePath => path.substring(0, path.lastIndexOf('/'));

  Future<String> get stylesheet {
    var uri = Uri.parse(path);
    switch (uri.scheme) {
      case 'file':
        return File(uri.toFilePath()).readAsString();
      case 'asset':
        return rootBundle.loadString(uri.toString().substring(8));
      default:
        return Future.error('css file $path not found.');
    }
  }
}

class StyleCubit extends Cubit<List<StyleSheet>> {
  StyleCubit({List<StyleSheet> state = const []}) : super(state);

  Future addStyle(String key, String style, {String basePath = ''}) async {
    final list = await _addStyle(key, style, origin: state, basePath: basePath);
    _notifyChanged(list);
  }

  void removeStyle(String key) {
    final list = state.toList(growable: true);
    list.removeWhere((element) => element.key == key);
    _notifyChanged(list);
  }

  void addCss(CssBundle bundle) {
    bundle.stylesheet.then((value) {
      addStyle(bundle.key, value, basePath: bundle.basePath);
    });
  }

  Future setCss(List<CssBundle> bundles) async {
    var origin = <StyleSheet>[];
    await Future.wait(bundles.map((e) => e.stylesheet.then((value) async {
      origin.addAll(await _addStyle(e.key, value, origin: origin, basePath: e.basePath));
    }))).then((value) {
      if (value.isNotEmpty) {
        _notifyChanged(origin);
      }
    });
  }

  Future<List<StyleSheet>> _addStyle(String key, String style, {List<StyleSheet>? origin, String basePath = ''}) async {
    final stylesheet = await compute(parse, style);
    stylesheet
      ..basePath = basePath
      ..key = key;
    final list = origin?.toList(growable: true) ?? [];
    list.add(stylesheet);
    stylesheet.ruleSets.forEach((element) {
      element.declarationGroup.basePath = basePath;
      element.declarationGroup.resolve();
    });
    return list;
  }

  void _notifyChanged(List<StyleSheet> list) {
    // clear component cache
    _SelectorSection.reset();
    emit(list);
  }
}
