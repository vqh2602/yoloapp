import 'package:flutter_test/flutter_test.dart';
import 'package:yoloapp/flavors.dart';

void main() {
  test('flavor title reflects the selected flavor', () {
    F.appFlavor = Flavor.dev;
    expect(F.title, 'YoloApp Dev');

    F.appFlavor = Flavor.prod;
    expect(F.title, 'YoloApp');
  });
}
