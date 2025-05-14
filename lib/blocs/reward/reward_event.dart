import 'package:equatable/equatable.dart';

abstract class RewardEvent extends Equatable {
  const RewardEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyRewards extends RewardEvent {
  final int page;
  final int limit;
  final String? fromDate;
  final String? toDate;

  const LoadMyRewards({
    this.page = 1,
    this.limit = 10,
    this.fromDate,
    this.toDate,
  });

  @override
  List<Object?> get props => [page, limit, fromDate, toDate];
}

class LoadMyTotalPoints extends RewardEvent {}

class LoadMyStatistics extends RewardEvent {
  final String period;

  const LoadMyStatistics({this.period = 'monthly'});

  @override
  List<Object> get props => [period];
}

class LoadUserRankings extends RewardEvent {}

class LoadRewardDetails extends RewardEvent {
  final int rewardId;

  const LoadRewardDetails(this.rewardId);

  @override
  List<Object> get props => [rewardId];
}

// Admin events
class LoadUserRewards extends RewardEvent {
  final int userId;
  final int page;
  final int limit;

  const LoadUserRewards({
    required this.userId,
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object> get props => [userId, page, limit];
}

class CreateReward extends RewardEvent {
  final int userId;
  final int points;
  final int? transactionId;

  const CreateReward({
    required this.userId,
    required this.points,
    this.transactionId,
  });

  @override
  List<Object?> get props => [userId, points, transactionId];
}

class UpdateReward extends RewardEvent {
  final int rewardId;
  final int points;

  const UpdateReward({
    required this.rewardId,
    required this.points,
  });

  @override
  List<Object> get props => [rewardId, points];
}

class DeleteReward extends RewardEvent {
  final int rewardId;

  const DeleteReward(this.rewardId);

  @override
  List<Object> get props => [rewardId];
}

class ProcessTransactionReward extends RewardEvent {
  final int transactionId;

  const ProcessTransactionReward(this.transactionId);

  @override
  List<Object> get props => [transactionId];
} 