import 'package:get_it/get_it.dart';
import 'package:playoffs_score_tracker/views/score_card/provider/score_card_provider.dart';
import 'package:uuid/uuid.dart';

final sl = GetIt.instance;

void initService() {
  sl.registerLazySingleton<ScoreCardProvider>(
    () => ScoreCardProvider(const Uuid()),
  );
}
