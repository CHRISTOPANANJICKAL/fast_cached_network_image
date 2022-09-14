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
  bool showImage = false;

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
