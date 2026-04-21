import 'package:yoloapp/flavors.dart';
import 'package:yoloapp/main.dart' as base;

void main() {
  F.appFlavor = Flavor.prod;
  base.main();
}
