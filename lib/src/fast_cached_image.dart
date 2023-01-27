import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/fast_cache_progress_data.dart';
import 'package:dio/dio.dart';

class FastCachedImage extends StatefulWidget {
  ///Provide the [url] for the image to display.
  final String url;

  ///[errorBuilder] must return a widget. This widget will be displayed if there is any error in downloading or displaying
  ///the downloaded image
  final ImageErrorWidgetBuilder? errorBuilder;

  ///[loadingBuilder] is the builder which can show the download progress of an image.

  ///Usage: loadingBuilder(context, FastCachedProgressData progressData){return  Text('${progress.downloadedBytes ~/ 1024} / ${progress.totalBytes! ~/ 1024} kb')}
  final Widget Function(BuildContext, FastCachedProgressData)? loadingBuilder;

  ///[fadeInDuration] can be adjusted to change the duration of the fade transition between the [loadingBuilder]
  ///and the actual image. Default value is 500 ms.
  final Duration fadeInDuration;

  /// If [cacheWidth] or [cacheHeight] are provided, it indicates to the
  /// engine that the image must be decoded at the specified size. The image
  /// will be rendered to the constraints of the layout or [width] and [height]
  /// regardless of these parameters. These parameters are primarily intended
  /// to reduce the memory usage of [ImageCache].
  /// If non-null, this color is blended with each image pixel using [colorBlendMode].
  /// If the image is of a high quality and its pixels are perfectly aligned
  /// with the physical screen pixels, extra quality enhancement may not be
  /// necessary. If so, then [FilterQuality.none] would be the most efficient.
  ///[width] width of the image
  final double? width;

  ///[height] of the image
  final double? height;

  ///[scale] property in Flutter memory image.
  final double scale;

  ///[color] property in Flutter memory image.
  final Color? color;

  ///[opacity] property in Flutter memory image.
  final Animation<double>? opacity;

  /// If the pixels are not perfectly aligned with the screen pixels, or if the
  /// image itself is of a low quality, [FilterQuality.none] may produce
  /// undesirable artifacts. Consider using other [FilterQuality] values to
  /// improve the rendered image quality in this case. Pixels may be misaligned
  /// with the screen pixels as a result of transforms or scaling.
  /// [opacity] can be used to adjust the opacity of the image.
  /// Used to combine [color] with this image.
  final FilterQuality filterQuality;

  ///[colorBlendMode] property in Flutter memory image
  final BlendMode? colorBlendMode;

  ///[fit] How a box should be inscribed into another box
  final BoxFit? fit;

  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while an
  /// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  final AlignmentGeometry alignment;

  ///[repeat] property in Flutter memory image.
  final ImageRepeat repeat;

  ///[centerSlice] property in Flutter memory image.
  final Rect? centerSlice;

  ///[matchTextDirection] property in Flutter memory image.
  final bool matchTextDirection;

  /// Whether to continue showing the old image (true), or briefly show nothing
  /// (false), when the image provider changes. The default value is false.
  ///
  /// ## Design discussion
  ///
  /// ### Why is the default value of [gaplessPlayback] false?
  ///
  /// Having the default value of [gaplessPlayback] be false helps prevent
  /// situations where stale or misleading information might be presented.
  /// Consider the following case:
  final bool gaplessPlayback;

  ///[semanticLabel] property in Flutter memory image.
  final String? semanticLabel;

  ///[excludeFromSemantics] property in Flutter memory image.
  final bool excludeFromSemantics;

  ///[isAntiAlias] property in Flutter memory image.
  final bool isAntiAlias;

  ///[disableErrorLogs] can be set to true if you want to ignore error logs from the widget
  final bool disableErrorLogs;

  ///[FastCachedImage] creates a widget to display network images. This widget downloads the network image
  ///when this widget is build for the first time. Later whenever this widget is called the image will be displayed from
  ///the downloaded database instead of the network. This can avoid unnecessary downloads and load images much faster.
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
      this.fadeInDuration = const Duration(milliseconds: 500),
      int? cacheWidth,
      int? cacheHeight,
      Key? key})
      : super(key: key);

  @override
  State<FastCachedImage> createState() => _FastCachedImageState();
}

