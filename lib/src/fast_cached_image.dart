import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FastCachedImage extends StatefulWidget {
  final String url;
  final ImageErrorWidgetBuilder? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;
  final double? width;
  final double? height;
  final double scale;
  final Color? color;
  final Animation<double>? opacity;
  final FilterQuality filterQuality;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool isAntiAlias;

  const FastCachedImage(
      {required this.url,
      this.scale = 1.0,
      this.errorBuilder,
      this.semanticLabel,
      this.loadingBuilder,
      this.excludeFromSemantics = false,
      this.width,
      this.height,
      this.color,
      this.opacity,
      this.colorBlendMode,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.centerSlice,
      this.matchTextDirection = false,
      this.gaplessPlayback = false,
      this.isAntiAlias = false,
      this.filterQuality = FilterQuality.low,
      int? cacheWidth,
      int? cacheHeight,
      Key? key})
      : super(key: key);

  @override
  State<FastCachedImage> createState() => _FastCachedImageState();
}

class _FastCachedImageState extends State<FastCachedImage> {
  _ImageResponse? imageResponse;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _loadAsync(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (imageResponse == null) {
      return (widget.loadingBuilder != null) ? widget.loadingBuilder!(context) : const SizedBox();
    }
    if (imageResponse!.error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, Object, StackTrace.fromString(imageResponse!.error!));
    }
    return Image.memory(
      imageResponse!.imageData,
      color: widget.color,
      width: widget.width,
      height: widget.height,
      alignment: widget.alignment,
      key: widget.key,
      fit: widget.fit,
      errorBuilder: widget.errorBuilder,
      centerSlice: widget.centerSlice,
      colorBlendMode: widget.colorBlendMode,
      excludeFromSemantics: widget.excludeFromSemantics,
      filterQuality: widget.filterQuality,
      gaplessPlayback: widget.gaplessPlayback,
      isAntiAlias: widget.isAntiAlias,
      matchTextDirection: widget.matchTextDirection,
      opacity: widget.opacity,
      repeat: widget.repeat,
      scale: widget.scale,
      semanticLabel: widget.semanticLabel,
    );
  }

  Future<void> _loadAsync(url) async {
    if (FastCachedImageConfig._box == null || !FastCachedImageConfig._box!.isOpen) {
      throw Exception(
          'FastCachedImage is not initialized. Please use FastCachedImageConfig.init to initialize FastCachedImage');
    }

    Uint8List? image = await FastCachedImageConfig._getImage(url);
    if (image != null) {
      setState(() => imageResponse = _ImageResponse(imageData: image, error: null));
      return;
    }

    StreamController chunkEvents = StreamController();

    try {
      final Uri resolved = Uri.base.resolve(url);
      HttpClient httpClient = HttpClient();

      final HttpClientRequest request = await httpClient.getUrl(resolved);

      // headers?.forEach((String name, String value) {
      //   request.headers.add(name, value);
      // });

      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<List<int>>(<int>[]);
        String error = NetworkImageLoadException(statusCode: response.statusCode, uri: resolved).toString();
        setState(() => imageResponse = _ImageResponse(imageData: Uint8List.fromList([]), error: error));
        return;
      }

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );

      if (bytes.isEmpty) {
        setState(() => imageResponse = _ImageResponse(imageData: bytes, error: 'Image is empty.'));
        return;
      }

      setState(() => imageResponse = _ImageResponse(imageData: bytes, error: null));
      await FastCachedImageConfig._saveImage(url, bytes);
    } catch (e) {
      setState(() => imageResponse = _ImageResponse(imageData: Uint8List.fromList([]), error: e.toString()));
    } finally {
      if (!chunkEvents.isClosed) await chunkEvents.close();
    }
  }
}

class _ImageResponse {
  Uint8List imageData;
  String? error;
  _ImageResponse({required this.imageData, required this.error});
}

class FastCachedImageConfig {
  static Box? _box;

  static Future<void> init({required String path}) async {
    Hive.init(path);
    _box = await Hive.openBox('FastCachedImageStorageBox');
  }

  static Future<Uint8List?> _getImage(String url) async {
    if (_box!.keys.contains(url)) {
      return await _box!.get(url);
    }
    return null;
  }

  static Future<void> _saveImage(String url, Uint8List image) async {
    await _box!.put(url, image);
  }
}
