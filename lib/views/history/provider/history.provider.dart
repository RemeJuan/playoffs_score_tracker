import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:playoffs_score_card/collections/score_card.collection.dart';
import 'package:playoffs_score_card/core/providers/general_providers.dart';
import 'package:playoffs_score_card/core/utils/utils.dart';

enum ChartDataSource {
  total("Total"),
  rower("Rower"),
  benchHops("Bench Hops"),
  kneeTuckPushUps("Knee Tuck Push Ups"),
  lateralHops("Lateral Hops"),
  boxJumpBurpee("Box Jump Burpee"),
  chinUps("Chin Ups"),
  squatPress("Squat Press"),
  russianTwist("Russian Twist"),
  deadBallOverTheShoulder("Dead Ball Over The Shoulder"),
  shuttleSprintLateralHop("Shuttle Sprint Lateral Hop");

  final String name;

  const ChartDataSource(this.name);
}

enum HistoryStatus {
  loading,
  loaded,
}

final historyProvider = Provider(HistoryProvider.new);

class HistoryProvider {
  final Ref ref;

  late Isar _db;
  late FirebaseFirestore _firestore;
  late FirebaseAuth _auth;

  List<ScoreCard> scores = [];
  List<double> chartData = [];

  ChartDataSource activeChartDataSource = ChartDataSource.total;
  HistoryStatus status = HistoryStatus.loading;

  HistoryProvider(this.ref) {
    _init();
  }

  late int maxRower;
  late int maxBenchHops;
  late int maxKneeTuckPushUps;
  late int maxLateralHops;
  late int maxBoxJumpBurpee;
  late int maxChinUps;
  late int maxSquatPress;
  late int maxRussianTwist;
  late int maxDeadBallOverTheShoulder;
  late int maxShuttleSprintLateralHop;

  void _init() async {
    _db = ref.read(dbProvider);
    _auth = ref.read(firebaseAuthProvider);
    _firestore = ref.read(firestoreProvider);
    final maxScores = ref.read(maxScoresProvider);

    // Max Scores
    maxRower = maxScores.maxRower;
    maxBenchHops = maxScores.maxBenchHops;
    maxKneeTuckPushUps = maxScores.maxKneeTuckPushUps;
    maxLateralHops = maxScores.maxLateralHops;
    maxBoxJumpBurpee = maxScores.maxBoxJumpBurpee;
    maxChinUps = maxScores.maxChinUps;
    maxSquatPress = maxScores.maxSquatPress;
    maxRussianTwist = maxScores.maxRussianTwist;
    maxDeadBallOverTheShoulder = maxScores.maxDeadBallOverTheShoulder;
    maxShuttleSprintLateralHop = maxScores.maxShuttleSprintLateralHop;
  }

  void getData() {
    final sc = _db.scoreCards.where().sortByDateDesc().findAllSync();

    scores = sc.map((card) {
      if (card.totalScore == 0.0) {
        final scores = [
          CoreUtils.calcScore(card.rower, maxRower),
          CoreUtils.calcScore(card.benchHops, maxBenchHops),
          CoreUtils.calcScore(card.kneeTuckPushUps, maxKneeTuckPushUps),
          CoreUtils.calcScore(card.lateralHops, maxLateralHops),
          CoreUtils.calcScore(card.boxJumpBurpee, maxBoxJumpBurpee),
          CoreUtils.calcScore(card.chinUps, maxChinUps),
          CoreUtils.calcScore(card.squatPress, maxSquatPress),
          CoreUtils.calcScore(card.russianTwist, maxRussianTwist),
          CoreUtils.calcScore(
            card.deadBallOverTheShoulder,
            maxDeadBallOverTheShoulder,
          ),
          CoreUtils.calcScore(
            card.shuttleSprintLateralHop,
            maxShuttleSprintLateralHop,
          ),
        ];
        card.totalScore = double.parse(
          scores.reduce((a, b) => a + b).toStringAsFixed(1),
        );

        return card;
      }
      return card;
    }).toList();

    chartData = scores.reversed.map((e) => e.totalScore.toDouble()).toList();
    status = HistoryStatus.loaded;
  }

  void updateChartData(ChartDataSource source) {
    activeChartDataSource = source;
    num amount;

    chartData = scores.reversed.map((e) {
      switch (source) {
        case ChartDataSource.rower:
          amount = e.rower;
          break;
        case ChartDataSource.benchHops:
          amount = e.benchHops;
          break;
        case ChartDataSource.kneeTuckPushUps:
          amount = e.kneeTuckPushUps;
          break;
        case ChartDataSource.lateralHops:
          amount = e.lateralHops;
          break;
        case ChartDataSource.boxJumpBurpee:
          amount = e.boxJumpBurpee;
          break;
        case ChartDataSource.chinUps:
          amount = e.chinUps;
          break;
        case ChartDataSource.squatPress:
          amount = e.squatPress;
          break;
        case ChartDataSource.russianTwist:
          amount = e.russianTwist;
          break;
        case ChartDataSource.deadBallOverTheShoulder:
          amount = e.deadBallOverTheShoulder;
          break;
        case ChartDataSource.shuttleSprintLateralHop:
          amount = e.shuttleSprintLateralHop;
          break;
        case ChartDataSource.total:
        default:
          amount = e.totalScore;
          break;
      }

      return amount.toDouble();
    }).toList();
  }

  void removeScore(ScoreCard score) async {
    await _db.writeTxn((isar) => isar.scoreCards.delete(score.id!));
    await Future.delayed(const Duration(milliseconds: 500));

    // Write scores to cloud when there is an active logged in user.
    final currentUser = _auth.currentUser?.uid;
    if (currentUser != null) {
      final cards = await _db.scoreCards.where().exportJson();
      await _firestore.collection("scores").doc(_auth.currentUser!.uid).set({
        "history": cards,
      });
    }
  }
}
