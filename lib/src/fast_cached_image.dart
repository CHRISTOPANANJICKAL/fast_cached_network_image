import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/fast_cache_progress_data.dart';

/// The underlying widget is [Image.memory]
/// The `scale` argument specifies the linear scale factor for drawing this
/// image at its intended size and applies to both the width and the height.
/// {@macro flutter.painting.imageInfo.scale}
///
/// The `bytes`, `scale`, and [repeat] arguments must not be null.
///
/// This only accepts compressed image formats (e.g. PNG). Uncompressed
/// formats like rawRgba (the default format of [dart:ui.Image.toByteData])
/// will lead to exceptions.
///

///
/// {@macro flutter.widgets.image.filterQualityParameter}
///
/// If [excludeFromSemantics] is true, then [semanticLabel] will be ignored.
///
/// If [cacheWidth] or [cacheHeight] are provided, it indicates to the
/// engine that the image must be decoded at the specified size. The image
/// will be rendered to the constraints of the layout or [width] and [height]
/// regardless of these parameters. These parameters are primarily intended
/// to reduce the memory usage of [ImageCache].
/// If non-null, this color is blended with each image pixel using [colorBlendMode].
/// If the image is of a high quality and its pixels are perfectly aligned
/// with the physical screen pixels, extra quality enhancement may not be
/// necessary. If so, then [FilterQuality.none] would be the most efficient.
///
/// If the pixels are not perfectly aligned with the screen pixels, or if the
/// image itself is of a low quality, [FilterQuality.none] may produce
/// undesirable artifacts. Consider using other [FilterQuality] values to
/// improve the rendered image quality in this case. Pixels may be misaligned
/// with the screen pixels as a result of transforms or scaling.
/// [opacity] can be used to adjust the opacity of the image.
/// Used to combine [color] with this image.
///
/// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
/// the source and this image is the destination.
///
/// See also:
///
///  * [BlendMode], which includes an illustration of the effect of each blend mode.

/// How to inscribe the image into the space allocated during layout.
///
/// The default varies based on the other fields. See the discussion at
/// [paintImage].

/// How to align the image within its bounds.
///
/// The alignment aligns the given position in the image to the given position
/// in the layout bounds. For example, an [Alignment] alignment of (-1.0,
/// -1.0) aligns the image to the top-left corner of its layout bounds, while an
/// [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
/// image with the bottom right corner of its layout bounds. Similarly, an
/// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
/// middle of the bottom edge of its layout bounds.
///
/// To display a subpart of an image, consider using a [CustomPainter] and
/// [Canvas.drawImageRect].
///
/// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
/// [AlignmentDirectional]), then an ambient [Directionality] widget
/// must be in scope.
///
/// Defaults to [Alignment.center].
///
/// See also:
///
///  * [Alignment], a class with convenient constants typically used to
///    specify an [AlignmentGeometry].
///  * [AlignmentDirectional], like [Alignment] for specifying alignments
///    relative to text direction.

/// How to paint any portions of the layout bounds not covered by the image.

/// The center slice for a nine-patch image.
///
/// The region of the image inside the center slice will be stretched both
/// horizontally and vertically to fit the image into its destination. The
/// region of the image above and below the center slice will be stretched
/// only horizontally and the region of the image to the left and right of
/// the center slice will be stretched only vertically.

/// Whether to paint the image in the direction of the [TextDirection].
///
/// If this is true, then in [TextDirection.ltr] contexts, the image will be
/// drawn with its origin in the top left (the "normal" painting direction for
/// images); and in [TextDirection.rtl] contexts, the image will be drawn with
/// a scaling factor of -1 in the horizontal direction so that the origin is
/// in the top right.
///
/// This is occasionally used with images in right-to-left environments, for
/// images that were designed for left-to-right locales. Be careful, when
/// using this, to not flip images with integral shadows, text, or other
/// effects that will look incorrect when flipped.
///
/// If this is true, there must be an ambient [Directionality] widget in
/// scope.

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
///
/// We have constructed a 'Person' widget that displays an avatar [Image] of
/// the currently loaded person along with their name. We could request for a
/// new person to be loaded into the widget at any time. Suppose we have a
/// person currently loaded and the widget loads a new person. What happens
/// if the [Image] fails to load?
///
/// * Option A ([gaplessPlayback] = false): The new person's name is coupled
/// with a blank image.
///
/// * Option B ([gaplessPlayback] = true): The widget displays the avatar of
/// the previous person and the name of the newly loaded person.
///
/// This is why the default value is false. Most of the time, when you change
/// the image provider you're not just changing the image, you're removing the
/// old widget and adding a new one and not expecting them to have any
/// relationship. With [gaplessPlayback] on you might accidentally break this
/// expectation and re-use the old widget.

