import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/common/custom_button.dart';
import '../generated/l10n.dart';

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
    final l10n = S.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          l10n.notificationSettings,
          style: const TextStyle(color: Colors.white),
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
                title: Text(
                  l10n.allNotifications,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  l10n.allNotificationsDescription,
                  style: const TextStyle(
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
              Text(
                l10n.notificationTypes,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Specific notification types
              SwitchListTile(
                title: Text(l10n.collectionReminders),
                subtitle: Text(l10n.collectionRemindersDescription),
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
                title: Text(l10n.recyclingTips),
                subtitle: Text(l10n.recyclingTipsDescription),
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
                title: Text(l10n.scheduleChanges),
                subtitle: Text(l10n.scheduleChangesDescription),
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
                title: Text(l10n.recyclingEvents),
                subtitle: Text(l10n.recyclingEventsDescription),
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
                title: Text(l10n.rewardsAndOffers),
                subtitle: Text(l10n.rewardsAndOffersDescription),
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
                title: Text(l10n.systemUpdates),
                subtitle: Text(l10n.systemUpdatesDescription),
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
              Text(
                l10n.notificationChannels,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              SwitchListTile(
                title: Text(l10n.pushNotifications),
                subtitle: Text(l10n.pushNotificationsDescription),
                value: _pushNotifications,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _pushNotifications = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              SwitchListTile(
                title: Text(l10n.emailNotifications),
                subtitle: Text(l10n.emailNotificationsDescription),
                value: _emailNotifications,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _emailNotifications = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              SwitchListTile(
                title: Text(l10n.smsNotifications),
                subtitle: Text(l10n.smsNotificationsDescription),
                value: _smsNotifications,
                activeColor: AppColors.primaryGreen,
                onChanged: _allNotifications ? (value) {
                  setState(() {
                    _smsNotifications = value;
                    _settingsChanged = true;
                  });
                } : null,
              ),

              const Divider(),
              const SizedBox(height: 10),

              // Time range settings
              Text(
                l10n.notificationTimeRange,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // Time range selection
              Row(
                children: [
                  Expanded(
                    child: _buildTimeSelector(
                      l10n.from,
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
                      l10n.to,
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
                text: l10n.saveSettings,
                isLoading: _isLoading,
                onPressed: _settingsChanged ? () {
                  _saveSettings();
                } : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSelector(
      String label,
      TimeOfDay time,
      Function(TimeOfDay) onTimeSelected,
      ) {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
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

        if (selectedTime != null) {
          onTimeSelected(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.access_time,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final l10n = S.of(context);
    
    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _settingsChanged = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsSaved),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}