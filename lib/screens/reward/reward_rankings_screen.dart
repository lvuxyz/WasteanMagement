import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_bloc.dart';
import 'package:wasteanmagement/blocs/reward/reward_event.dart';
import 'package:wasteanmagement/blocs/reward/reward_state.dart';
import 'package:wasteanmagement/models/reward.dart';
import 'package:wasteanmagement/utils/app_colors.dart';
import 'package:wasteanmagement/widgets/common/loading_indicator.dart';
import 'package:wasteanmagement/widgets/common/error_view.dart';

class RewardRankingsScreen extends StatefulWidget {
  const RewardRankingsScreen({Key? key}) : super(key: key);

  @override
  State<RewardRankingsScreen> createState() => _RewardRankingsScreenState();
}

class _RewardRankingsScreenState extends State<RewardRankingsScreen> {
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  void _loadRankings() {
    setState(() {
      _isLoading = true;
    });
    
    context.read<RewardBloc>().add(LoadUserRankings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: BlocConsumer<RewardBloc, RewardState>(
        listener: (context, state) {
          if (state is RankingsLoaded || state is RewardError) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        builder: (context, state) {
          if (_isLoading) {
            return const Center(child: LoadingIndicator());
          } else if (state is RankingsLoaded) {
            return _buildRankingsList(state.rankings);
          } else if (state is RewardError) {
            return ErrorView(
              message: state.message,
              onRetry: _loadRankings,
              title: 'Lỗi tải dữ liệu',
            );
          }
          // Initial state or unexpected state
          return const Center(child: LoadingIndicator());
        },
      ),
    );
  }

  Widget _buildRankingsList(List<UserRanking> rankings) {
    if (rankings.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadRankings();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),
          SliverToBoxAdapter(
            child: _buildTopThreeUsers(rankings.take(3).toList()),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Skip the top 3 users as they're displayed above
                final rankingIndex = index + 3;
                if (rankingIndex < rankings.length) {
                  final ranking = rankings[rankingIndex];
                  return _buildRankingItem(ranking);
                }
                return null;
              },
              childCount: (rankings.length - 3).clamp(0, rankings.length),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu xếp hạng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tích điểm để lên bảng xếp hạng',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: const Text(
        'Top người dùng tích điểm cao nhất',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  Widget _buildTopThreeUsers(List<UserRanking> topRankings) {
    // If less than 3 users, pad the list
    final paddedRankings = List.generate(3, (index) {
      if (index < topRankings.length) {
        return topRankings[index];
      } else {
        return null;
      }
    });

    return Container(
      height: 220, // Increased height for better display
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          if (paddedRankings[1] != null)
            _buildTopUserItem(
              paddedRankings[1]!,
              '2',
              Colors.grey.shade400,
              0.85,
            )
          else
            _buildEmptyTopUserItem(0.85, '2'),
            
          // First place
          if (paddedRankings[0] != null)
            _buildTopUserItem(
              paddedRankings[0]!,
              '1',
              Colors.amber,
              1.0,
            )
          else
            _buildEmptyTopUserItem(1.0, '1'),
            
          // Third place
          if (paddedRankings[2] != null)
            _buildTopUserItem(
              paddedRankings[2]!,
              '3',
              Colors.brown.shade300,
              0.75,
            )
          else
            _buildEmptyTopUserItem(0.75, '3'),
        ],
      ),
    );
  }

  Widget _buildTopUserItem(UserRanking ranking, String position, Color color, double scale) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top section with avatar and crown for first place
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 30 * scale,
                  backgroundColor: color.withOpacity(0.2),
                  child: CircleAvatar(
                    radius: 28 * scale,
                    backgroundColor: Colors.white,
                    child: Text(
                      ranking.name?.substring(0, 1).toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Crown for first place
              if (position == '1')
                Positioned(
                  top: -15 * scale,
                  child: Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 24 * scale,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Position badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12 * scale),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              position,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14 * scale,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Podium and user info
          Flexible(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 8 * scale),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8 * scale),
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // User name
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                    child: Text(
                      ranking.name ?? 'Người dùng ${ranking.userId}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12 * scale,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Points display
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, color: color, size: 14 * scale),
                        SizedBox(width: 4 * scale),
                        Text(
                          '${ranking.totalPoints}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13 * scale,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTopUserItem(double scale, String position) {
    final Color color = position == '1'
        ? Colors.amber.withOpacity(0.5)
        : position == '2'
            ? Colors.grey.shade400.withOpacity(0.5)
            : Colors.brown.shade300.withOpacity(0.5);
            
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty avatar
          CircleAvatar(
            radius: 30 * scale,
            backgroundColor: Colors.grey.withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: Colors.grey[300],
              size: 28 * scale,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Position badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Text(
              position,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14 * scale,
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Empty podium
          Flexible(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 8 * scale),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(8 * scale),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chưa có',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12 * scale,
                    ),
                  ),
                  
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(UserRanking ranking) {
    // Background colors for different positions
    Color getBackgroundColor() {
      if (ranking.rank <= 3) {
        return Colors.amber.withOpacity(0.05);
      }
      if (ranking.rank <= 10) {
        return AppColors.primaryGreen.withOpacity(0.05);
      }
      return Colors.transparent;
    }

    Color getPositionColor() {
      if (ranking.rank == 1) return Colors.amber;
      if (ranking.rank == 2) return Colors.grey.shade400;
      if (ranking.rank == 3) return Colors.brown.shade300;
      if (ranking.rank <= 10) return AppColors.primaryGreen;
      return Colors.grey[600]!;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getPositionColor().withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: getPositionColor().withOpacity(0.3),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${ranking.rank}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: getPositionColor(),
            ),
          ),
        ),
        title: Text(
          ranking.name ?? 'Người dùng ${ranking.userId}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: getPositionColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                color: getPositionColor(),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${ranking.totalPoints}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: getPositionColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 