/// A Semantic description of the image.
///
/// Used to provide a description of the image to TalkBack on Android, and
/// VoiceOver on iOS.

/// Whether to exclude this image from semantics.
///
/// Useful for images which do not contribute meaningful information to an
/// application.

/// Whether to paint the image with anti-aliasing.
///
/// Anti-aliasing alleviates the sawtooth artifact when the image is rotated.

class FastCachedImage extends StatefulWidget {
  ///Provide the [url] for the image to display.
  final String url;

  ///[errorBuilder] must return a widget. This widget will be displayed if there is any error in downloading or displaying
  ///the downloaded image
  final ImageErrorWidgetBuilder? errorBuilder;

  //[loadingBuilder] must return a widget. This widget is shown when the image is being downloaded and processed
  // final Widget Function(BuildContext)? loadingBuilder;

  ///[progressBuilder] is the builder which can show the download progress of an image.

  ///Usage: progressBuilder(context, int downloaded, int? total){return Text('$downloaded / $total ')}
  // final Widget Function(BuildContext, int downloaded, int? total, ValueListenable<double> progress)? progressBuilder;
  final Widget Function(BuildContext, FastCachedProgressData)? progressBuilder;

  ///[fadeInDuration] can be adjusted to change the duration of the fade transition between the [progressBuilder]
  ///and the actual image. Default value is 500 ms.
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
      // this.loadingBuilder,
      this.progressBuilder,
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

class _FastCachedImageState extends State<FastCachedImage> with TickerProviderStateMixin {
  _ImageResponse? _imageResponse;

  late Animation<double> _animation;
  late AnimationController _animationController;

  // int _downloaded = 0;
  // final ValueNotifier<double> _progress = ValueNotifier(0);
  // int? _total;
  // bool _isDownloading = false;

