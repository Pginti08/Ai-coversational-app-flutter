import 'core/constants/flavors.dart';
import 'main.dart';

void main() {
  bootstrap(() => const App(), FlavorType.staging);
}
