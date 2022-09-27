import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String storageLocation = 'E:/fast';
  print('init');
  final a = DateTime.now();
  await FastCachedImageConfig.init(path: storageLocation, clearCacheAfter: const Duration(days: 15));
  print(DateTime.now().difference(a).inMilliseconds);

  print('init over');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String url1 = 'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg';
  String url1 =
      'https://effigis.com/wp-content/uploads/2015/02/DigitalGlobe_WorldView1_50cm_8bit_BW_DRA_Bangkok_Thailand_2009JAN06_8bits_sub_r_1.jpg';
  String url2 =
      'https://effigis.com/wp-content/uploads/2015/02/DigitalGlobe_WorldView2_50cm_8bit_Pansharpened_RGB_DRA_Rome_Italy_2009DEC10_8bits_sub_r_1.jpg';
  String url3 =
      'https://effigis.com/wp-content/uploads/2015/02/DigitalGlobe_QuickBird_60cm_8bit_RGB_DRA_Boulder_2005JUL04_8bits_sub_r_1.jpg';
  String url4 =
      'https://effigis.com/wp-content/themes/effigis_2014/img/RapidEye_RapidEye_5m_RGB_Altotting_Germany_Agriculture_and_Forestry_2009MAY17_8bits_sub_r_2.jpg';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: Column(
        children: [
          // SizedBox(
          //   height: 350,
          //   width: 350,
          //   child: CachedNetworkImage(
          //     imageUrl: url1,
          //     progressIndicatorBuilder: (contex, _, s) {
          //       return CircularProgressIndicator(value: s.progress);
          //     },
          //   ),
          // ),
          Img(url: url1),
          // Img(url: url2),
          // Img(url: url3),
          // Img(url: url4),

          MaterialButton(
            onPressed: () => print(FastCachedImageConfig.isCached(imageUrl: url1)),
            child: const Text('check'),
          ),
          MaterialButton(
            onPressed: () => FastCachedImageConfig.clearCachedImage(imageUrl: url1),
            child: const Text('delete'),
          ),
          MaterialButton(
            onPressed: () => FastCachedImageConfig.clearAllCachedImages(),
            child: const Text('del all'),
          ),
        ],
      ),
    )));
  }
}

class Img extends StatelessWidget {
  final String url;
  const Img({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: FastCachedImage(
        url: url,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(seconds: 1),
        errorBuilder: (context, exception, stacktrace) {
          return Text(exception.toString());
        },
        // loadingBuilder: (context) {
        //   return Container(color: Colors.yellow);
        // },
        progressBuilder: (context, a, b, progress) {
          return Container(
            color: Colors.green,
            child: CircularProgressIndicator(color: Colors.red, value: progress.value),
          );
        },
      ),
    );
  }
}
