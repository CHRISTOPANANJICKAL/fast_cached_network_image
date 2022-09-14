
# Fast Cached Network Image

A flutter package to cache network image fastly without native dependencies, with loader, error builder, and smooth fade transitions.


[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://pub.dev/packages/fast_cached_network_image)
[![pub](https://img.shields.io/pub/v/fast_cached_network_image)](https://pub.dev/packages/fast_cached_network_image)
[![dart](https://img.shields.io/badge/dart-pure%20dart-success)](https://pub.dev/packages/fast_cached_network_image)

## Screenshots

![App caching](https://github.com/CHRISTOPANANJICKAL/fast_cached_network_image/blob/main/fast-cache.gif)

![Caching with fade in animation](https://github.com/CHRISTOPANANJICKAL/fast_cached_network_image/blob/main/images-in-row.gif)

The below gif displays a 30 MB image from cache. Use [shimmer](https://pub.dev/packages/shimmer) package to create a beautiful loading widget.
![Loading a large cached imaged file](https://github.com/CHRISTOPANANJICKAL/fast_cached_network_image/blob/main/image-with-shimmer.gif)

## Usage
Depend on it
```dart
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
```

Use [path_provider](https://pub.dev/packages/path_provider) to set a storage location for the db of images.
```dart
String storageLocation = (await getApplicationDocumentsDirectory()).path;
```


Initialize the cache configuration
```dart
await FastCachedImageConfig.init(path: storageLocation, clearCacheAfter: const Duration(days: 15));
```
The clearCacheAfter property is used to set the Duration after with the cached image will be cleared. By default its set to 7 days, which means an image cached today will be deleted when you open the app after 7 days.

Use it as a Widget

```dart
child: FastCachedImage(url: url)
```

## Properties
``` dart
errorBuilder: (context, exception, stacktrace) {
          return Text(exception.toString());
        },
```
errorBuilder property needs to return a widget. This widget will be displayed if there is any error while loading the provided image.
``` dart

loadingBuilder: (context) {
          return Container(color: Colors.red, height: 100, width: 100);
        },
```
loadingBuilder property can be used to display a loading widget such as a shimmer. This widget will be displayed while the image is being downloaded and processed.

```dart
fadeInDuration: const Duration(seconds: 1)
```
fadeInDuration property can be use to set the fadeInDuration between the loadingBuilder and the image. Default duration is 500 milliseconds

If an image had some errors while displaying, the image will be automatically re - downloaded when the image is requested again.

FastCachedImage have all other default properties such as height, width etc. provided by flutter.


## Example

```dart

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String storageLocation = 'E:/fast';
  await FastCachedImageConfig.init(path: storageLocation, clearCacheAfter: const Duration(days: 15));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String url1 = 'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg';


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SizedBox(
      height: 350,
      width: 350,
      child: FastCachedImage(
        url: url1,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(seconds: 1),
        errorBuilder: (context, exception, stacktrace) {
          return Text(exception.toString());
        },
        loadingBuilder: (context) {
          return Container(color: Colors.grey);
        },
      ),
    )));
  }
}
```

## Package on pub.dev

[fast_cached_network_image](https://pub.dev/packages/fast_cached_network_image)

