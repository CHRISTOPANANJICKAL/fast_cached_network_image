import 'package:flutter/cupertino.dart';

class FastCachedProgressData {
  ///[downloadedBytes] represents the downloaded size(in bytes) of the image. This value increases and reaches the [totalBytes] when image is fully downloaded.
  int downloadedBytes;

  ///[totalBytes] represents the actual size(in bytes) of the image. This value can be null if the size is not obtained from the image.
  int? totalBytes;

  ///[progressPercentage] gives the download progress of the image
  ValueNotifier<double> progressPercentage;

  ///[isDownloading] will be true if the image is to be download, and will be false if the image is already in the cache
  bool isDownloading;

  ///[FastCachedProgressData] has the data representing the download progress and total size of the image.
  FastCachedProgressData(
      {required this.progressPercentage,
      required this.totalBytes,
      required this.downloadedBytes,
      required this.isDownloading});
}
