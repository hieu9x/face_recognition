import 'package:get_it/get_it.dart';

import 'services/ml_service.dart';

final locator = GetIt.instance;

void setupServices() {
  locator.registerLazySingleton<MLService>(() => MLService());
}