class _FastCachedImageState extends State<FastCachedImage>
    with TickerProviderStateMixin {
  ///[_imageResponse] not public API.
  _ImageResponse? _imageResponse;

  ///[_animation] not public API.
  late Animation<double> _animation;

  ///[_animationController] not public API.
  late AnimationController _animationController;

  ///[_progressData] holds the data indicating the progress of download.
  late FastCachedProgressData _progressData;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: widget.fadeInDuration);
    _animation = Tween<double>(
            begin: widget.fadeInDuration == Duration.zero ? 1 : 0, end: 1)
        .animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadAsync(widget.url);
      _animationController
          .addStatusListener((status) => _animationListener(status));
    });

    _progressData = FastCachedProgressData(
        progressPercentage: ValueNotifier(0),
        totalBytes: null,
        downloadedBytes: 0,
        isDownloading: false);
    super.initState();
  }

  void _animationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed &&
        mounted &&
        widget.fadeInDuration != Duration.zero) setState(() => {});
  }

  @override
  void dispose() {
    _animationController.removeListener(() => {});
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageResponse?.error != null && widget.errorBuilder != null) {
      _logErrors(_imageResponse?.error);
      return widget.errorBuilder!(
          context, Object, StackTrace.fromString(_imageResponse!.error!));
    }

    return SizedBox(
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          if (_animationController.status != AnimationStatus.completed)
            // (widget.loadingBuilder != null)
            // ? widget.loadingBuilder!(context)
            // :
            (widget.loadingBuilder != null)
                ? ValueListenableBuilder(
                    valueListenable: _progressData.progressPercentage,
                    builder: (context, p, c) {
                      return widget.loadingBuilder!(context, _progressData);
                    })
                : const SizedBox(),
          if (_imageResponse != null)
            FadeTransition(
              opacity: _animation,
              child: Image.memory(
                _imageResponse!.imageData,
                color: widget.color,
                width: widget.width,
                height: widget.height,
                alignment: widget.alignment,
                key: widget.key,
                fit: widget.fit,
                errorBuilder: (a, c, v) {
                  if (_animationController.status !=
                      AnimationStatus.completed) {
                    _animationController.forward();
                    _logErrors(c);
                    FastCachedImageConfig.deleteCachedImage(
                        imageUrl: widget.url);
                  }
                  return widget.errorBuilder != null
                      ? widget.errorBuilder!(a, c, v)
                      : const SizedBox();
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
                frameBuilder: (widget.loadingBuilder != null)
                    ? (context, a, b, c) {
                        if (b == null) {
                          return widget.loadingBuilder!(
                              context,
                              FastCachedProgressData(
                                  progressPercentage:
                                      _progressData.progressPercentage,
                                  totalBytes: _progressData.totalBytes,
                                  downloadedBytes:
                                      _progressData.downloadedBytes,
                                  isDownloading: false));
                        }

                        if (_animationController.status !=
                            AnimationStatus.completed) {
                          _animationController.forward();
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

  ///[_loadAsync] Not public API.
  Future<void> _loadAsync(url) async {
    FastCachedImageConfig._checkInit();
    Uint8List? image = await FastCachedImageConfig._getImage(url);

    if (!mounted) return;

    if (image != null) {
      setState(
          () => _imageResponse = _ImageResponse(imageData: image, error: null));
      if (widget.loadingBuilder == null) _animationController.forward();

      return;
    }

    StreamController chunkEvents = StreamController();

    try {
      final Uri resolved = Uri.base.resolve(url);
      Dio dio = Dio();

      if (!mounted) return;

      //set is downloading flag to true
      _progressData.isDownloading = true;
      if (widget.loadingBuilder != null) {
        widget.loadingBuilder!(context, _progressData);
      }
      Response response = await dio
          .get(url, options: Options(responseType: ResponseType.bytes),
              onReceiveProgress: (int received, int total) {
        if (received < 0 || total < 0) return;
        if (widget.loadingBuilder != null) {
          _progressData.downloadedBytes = received;
          _progressData.totalBytes = total;
          double.parse((received / total).toStringAsFixed(2));
          // _progress.value = tot != null ? _downloaded / _total! : 0;
          _progressData.progressPercentage.value =
              double.parse((received / total).toStringAsFixed(2));
          widget.loadingBuilder!(context, _progressData);
        }

        chunkEvents.add(ImageChunkEvent(
          cumulativeBytesLoaded: received,
          expectedTotalBytes: total,
        ));
      });

      final Uint8List bytes = response.data;

      if (response.statusCode != 200) {
        String error = NetworkImageLoadException(
                statusCode: response.statusCode ?? 0, uri: resolved)
            .toString();
        if (mounted) {
          setState(() => _imageResponse =
              _ImageResponse(imageData: Uint8List.fromList([]), error: error));
        }
        return;
      }

      //set is downloading flag to false
      _progressData.isDownloading = false;

      if (bytes.isEmpty && mounted) {
        setState(() => _imageResponse =
            _ImageResponse(imageData: bytes, error: 'Image is empty.'));
        return;
      }
      if (mounted) {
        setState(() =>
            _imageResponse = _ImageResponse(imageData: bytes, error: null));
        if (widget.loadingBuilder == null) _animationController.forward();
      }

      await FastCachedImageConfig._saveImage(url, bytes);
    } catch (e) {
      if (mounted) {
        setState(() => _imageResponse = _ImageResponse(
            imageData: Uint8List.fromList([]), error: e.toString()));
      }
    } finally {
      if (!chunkEvents.isClosed) await chunkEvents.close();
    }
  }

  void _logErrors(dynamic object) {
    if (!widget.disableErrorLogs) {
      debugPrint('$object - Image url : ${widget.url}');
    }
  }
}

class _ImageResponse {
  Uint8List imageData;
  String? error;
  _ImageResponse({required this.imageData, required this.error});
}

///[FastCachedImageConfig] is the class to manage and set the cache configurations.
class FastCachedImageConfig {
  static LazyBox? _imageKeyBox;
  static LazyBox? _imageBox;
  static bool _isInitialized = false;
  static const String _notInitMessage =
      'FastCachedImage is not initialized. Please use FastCachedImageConfig.init to initialize FastCachedImage';

  ///[init] function initializes the cache management system. Use this code only once in the app in main to avoid errors.
  /// You can provide a [subDir] where the boxes should be stored.
  ///[clearCacheAfter] property is used to set a  duration after which the cache will be cleared.
  ///Default value of [clearCacheAfter] is 7 days which means if [clearCacheAfter] is set to null,
  /// an image cached today will be cleared when you open the app after 7 days from now.
  static Future<void> init({String? subDir, Duration? clearCacheAfter}) async {
    if (_isInitialized) return;

    clearCacheAfter ??= const Duration(days: 7);

    await Hive.initFlutter(subDir);
    _isInitialized = true;

    _imageKeyBox = await Hive.openLazyBox(_BoxNames.imagesKeyBox);
    _imageBox = await Hive.openLazyBox(_BoxNames.imagesBox);
    await _clearOldCache(clearCacheAfter);
  }

  static Future<Uint8List?> _getImage(String url) async {
    if (_imageKeyBox!.keys.contains(url) && _imageBox!.keys.contains(url)) {
      Uint8List? data = await _imageBox!.get(url);
      if (data == null || data.isEmpty) return null;

      return data;
    }

    return null;
  }

  ///[_saveImage] is to save an image to cache. Not part of public API.
  static Future<void> _saveImage(String url, Uint8List image) async {
    await _imageKeyBox!.put(url, DateTime.now());
    await _imageBox!.put(url, image);
  }

  ///[_clearOldCache] clears the old cache. Not part of public API.
  static Future<void> _clearOldCache(Duration cleatCacheAfter) async {
    DateTime today = DateTime.now();

    for (final key in _imageKeyBox!.keys) {
      DateTime? dateCreated = await _imageKeyBox!.get(key);

      if (dateCreated == null) continue;

      if (today.difference(dateCreated) > cleatCacheAfter) {
        await _imageKeyBox!.delete(key);
        await _imageBox!.delete(key);
      }
    }
  }

  ///[deleteCachedImage] function takes in a image [imageUrl] and removes the image corresponding to the url
  /// from the cache if the image is present in the cache.
  static Future<void> deleteCachedImage(
      {required String imageUrl, bool showLog = true}) async {
    _checkInit();
    if (_imageKeyBox!.keys.contains(imageUrl) &&
        _imageBox!.keys.contains(imageUrl)) {
      await _imageKeyBox!.delete(imageUrl);
      await _imageBox!.delete(imageUrl);
      if (showLog) {
        debugPrint('FastCacheImage: Removed image $imageUrl from cache.');
      }
    }
  }

  ///[clearAllCachedImages] function clears all cached images. This can be used in scenarios such as
  ///logout functionality of your app, so that all cached images corresponding to the user's account is removed.
  static Future<void> clearAllCachedImages({bool showLog = true}) async {
    _checkInit();
    await _imageKeyBox!.deleteFromDisk();
    await _imageBox!.deleteFromDisk();
    if (showLog) debugPrint('FastCacheImage: All cache cleared.');
    _imageKeyBox = await Hive.openLazyBox(_BoxNames.imagesKeyBox);
    _imageBox = await Hive.openLazyBox(_BoxNames.imagesBox);
  }

  ///[_checkInit] method ensures the hive db is initialized. Not part of public API
  static _checkInit() {
    if ((FastCachedImageConfig._imageKeyBox == null ||
            !FastCachedImageConfig._imageKeyBox!.isOpen) ||
        FastCachedImageConfig._imageBox == null ||
        !FastCachedImageConfig._imageBox!.isOpen) {
      throw Exception(_notInitMessage);
    }
  }

  ///[isCached] returns a boolean indicating whether the given image is cached or not.
  ///Returns true if cached, false if not.
  static bool isCached({required String imageUrl}) {
    _checkInit();
    if (_imageKeyBox!.containsKey(imageUrl) &&
        _imageBox!.keys.contains(imageUrl)) return true;
    return false;
  }
}

///[_BoxNames] contains the name of the boxes. Not part of public API
class _BoxNames {
  ///[imagesBox] db for images
  static String imagesBox = 'cachedImages';

  ///[imagesKeyBox] db for keys of images
  static String imagesKeyBox = 'cachedImagesKeys';
}

/// The fast cached image implementation of [image_provider.NetworkImage].
@immutable
class FastCachedImageProvider extends ImageProvider<NetworkImage>
    implements NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const FastCachedImageProvider(this.url, {this.scale = 1.0, this.headers});

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String>? headers;

  @override
  Future<FastCachedImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FastCachedImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      NetworkImage key, DecoderBufferCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key as FastCachedImageProvider, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<NetworkImage>('Image key', key),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(
    FastCachedImageProvider key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderBufferCallback decode,
  ) async {
    try {
      assert(key == this);
      Dio dio = Dio();
      FastCachedImageConfig._checkInit();
      Uint8List? image = await FastCachedImageConfig._getImage(url);
      if (image != null) {
        final ui.ImmutableBuffer buffer =
            await ui.ImmutableBuffer.fromUint8List(image);
        return decode(buffer);
      }

      final Uri resolved = Uri.base.resolve(key.url);

      if (headers != null) dio.options.headers.addAll(headers!);
      Response response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (int received, int total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: received,
            expectedTotalBytes: total,
          ));
        },
      );

      final Uint8List bytes = response.data;
      if (bytes.lengthInBytes == 0) {
        throw Exception('NetworkImage is an empty file: $resolved');
      }

      final ui.ImmutableBuffer buffer =
          await ui.ImmutableBuffer.fromUint8List(bytes);
      await FastCachedImageConfig._saveImage(url, bytes);
      return decode(buffer);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      scheduleMicrotask(() {
        PaintingBinding.instance.imageCache.evict(key);
      });
      rethrow;
    } finally {
      await chunkEvents.close();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FastCachedImageProvider &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'NetworkImage')}("$url", scale: $scale)';
}
