import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_event.dart';
import 'package:wasteanmagement/blocs/reward/reward_state.dart';
import 'package:wasteanmagement/services/reward_service.dart';
import '../../utils/app_logger.dart';

class RewardBloc extends Bloc<RewardEvent, RewardState> {
  final RewardService _rewardService;

  RewardBloc({required RewardService rewardService})
      : _rewardService = rewardService,
        super(RewardInitial()) {
    on<LoadMyRewards>(_onLoadMyRewards);
    on<LoadMyTotalPoints>(_onLoadMyTotalPoints);
    on<LoadMyStatistics>(_onLoadMyStatistics);
    on<LoadUserRankings>(_onLoadUserRankings);
    on<LoadRewardDetails>(_onLoadRewardDetails);

    // Admin events
    on<LoadUserRewards>(_onLoadUserRewards);
    on<CreateReward>(_onCreateReward);
    on<UpdateReward>(_onUpdateReward);
    on<DeleteReward>(_onDeleteReward);
    on<ProcessTransactionReward>(_onProcessTransactionReward);
  }

  void _onLoadMyRewards(LoadMyRewards event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final rewardsData = await _rewardService.getMyRewards(
        page: event.page,
        limit: event.limit,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(MyRewardsLoaded(
        rewards: rewardsData['rewards'],
        totalPoints: rewardsData['totalPoints'],
        pagination: rewardsData['pagination'],
      ));
    } catch (e) {
      AppLogger.e('Reward', 'Không tải được danh sách phần thưởng', error: e);
      emit(RewardError('Không thể tải điểm thưởng: $e'));
    }
  }

  void _onLoadMyTotalPoints(LoadMyTotalPoints event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final totalPoints = await _rewardService.getMyTotalPoints();

      emit(TotalPointsLoaded(totalPoints));
    } catch (e) {
      AppLogger.e('Reward', 'Không tải được tổng điểm', error: e);
      emit(RewardError('Không thể tải tổng điểm: $e'));
    }
  }

  void _onLoadMyStatistics(LoadMyStatistics event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final statisticsData = await _rewardService.getMyStatistics(period: event.period);

      emit(StatisticsLoaded(
        period: statisticsData['period'],
        statistics: statisticsData['statistics'],
      ));
    } catch (e) {
      AppLogger.e('Reward', 'Không tải được thống kê phần thưởng', error: e);
      emit(RewardError('Không thể tải thống kê điểm: $e'));
    }
  }

  void _onLoadUserRankings(LoadUserRankings event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final rankings = await _rewardService.getUserRankings();

      emit(RankingsLoaded(rankings));
    } catch (e) {
      AppLogger.e('Reward', 'Không tải được bảng xếp hạng', error: e);
      emit(RewardError('Không thể tải bảng xếp hạng: $e'));
    }
  }

  void _onLoadRewardDetails(LoadRewardDetails event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final reward = await _rewardService.getRewardDetails(event.rewardId);

      emit(RewardDetailsLoaded(reward));
    } catch (e) {
      AppLogger.e('Reward', 'Không tải được chi tiết phần thưởng', error: e);
      emit(RewardError('Không thể tải chi tiết điểm thưởng: $e'));
    }
  }

  // Admin methods

  void _onLoadUserRewards(LoadUserRewards event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final rewardsData = await _rewardService.getUserRewardsAdmin(
        event.userId,
        page: event.page,
        limit: event.limit,
      );

      emit(UserRewardsLoaded(
        rewards: rewardsData['rewards'],
        pagination: rewardsData['pagination'],
        userId: event.userId,
      ));
    } catch (e) {
      AppLogger.e('Reward', 'Không tải được phần thưởng của người dùng', error: e);
      emit(RewardError('Không thể tải điểm thưởng của người dùng: $e'));
    }
  }

  void _onCreateReward(CreateReward event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final reward = await _rewardService.createReward(
        event.userId,
        event.points,
        transactionId: event.transactionId,
      );

      emit(RewardCreated(reward));
    } catch (e) {
      AppLogger.e('Reward', 'Không tạo được phần thưởng', error: e);
      emit(RewardError('Không thể tạo điểm thưởng: $e'));
    }
  }

  void _onUpdateReward(UpdateReward event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final reward = await _rewardService.updateReward(
        event.rewardId,
        event.points,
      );

      emit(RewardUpdated(reward));
    } catch (e) {
      AppLogger.e('Reward', 'Không cập nhật được phần thưởng', error: e);
      emit(RewardError('Không thể cập nhật điểm thưởng: $e'));
    }
  }

  void _onDeleteReward(DeleteReward event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      await _rewardService.deleteReward(event.rewardId);

      emit(RewardDeleted(event.rewardId));
    } catch (e) {
      AppLogger.e('Reward', 'Không xóa được phần thưởng', error: e);
      emit(RewardError('Không thể xóa điểm thưởng: $e'));
    }
  }

  void _onProcessTransactionReward(ProcessTransactionReward event, Emitter<RewardState> emit) async {
    try {
      emit(RewardLoading());

      final reward = await _rewardService.processTransactionReward(event.transactionId);

      emit(TransactionRewardProcessed(
        reward: reward,
        transactionId: event.transactionId,
      ));
    } catch (e) {
      AppLogger.e('Reward', 'Không xử lý được điểm thưởng của giao dịch', error: e);
      emit(RewardError('Không thể xử lý điểm thưởng cho giao dịch: $e'));
    }
  }
} 