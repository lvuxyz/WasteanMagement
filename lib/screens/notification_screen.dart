import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Notification settings
  bool _allNotifications = true;
  bool _collectionReminders = true;
  bool _recyclingTips = true;
  bool _scheduleChanges = true;
  bool _recyclingEvents = true;
  bool _rewards = true;
  bool _systemUpdates = false;

  // Notification channels
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  // Time range settings
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 20, minute: 0);

  bool _isLoading = false;
  bool _settingsChanged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: const Text(
          'Cài đặt thông báo',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Master notification switch
              SwitchListTile(
                title: const Text(
                  'Tất cả thông báo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Bật/tắt tất cả thông báo từ ứng dụng',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                value: _allNotifications,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _allNotifications = value;
                    _settingsChanged = true;

                    // Update all other notifications if master switch is turned off
                    if (!value) {
                      _collectionReminders = false;
                      _recyclingTips = false;
                      _scheduleChanges = false;
                      _recyclingEvents = false;
                      _rewards = false;
                      _systemUpdates = false;
                    }
                  });
                },
              ),

              const Divider(),
              const SizedBox(height: 10),

              // Section title
              const Text(
                'Loại thông báo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Specific notification types
              SwitchListTile(
                title: const Text('Nhắc nhở thu gom'),
                subtitle: const Text('Thông báo lịch thu gom rác theo lịch'),
                value: _allNotifications && _collectionReminders,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _collectionReminders = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              SwitchListTile(
                title: const Text('Mẹo tái chế'),
                subtitle: const Text('Nhận thông tin và mẹo về tái chế hàng tuần'),
                value: _allNotifications && _recyclingTips,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _recyclingTips = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              SwitchListTile(
                title: const Text('Thay đổi lịch trình'),
                subtitle: const Text('Thông báo khi có thay đổi trong lịch thu gom'),
                value: _allNotifications && _scheduleChanges,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _scheduleChanges = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              SwitchListTile(
                title: const Text('Sự kiện tái chế'),
                subtitle: const Text('Thông báo về các sự kiện tái chế gần bạn'),
                value: _allNotifications && _recyclingEvents,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _recyclingEvents = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              SwitchListTile(
                title: const Text('Điểm thưởng & Ưu đãi'),
                subtitle: const Text('Thông báo về điểm thưởng và các ưu đãi mới'),
                value: _allNotifications && _rewards,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _rewards = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              SwitchListTile(
                title: const Text('Cập nhật hệ thống'),
                subtitle: const Text('Thông báo về các cập nhật ứng dụng và bảo trì'),
                value: _allNotifications && _systemUpdates,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _systemUpdates = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              const Divider(),
              const SizedBox(height: 10),

              // Notification channels
              const Text(
                'Kênh thông báo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              SwitchListTile(
                title: const Text('Thông báo đẩy'),
                subtitle: const Text('Nhận thông báo trực tiếp trên thiết bị'),
                value: _pushNotifications,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                    _settingsChanged = true;
                  });
                },
              ),

              SwitchListTile(
                title: const Text('Email'),
                subtitle: const Text('Nhận thông báo qua email'),
                value: _emailNotifications,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                    _settingsChanged = true;
                  });
                },
              ),

              SwitchListTile(
                title: const Text('SMS'),
                subtitle: const Text('Nhận thông báo qua tin nhắn SMS'),
                value: _smsNotifications,
                activeColor: AppColors.primaryGreen,
                onChanged: (value) {
                  setState(() {
                    _smsNotifications = value;
                    _settingsChanged = true;
                  });
                },
              ),

              const Divider(),
              const SizedBox(height: 10),

              // Time range settings
              const Text(
                'Khung giờ thông báo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Chỉ nhận thông báo trong khung giờ này',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: _buildTimeSelector(
                      'Từ',
                      _startTime,
                          (newTime) {
                        setState(() {
                          _startTime = newTime;
                          _settingsChanged = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTimeSelector(
                      'Đến',
                      _endTime,
                          (newTime) {
                        setState(() {
                          _endTime = newTime;
                          _settingsChanged = true;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Save button
              CustomButton(
                text: 'Lưu cài đặt',
                isLoading: _isLoading,
                onPressed: _settingsChanged ? () {
                  // Implement actual save settings logic
                  _mockSaveSettings();
                } : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This is just for UI mockup - would be replaced with real API call
  void _mockSaveSettings() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
        _settingsChanged = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cài đặt thông báo đã được lưu thành công'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    });
  }

  Widget _buildTimeSelector(String label, TimeOfDay time, Function(TimeOfDay) onTimeChanged) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryGreen,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedTime != null && pickedTime != time) {
          onTimeChanged(pickedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.access_time,
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}