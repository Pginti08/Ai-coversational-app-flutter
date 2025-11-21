import 'core/constants/flavors.dart';
import 'main.dart';

void main() {
  bootstrap(() => App(), FlavorType.staging);
}
