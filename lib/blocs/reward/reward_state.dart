import 'package:equatable/equatable.dart';
import '../../models/reward.dart';

abstract class RewardState extends Equatable {
  const RewardState();
  
  @override
  List<Object?> get props => [];
}

// Initial state
class RewardInitial extends RewardState {}

// Loading state
class RewardLoading extends RewardState {}

// Error state
class RewardError extends RewardState {
  final String message;
  
  const RewardError(this.message);
  
  @override
  List<Object> get props => [message];
}

// State for My Rewards
class MyRewardsLoaded extends RewardState {
  final List<Reward> rewards;
  final int totalPoints;
  final Pagination pagination;
  
  const MyRewardsLoaded({
    required this.rewards,
    required this.totalPoints,
    required this.pagination,
  });
  
  @override
  List<Object> get props => [rewards, totalPoints, pagination];
}

// State for Total Points
class TotalPointsLoaded extends RewardState {
  final int totalPoints;
  
  const TotalPointsLoaded(this.totalPoints);
  
  @override
  List<Object> get props => [totalPoints];
}

// State for Statistics
class StatisticsLoaded extends RewardState {
  final String period;
  final List<RewardStatistics> statistics;
  
  const StatisticsLoaded({
    required this.period,
    required this.statistics,
  });
  
  @override
  List<Object> get props => [period, statistics];
}

// State for Rankings
class RankingsLoaded extends RewardState {
  final List<UserRanking> rankings;
  
  const RankingsLoaded(this.rankings);
  
  @override
  List<Object> get props => [rankings];
}

// State for Reward Details
class RewardDetailsLoaded extends RewardState {
  final Reward reward;
  
  const RewardDetailsLoaded(this.reward);
  
  @override
  List<Object> get props => [reward];
}

// Admin states
class UserRewardsLoaded extends RewardState {
  final List<Reward> rewards;
  final Pagination pagination;
  final int userId;
  
  const UserRewardsLoaded({
    required this.rewards,
    required this.pagination,
    required this.userId,
  });
  
  @override
  List<Object> get props => [rewards, pagination, userId];
}

class RewardCreated extends RewardState {
  final Reward reward;
  
  const RewardCreated(this.reward);
  
  @override
  List<Object> get props => [reward];
}

class RewardUpdated extends RewardState {
  final Reward reward;
  
  const RewardUpdated(this.reward);
  
  @override
  List<Object> get props => [reward];
}

class RewardDeleted extends RewardState {
  final int rewardId;
  
  const RewardDeleted(this.rewardId);
  
  @override
  List<Object> get props => [rewardId];
}

class TransactionRewardProcessed extends RewardState {
  final Reward reward;
  final int transactionId;
  
  const TransactionRewardProcessed({
    required this.reward,
    required this.transactionId,
  });
  
  @override
  List<Object> get props => [reward, transactionId];
} 