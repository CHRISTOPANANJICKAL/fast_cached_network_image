
## Usage

```dart

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String storageLocation = (await getApplicationDocumentsDirectory()).path;
  await FastCachedImageConfig.init(path: storageLocation);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String url = 'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: FastCachedImage(
        url: url,
        errorBuilder: (context, _, e) {
          return Text(e.toString());
        },
        loadingBuilder: (context) {
          return Container(color: Colors.red, height: 100, width: 100);
        },
      ),
    ));
  }
}