  late FastCachedProgressData progressData;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: widget.fadeInDuration);
    _animation =
        Tween<double>(begin: widget.fadeInDuration == Duration.zero ? 1 : 0, end: 1).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadAsync(widget.url);
      _animationController.addStatusListener((status) => _animationListener(status));
    });

    progressData = FastCachedProgressData(
        progressPercentage: ValueNotifier(0), totalBytes: null, downloadedBytes: 0, isDownloading: false);
    super.initState();
  }

  void _animationListener(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted && widget.fadeInDuration != Duration.zero) setState(() => {});
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
      return widget.errorBuilder!(context, Object, StackTrace.fromString(_imageResponse!.error!));
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
            (widget.progressBuilder != null)
                ? ValueListenableBuilder(
                    valueListenable: progressData.progressPercentage,
                    builder: (context, p, c) {
                      // return widget.progressBuilder!(context, downloaded, total, progress);
                      return widget.progressBuilder!(context, progressData);
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
                  if (_animationController.status != AnimationStatus.completed) {
                    _animationController.forward();
                    _logErrors(c);
                    FastCachedImageConfig.deleteCachedImage(imageUrl: widget.url);
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
                // frameBuilder: (widget.loadingBuilder != null || widget.progressBuilder != null)
                frameBuilder: (widget.progressBuilder != null)
                    ? (context, a, b, c) {
                        if (b == null) {
                          return
                              // (widget.loadingBuilder != null)
                              //   ? widget.loadingBuilder!(context)
                              //   :widget.progressBuilder!(context, downloaded, total, progress);
                              widget.progressBuilder!(
                                  context,
                                  FastCachedProgressData(
                                      progressPercentage: progressData.progressPercentage,
                                      totalBytes: progressData.totalBytes,
                                      downloadedBytes: progressData.downloadedBytes,
                                      isDownloading: false));
                        }

                        if (_animationController.status != AnimationStatus.completed) {
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

  Future<void> _loadAsync(url) async {
    FastCachedImageConfig._checkInit();
    Uint8List? image = await FastCachedImageConfig._getImage(url);

    if (!mounted) return;

    if (image != null) {
      setState(() => _imageResponse = _ImageResponse(imageData: image, error: null));
      // if (widget.loadingBuilder == null && widget.progressBuilder == null) animationController.forward();
      if (widget.progressBuilder == null) _animationController.forward();

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
        if (mounted) {
          setState(() => _imageResponse = _ImageResponse(imageData: Uint8List.fromList([]), error: error));
        }
        return;
      }

      if (!mounted) return;

      //set is downloading flag to true
      progressData.isDownloading = true;
      widget.progressBuilder!(context, progressData);

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int? tot) {
          if (widget.progressBuilder != null) {
            progressData.downloadedBytes = cumulative;
            progressData.totalBytes = tot;
            // _progress.value = tot != null ? _downloaded / _total! : 0;
            progressData.progressPercentage.value =
                tot != null ? double.parse((cumulative / tot).toStringAsFixed(2)) : 0;
            widget.progressBuilder!(context, progressData);
          }

          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: tot,
          ));
        },
      );

      //set is downloading flag to false
      progressData.isDownloading = false;

      if (bytes.isEmpty && mounted) {
        setState(() => _imageResponse = _ImageResponse(imageData: bytes, error: 'Image is empty.'));
        return;
      }
      if (mounted) {
        setState(() => _imageResponse = _ImageResponse(imageData: bytes, error: null));
        // if (widget.loadingBuilder == null && widget.progressBuilder == null) animationController.forward();
        if (widget.progressBuilder == null) _animationController.forward();
      }

      await FastCachedImageConfig._saveImage(url, bytes);
    } catch (e) {
      if (mounted) {
        setState(() => _imageResponse = _ImageResponse(imageData: Uint8List.fromList([]), error: e.toString()));
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

class FastCachedImageConfig {
  static LazyBox? _imageKeyBox;
  static LazyBox? _imageBox;
  static bool _isInitialized = false;
  static const String _notInitMessage =
      'FastCachedImage is not initialized. Please use FastCachedImageConfig.init to initialize FastCachedImage';

  ///[FastCachedImageConfig] is the class to manage and set the cache configurations.
  ///[init] function initializes the cache management system. Use this code only once in the app in main to avoid errors.
  ///The path param must be a valid location such as temporary directory in android.
  ///[clearCacheAfter] property is used to set a  duration after which the cache will be cleared.
  ///Default value of [clearCacheAfter] is 7 days which means if [clearCacheAfter] is set to null,
  /// an image cached today will be cleared when you open the app after 7 days from now.
  static Future<void> init({required String path, Duration? clearCacheAfter}) async {
    if (_isInitialized) return;

    if (path.isEmpty) {
      throw Exception('Image storage location path cannot be empty');
    }
    clearCacheAfter ??= const Duration(days: 7);

    Hive.init(path);
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
  static Future<void> deleteCachedImage({required String imageUrl, bool showLog = true}) async {
    _checkInit();
    if (_imageKeyBox!.keys.contains(imageUrl) && _imageBox!.keys.contains(imageUrl)) {
      await _imageKeyBox!.delete(imageUrl);
      await _imageBox!.delete(imageUrl);
      if (showLog) debugPrint('FastCacheImage: Removed image $imageUrl from cache.');
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
    if ((FastCachedImageConfig._imageKeyBox == null || !FastCachedImageConfig._imageKeyBox!.isOpen) ||
        FastCachedImageConfig._imageBox == null ||
        !FastCachedImageConfig._imageBox!.isOpen) {
      throw Exception(_notInitMessage);
    }
  }

  ///[isCached] returns a boolean indicating whether the given image is cached or not.
  ///Returns true if cached, false if not.
  static bool isCached({required String imageUrl}) {
    _checkInit();
    if (_imageKeyBox!.containsKey(imageUrl) && _imageBox!.keys.contains(imageUrl)) return true;
    return false;
  }
}

///[_BoxNames] contains the name of the boxes. Not part of public API
class _BoxNames {
  static String imagesBox = 'cachedImages';
  static String imagesKeyBox = 'cachedImagesKeys';
}
