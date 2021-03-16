part of megami;

enum SvgSource { network, asset, file }

/// Rasterizes given svg picture for displaying in [Image] widget:
///
/// ```dart
/// Image(
///   width: 32,
///   height: 32,
///   image: Svg('assets/my_icon.svg', source: SvgSource.asset),
/// )
/// ```
class Svg extends ImageProvider<SvgImageKey> {
  /// Path to svg file asset
  final String path;

  final SvgSource source;

  /// Size in logical pixels to render.
  /// Useful for [DecorationImage].
  /// If not specified, will use size from [Image].
  /// If [Image] not specifies size too, will use default size 100x100.
  final Size size; // nullable

  /// The [ColorFilter], if any, to apply to the drawing.
  final ColorFilter colorFilter;

  /// Width and height can also be specified from [Image] constrictor.
  /// Default size is 100x100 logical pixels.
  /// Different size can be specified in [Image] parameters
  const Svg(this.path,
      {this.source = SvgSource.asset, this.size, this.colorFilter})
      : assert(path != null);

  @override
  Future<SvgImageKey> obtainKey(ImageConfiguration configuration) {
    final logicWidth = size?.width ?? configuration.size?.width ?? 100;
    final logicHeight = size?.height ?? configuration.size?.width ?? 100;
    final scale = configuration.devicePixelRatio ?? 1.0;

    return SynchronousFuture<SvgImageKey>(
      SvgImageKey(
        path: path,
        pixelWidth: (logicWidth * scale).round(),
        pixelHeight: (logicHeight * scale).round(),
        scale: scale,
        colorFilter: colorFilter,
      ),
    );
  }

  @override
  ImageStreamCompleter load(SvgImageKey key, nil) {
    Future<ImageInfo> image;
    switch (source) {
      case SvgSource.network:
        image = _loadNetworkAsync(key);
        break;
      case SvgSource.file:
        image = _loadFileAsync(key);
        break;
      default:
        image = _loadAssetAsync(key);
        break;
    }
    return OneFrameImageStreamCompleter(image);
  }

  static Future<ImageInfo> _loadNetworkAsync(SvgImageKey key) async {
    final bytes = await _httpGet(key.path);
    final svgRoot = await svg.fromSvgBytes(bytes, key.path);
    return _loadAsync(key, svgRoot);
  }

  static Future<ImageInfo> _loadAssetAsync(SvgImageKey key) async {
    final rawSvg = await rootBundle.loadString(key.path);
    final svgRoot = await svg.fromSvgString(rawSvg, key.path);
    return _loadAsync(key, svgRoot);
  }

  static Future<ImageInfo> _loadFileAsync(SvgImageKey key) async {
    final rawSvg = await File(key.path).readAsString();
    final svgRoot = await svg.fromSvgString(rawSvg, key.path);
    return _loadAsync(key, svgRoot);
  }

  static Future<ImageInfo> _loadAsync(
      SvgImageKey key, DrawableRoot svgRoot) async {
    if (svgRoot.viewport.viewBox.isEmpty) {
      throw StateError('Invalid SVG data');
    }
    final scaleX = key.pixelWidth / svgRoot.viewport.viewBox.width;
    final scaleY =
        key.pixelHeight / svgRoot.viewport.viewBox.height;
    final root = DrawableRoot(svgRoot.id, svgRoot.viewport, svgRoot.children,
        svgRoot.definitions, svgRoot.style,
        transform: Matrix4.diagonal3Values(scaleX, scaleY, 1).storage);
    final bounds = svgRoot.viewport.viewBoxOffset.scale(scaleX, scaleY) &
    Size(
      svgRoot.viewport.viewBox.width * scaleX,
      svgRoot.viewport.viewBox.height * scaleY,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, bounds);
    if (key.colorFilter != null) {
      canvas.saveLayer(null, Paint()..colorFilter = key.colorFilter);
    } else {
      canvas.save();
    }
    root.draw(canvas, bounds);
    canvas.restore();
    final image = await recorder.endRecording().toImage(
      key.pixelWidth.toInt(),
      key.pixelHeight.toInt(),
    );
    return ImageInfo(
      image: image,
      scale: key.scale,
    );
  }

  Svg.network(this.path, {this.size, this.colorFilter}): source = SvgSource.network;
  Svg.asset(this.path, {this.size, this.colorFilter}): source = SvgSource.asset;
  Svg.file(this.path, {this.size, this.colorFilter}): source = SvgSource.file;

  // Note: == and hashCode not overrided as changes in properties
  // (width, height and scale) are not observable from the here.
  // [SvgImageKey] instances will be compared instead.

  @override
  String toString() => '$runtimeType(${describeIdentity(path)})';
}

@immutable
class SvgImageKey {
  const SvgImageKey({
    @required this.path,
    @required this.pixelWidth,
    @required this.pixelHeight,
    @required this.scale,
    this.colorFilter,
  })  : assert(path != null),
        assert(pixelWidth != null),
        assert(pixelHeight != null),
        assert(scale != null);

  /// Path to svg asset.
  final String path;

  /// Width in physical pixels.
  /// Used when raterizing.
  final int pixelWidth;

  /// Height in physical pixels.
  /// Used when raterizing.
  final int pixelHeight;

  /// The [ColorFilter], if any, to apply to the drawing.
  final ColorFilter colorFilter;

  /// Used to calculate logical size from physical, i.e.
  /// logicalWidth = [pixelWidth] / [scale],
  /// logicalHeight = [pixelHeight] / [scale].
  /// Should be equal to [MediaQueryData.devicePixelRatio].
  final double scale;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SvgImageKey &&
        other.path == path &&
        other.pixelWidth == pixelWidth &&
        other.pixelHeight == pixelHeight &&
        other.scale == scale &&
        other.colorFilter == colorFilter;
  }

  @override
  int get hashCode =>
      hashValues(path, pixelWidth, pixelHeight, scale, colorFilter);

  @override
  String toString() => '${objectRuntimeType(this, 'SvgImageKey')}'
      '(path: "$path", pixelWidth: $pixelWidth, pixelHeight: $pixelHeight, scale: $scale)';
}

/// Fetches an HTTP resource from the specified [url] using the specified [headers].
Future<Uint8List> _httpGet(String url, {Map<String, String> headers}) async {
  final httpClient = HttpClient();
  final uri = Uri.base.resolve(url);
  final request = await httpClient.getUrl(uri);
  if (headers != null) {
    headers.forEach((String key, String value) {
      request.headers.add(key, value);
    });
  }
  final response = await request.close();

  if (response.statusCode != HttpStatus.ok) {
    throw HttpException('Could not get network asset', uri: uri);
  }
  return consolidateHttpClientResponseBytes(response);
}
