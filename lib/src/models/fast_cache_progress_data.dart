import 'package:flutter/cupertino.dart';

class FastCachedProgressData {
  int downloadedBytes;
  int? totalBytes;
  ValueNotifier<double> progressPercentage;
  bool isDownloading;

  FastCachedProgressData(
      {required this.progressPercentage,
      required this.totalBytes,
      required this.downloadedBytes,
      required this.isDownloading});
}
