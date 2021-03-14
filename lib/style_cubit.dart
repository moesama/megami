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

  void addStyle(String key, String style, {String basePath = ''}) {
    final list = _addStyle(key, style, origin: state, basePath: basePath);
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

  void setCss(List<CssBundle> bundles) {
    var origin = <StyleSheet>[];
    Future.wait(bundles.map((e) => e.stylesheet.then((value) {
      origin = _addStyle(e.key, value, origin: origin, basePath: e.basePath);
    }))).then((value) {
      if (value.isNotEmpty) {
        _notifyChanged(origin);
      }
    });
  }

  List<StyleSheet> _addStyle(String key, String style, {List<StyleSheet>? origin, String basePath = ''}) {
    final stylesheet = parse(style)
      ..basePath = basePath
      ..key = key;
    final list = origin?.toList(growable: true) ?? [];
    list.add(stylesheet);
    return list;
  }

  void _notifyChanged(List<StyleSheet> list) {
    // clear component cache
    _SelectorSection.reset();
    emit(list);
  }
}
