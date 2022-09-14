import 'dart:async';
import 'dart:io';
import 'package:fast_cached_network_image/src/models/image_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class FastCachedImage extends StatefulWidget {
  final String url;
  final ImageErrorWidgetBuilder? errorBuilder;
  final Widget Function(BuildContext)? loadingBuilder;
  final Duration fadeInDuration;
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
  final bool disableErrorLogs;

  const FastCachedImage(
      {required this.url,
      this.scale = 1.0,
      this.errorBuilder,
      this.semanticLabel,
      this.loadingBuilder,
      this.excludeFromSemantics = false,
      this.disableErrorLogs = false,
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
      this.fadeInDuration = const Duration(milliseconds: 750),
      int? cacheWidth,
      int? cacheHeight,
      Key? key})
      : super(key: key);

  @override
  State<FastCachedImage> createState() => _FastCachedImageState();
}

class _FastCachedImageState extends State<FastCachedImage> with TickerProviderStateMixin {
  _ImageResponse? imageResponse;

  late Animation<double> animation;
  late AnimationController animationController;
  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: widget.fadeInDuration);
    animation =
        Tween<double>(begin: widget.fadeInDuration == Duration.zero ? 1 : 0, end: 1).animate(animationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadAsync(widget.url);
      animationController.addStatusListener((status) => _animationListener(status));
    });

    super.initState();
  }

  void _animationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted && widget.fadeInDuration != Duration.zero) setState(() => {});
  }

  @override
  void dispose() {
    animationController.removeListener(() => {});
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (imageResponse?.error != null && widget.errorBuilder != null) {
      _logErrors(imageResponse?.error);
      return widget.errorBuilder!(context, Object, StackTrace.fromString(imageResponse!.error!));
    }

    return SizedBox(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          if (animationController.status != AnimationStatus.completed)
            (widget.loadingBuilder != null) ? widget.loadingBuilder!(context) : const SizedBox(),
          if (imageResponse != null)
            FadeTransition(
              opacity: animation,
              child: Image.memory(
                imageResponse!.imageData,
                color: widget.color,
                width: widget.width,
                height: widget.height,
                alignment: widget.alignment,
                key: widget.key,
                fit: widget.fit,
                errorBuilder: (a, c, v) {
                  if (animationController.status != AnimationStatus.completed) {
                    animationController.forward();
                    _logErrors(c);
                    FastCachedImageConfig._deleteImage(widget.url);
                  }
                  return widget.errorBuilder != null ? widget.errorBuilder!(a, c, v) : const SizedBox();
                },
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
                frameBuilder: widget.loadingBuilder != null
                    ? (context, a, b, c) {
                        if (b == null) {
                          return widget.loadingBuilder!(context);
                        }

                        if (animationController.status != AnimationStatus.completed) {
                          animationController.forward();
                        }
                        return a;
                      }
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _loadAsync(url) async {
    if (FastCachedImageConfig._box == null || !FastCachedImageConfig._box!.isOpen) {
      throw Exception(
          'FastCachedImage is not initialized. Please use FastCachedImageConfig.init to initialize FastCachedImage');
    }

    Uint8List? image = await FastCachedImageConfig._getImage(url);

    if (!mounted) return;

    if (image != null) {
      setState(() => imageResponse = _ImageResponse(imageData: image, error: null));
      if (widget.loadingBuilder == null) animationController.forward();

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
        if (mounted) setState(() => imageResponse = _ImageResponse(imageData: Uint8List.fromList([]), error: error));
        return;
      }

      if (!mounted) return;

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );

      if (bytes.isEmpty && mounted) {
        setState(() => imageResponse = _ImageResponse(imageData: bytes, error: 'Image is empty.'));
        return;
      }
      if (mounted) {
        setState(() => imageResponse = _ImageResponse(imageData: bytes, error: null));
        if (widget.loadingBuilder == null) animationController.forward();
      }

      await FastCachedImageConfig._saveImage(url, bytes);
    } catch (e) {
      if (mounted) {
        setState(() => imageResponse = _ImageResponse(imageData: Uint8List.fromList([]), error: e.toString()));
      }
    } finally {
      if (!chunkEvents.isClosed) await chunkEvents.close();
    }
  }

  void _logErrors(dynamic object) {
    if (!widget.disableErrorLogs) debugPrint('$object - Image url : ${widget.url}');
  }
}

class _ImageResponse {
  Uint8List imageData;
  String? error;
  _ImageResponse({required this.imageData, required this.error});
}

class FastCachedImageConfig {
  static Box? _box;

  ///[init] function initializes the cache management system.
  ///The path param must be a valid location such as temporary directory in android.
  ///[clearCacheAfter] property is used to set a  duration after which the cache will be cleared.
  ///Default value of [clearCacheAfter] is 7 days which means if [clearCacheAfter] is set to null, an image cached today will be cleared when you open the app after 7 days from now.

  static Future<void> init({required String path, Duration? clearCacheAfter}) async {
    if (path.isEmpty) throw Exception('Image storage location path cannot be empty');

    clearCacheAfter ??= const Duration(days: 7);

    Hive.init(path);
    _box = await Hive.openBox('FastCachedImageStorageBox');
    await _clearOldCache(clearCacheAfter);
  }

  static Future<Uint8List?> _getImage(String url) async {
    if (_box!.keys.contains(url)) {
      FastCacheImageModel model = FastCacheImageModel.fromJson(await _box!.get(url));
      return model.data;
    }
    return null;
  }

  static Future<void> _saveImage(String url, Uint8List image) async {
    await _box!.put(url, FastCacheImageModel(dateCreated: DateTime.now(), data: image).toJson());
  }

  static Future<void> _clearOldCache(Duration cleatCacheAfter) async {
    DateTime today = DateTime.now();

    for (final key in _box!.keys) {
      FastCacheImageModel model = FastCacheImageModel.fromJson(await _box!.get(key));

      if (today.difference(model.dateCreated) > cleatCacheAfter) await _box!.delete(key);
    }
  }

  static Future<void> _deleteImage(String url) async {
    if (_box!.keys.contains(url)) await _box!.delete(url);
  }
}
