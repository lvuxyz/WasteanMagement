class UserProfile {
  final BasicInfo basicInfo;
  final AccountStatus accountStatus;
  final TransactionStats transactionStats;
  final AdditionalData additionalData;
  final String timezone;

  UserProfile({
    required this.basicInfo,
    required this.accountStatus,
    required this.transactionStats,
    required this.additionalData,
    required this.timezone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] UserProfile.fromJson START with data: $json');
    print('[DEBUG] Basic info data: ${json['basic_info']}');
    print('[DEBUG] Transaction stats data: ${json['transaction_stats']}');

    final profile = UserProfile(
      basicInfo: BasicInfo.fromJson(json['basic_info']),
      accountStatus: AccountStatus.fromJson(json['account_status']),
      transactionStats: TransactionStats.fromJson(json['transaction_stats']),
      additionalData: AdditionalData.fromJson(json['additional_data']),
      timezone: json['timezone'] ?? 'UTC',
    );

    print('[DEBUG] UserProfile created successfully');
    print('[DEBUG] Basic info: ${profile.basicInfo.fullName}');
    print('[DEBUG] Total transactions: ${profile.transactionStats.totalTransactions}');
    
    return profile;
  }

  // Factory method to create UserProfile from User model
  factory UserProfile.fromUserModel(dynamic user) {
    // If the user has raw profile data, use it to create the profile
    if (user.rawProfileData != null) {
      return UserProfile.fromJson(user.rawProfileData);
    }
    
    // Fallback to creating a UserProfile from basic user data
    return UserProfile(
      basicInfo: BasicInfo(
        id: user.id ?? 0,
        fullName: user.fullName ?? '',
        username: user.username ?? '',
        email: user.email ?? '',
        phone: user.phone ?? '',
        address: user.address ?? '',
        roles: user.roles?.toList() ?? ['User'],
      ),
      accountStatus: AccountStatus(
        status: user.status ?? 'active',
        createdAt: user.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        lockUntil: null,
        loginAttempts: 0,
      ),
      transactionStats: TransactionStats(
        totalTransactions: 0,
        completedTransactions: '0',
        pendingTransactions: '0',
        rejectedTransactions: '0',
        verifiedTransactions: '0',
        totalQuantity: '0',
      ),
      additionalData: AdditionalData(
        wasteTypeStats: [],
        rewardStats: RewardStats(
          totalRewards: 0,
          totalPoints: '0',
          lastRewardDate: DateTime.now().toIso8601String(),
        ),
        latestTransactions: [],
      ),
      timezone: 'UTC',
    );
  }
}

class BasicInfo {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String address;
  final List<String> roles;

  BasicInfo({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.address,
    required this.roles,
  });

  factory BasicInfo.fromJson(Map<String, dynamic> json) {
    return BasicInfo(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AccountStatus {
  final String status;
  final String createdAt;
  final String? lockUntil;
  final int loginAttempts;

  AccountStatus({
    required this.status,
    required this.createdAt,
    this.lockUntil,
    required this.loginAttempts,
  });

  factory AccountStatus.fromJson(Map<String, dynamic> json) {
    return AccountStatus(
      status: json['status'] ?? 'unknown',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      lockUntil: json['lock_until'],
      loginAttempts: json['login_attempts'] ?? 0,
    );
  }
}

class TransactionStats {
  final int totalTransactions;
  final String completedTransactions;
  final String pendingTransactions;
  final String rejectedTransactions;
  final String verifiedTransactions;
  final String totalQuantity;

  TransactionStats({
    required this.totalTransactions,
    required this.completedTransactions,
    required this.pendingTransactions,
    required this.rejectedTransactions,
    required this.verifiedTransactions,
    required this.totalQuantity,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    print('[DEBUG] TransactionStats.fromJson with data: $json');
    
    // Convert any number types to string if needed
    String getStringValue(dynamic value) {
      if (value == null) return '0';
      if (value is String) return value;
      return value.toString();
    }
    
    // Convert any string or number types to int
    int getIntValue(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }
    
    final stats = TransactionStats(
      totalTransactions: getIntValue(json['total_transactions']),
      completedTransactions: getStringValue(json['completed_transactions']),
      pendingTransactions: getStringValue(json['pending_transactions']),
      rejectedTransactions: getStringValue(json['rejected_transactions']),
      verifiedTransactions: getStringValue(json['verified_transactions']),
      totalQuantity: getStringValue(json['total_quantity']),
    );
    
    print('[DEBUG] Created TransactionStats: totalTransactions=${stats.totalTransactions}');
    
    return stats;
  }
}

class AdditionalData {
  final List<WasteTypeStat> wasteTypeStats;
  final RewardStats rewardStats;
  final List<LatestTransaction> latestTransactions;

  AdditionalData({
    required this.wasteTypeStats,
    required this.rewardStats,
    required this.latestTransactions,
  });

  factory AdditionalData.fromJson(Map<String, dynamic> json) {
    return AdditionalData(
      wasteTypeStats: (json['waste_type_stats'] as List<dynamic>?)
              ?.map((e) => WasteTypeStat.fromJson(e))
              .toList() ??
          [],
      rewardStats: RewardStats.fromJson(json['reward_stats'] ?? {}),
      latestTransactions: (json['latest_transactions'] as List<dynamic>?)
              ?.map((e) => LatestTransaction.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class WasteTypeStat {
  final String wasteTypeName;
  final String totalQuantity;

  WasteTypeStat({
    required this.wasteTypeName,
    required this.totalQuantity,
  });

  factory WasteTypeStat.fromJson(Map<String, dynamic> json) {
    return WasteTypeStat(
      wasteTypeName: json['waste_type_name'] ?? 'Unknown',
      totalQuantity: json['total_quantity'] ?? '0',
    );
  }
}

class RewardStats {
  final int totalRewards;
  final String totalPoints;
  final String lastRewardDate;

  RewardStats({
    required this.totalRewards,
    required this.totalPoints,
    required this.lastRewardDate,
  });

  factory RewardStats.fromJson(Map<String, dynamic> json) {
    return RewardStats(
      totalRewards: json['total_rewards'] ?? 0,
      totalPoints: json['total_points'] ?? '0',
      lastRewardDate: json['last_reward_date'] ?? DateTime.now().toIso8601String(),
    );
  }
}

class LatestTransaction {
  final int transactionId;
  final String status;
  final String quantity;
  final String transactionDate;
  final String collectionPointName;
  final String wasteTypeName;

  LatestTransaction({
    required this.transactionId,
    required this.status,
    required this.quantity,
    required this.transactionDate,
    required this.collectionPointName,
    required this.wasteTypeName,
  });

  factory LatestTransaction.fromJson(Map<String, dynamic> json) {
    return LatestTransaction(
      transactionId: json['transaction_id'] ?? 0,
      status: json['status'] ?? 'unknown',
      quantity: json['quantity'] ?? '0',
      transactionDate: json['transaction_date'] ?? DateTime.now().toIso8601String(),
      collectionPointName: json['collection_point_name'] ?? 'Unknown',
      wasteTypeName: json['waste_type_name'] ?? 'Unknown',
    );
  }
} 