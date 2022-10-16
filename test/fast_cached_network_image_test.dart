import 'package:fast_cached_network_image/src/fast_cached_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String url1 =
      'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg';

  test('Initialize fast cached image configurations', () async {
    await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 15));
  }, timeout: const Timeout(Duration(seconds: 2)));

  testWidgets('FastCachedImage can be displayed', (WidgetTester tester) async {
    await tester.pumpWidget(FastCachedImage(url: url1));
  });
}
