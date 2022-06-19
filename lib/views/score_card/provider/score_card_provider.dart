import 'package:flutter/material.dart';
import 'package:playoffs_score_tracker/schemas/score_card.schema.dart';
import 'package:realm/realm.dart';
import 'package:uuid/uuid.dart' as u;

enum ScoreCardStatus {
  incomplete,
  complete,
  saved,
}

class ScoreCardProvider extends ChangeNotifier {
  final u.Uuid uuid;
  final Realm db;

  late String id;

  final int maxRower = 290;
  final int maxBenchHops = 95;
  final int maxKneeTuckPushUps = 57;
  final int maxLateralHops = 130;
  final int maxBoxJumpBurpee = 20;
  final int maxChinUps = 25;
  final int maxSquatPress = 36;
  final int maxRussianTwist = 87;
  final int maxDeadBallOverTheShoulder = 27;
  final int maxShuttleSprintLateralHop = 15;

  int totalScore = 0;

  late DateTime date;
  late int rower;
  late int benchHops;
  late int kneeTuckPushUps;
  late int lateralHops;
  late int boxJumpBurpee;
  late int chinUps;
  late int squatPress;
  late int russianTwist;
  late int deadBallOverTheShoulder;
  late int shuttleSprintLateralHop;

  int rowerScore = 0;
  int benchHopsScore = 0;
  int kneeTuckPushUpsScore = 0;
  int lateralHopsScore = 0;
  int boxJumpBurpeeScore = 0;
  int chinUpsScore = 0;
  int squatPressScore = 0;
  int russianTwistScore = 0;
  int deadBallOverTheShoulderScore = 0;
  int shuttleSprintLateralHopScore = 0;

  ScoreCardStatus status = ScoreCardStatus.incomplete;

  ScoreCardProvider(this.uuid, this.db) {
    _init();
  }

  void _init() {
    id = uuid.v4();
    print("re-init: $id");
    date = DateTime.now();
    rower = -1;
    benchHops = -1;
    kneeTuckPushUps = -1;
    lateralHops = -1;
    boxJumpBurpee = -1;
    chinUps = -1;
    squatPress = -1;
    russianTwist = -1;
    deadBallOverTheShoulder = -1;
    shuttleSprintLateralHop = -1;
  }

  void setRower(int value) {
    rower = value;
    rowerScore = _calcScore(value, maxRower);
    totalScoreCalculator();
    notifyListeners();
  }

  void setBenchHops(int value) {
    benchHops = value;
    benchHopsScore = _calcScore(value, maxBenchHops);

    totalScoreCalculator();
    notifyListeners();
  }

  void setKneeTuckPushUps(int value) {
    kneeTuckPushUps = value;
    kneeTuckPushUpsScore = _calcScore(value, maxKneeTuckPushUps);

    totalScoreCalculator();
    notifyListeners();
  }

  void setLateralHops(int value) {
    lateralHops = value;
    lateralHopsScore = _calcScore(value, maxLateralHops);

    totalScoreCalculator();
    notifyListeners();
  }

  void setBoxJumpBurpee(int value) {
    boxJumpBurpee = value;
    boxJumpBurpeeScore = _calcScore(value, maxBoxJumpBurpee);

    totalScoreCalculator();
    notifyListeners();
  }

  void setChinUps(int value) {
    chinUps = value;
    chinUpsScore = _calcScore(value, maxChinUps);

    totalScoreCalculator();
    notifyListeners();
  }

  void setSquatPress(int value) {
    squatPress = value;
    squatPressScore = _calcScore(value, maxSquatPress);

    totalScoreCalculator();
    notifyListeners();
  }

  void setRussianTwist(int value) {
    russianTwist = value;
    russianTwistScore = _calcScore(value, maxRussianTwist);

    totalScoreCalculator();
    notifyListeners();
  }

  void setDeadBallOverTheShoulder(int value) {
    deadBallOverTheShoulder = value;
    deadBallOverTheShoulderScore =
        _calcScore(value, maxDeadBallOverTheShoulder);

    totalScoreCalculator();
    notifyListeners();
  }

  void setShuttleSprintLateralHop(int value) {
    shuttleSprintLateralHop = value;
    shuttleSprintLateralHopScore =
        _calcScore(value, maxShuttleSprintLateralHop);

    totalScoreCalculator();
    notifyListeners();
  }

  int _calcScore(int value, int max) {
    if (value > max) return 100;
    return (value / max * 100).round();
  }

  void totalScoreCalculator() {
    totalScore = rowerScore +
        benchHopsScore +
        kneeTuckPushUpsScore +
        lateralHopsScore +
        boxJumpBurpeeScore +
        chinUpsScore +
        squatPressScore +
        russianTwistScore +
        deadBallOverTheShoulderScore +
        shuttleSprintLateralHop;

    canSave();
    notifyListeners();
  }

  void canSave() {
    if (rower != -1 &&
        benchHops != -1 &&
        kneeTuckPushUps != -1 &&
        lateralHops != -1 &&
        boxJumpBurpee != -1 &&
        chinUps != -1 &&
        squatPress != -1 &&
        russianTwist != -1 &&
        deadBallOverTheShoulder != -1 &&
        shuttleSprintLateralHop != -1) {
      status = ScoreCardStatus.complete;
    } else {
      status = ScoreCardStatus.incomplete;
    }
    notifyListeners();
  }

  void save() {
    db.write(
      () => db.add(
        ScoreCard(
          id,
          date,
          rower,
          benchHops,
          kneeTuckPushUps,
          lateralHops,
          boxJumpBurpee,
          chinUps,
          squatPress,
          russianTwist,
          deadBallOverTheShoulder,
          shuttleSprintLateralHop,
        ),
      ),
    );

    status = ScoreCardStatus.saved;
    print("saved: $id");
    _init();
    print("re-init: $id");
    notifyListeners();
  }
}