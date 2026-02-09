import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/todo_provider.dart';
import '../services/notification_service.dart';
import 'achievements_screen.dart';
import 'archive_screen.dart';
import 'trash_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FFF4),
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 알림 설정 섹션
              _buildSectionCard(
                emoji: '🔔',
                title: '알림',
                child: Column(
                  children: [
                    _buildSettingRow(
                      icon: settings.notificationEnabled ? '🔔' : '🔕',
                      title: '알림 받기',
                      subtitle: '마감일에 푸시 알림을 받습니다',
                      trailing: Switch(
                        value: settings.notificationEnabled,
                        onChanged: (value) async {
                          await settings.setNotificationEnabled(value);
                          if (!value) {
                            // 알림 끄면 모든 알림 취소
                            await NotificationService().cancelAllNotifications();
                          }
                        },
                        activeThumbColor: const Color(0xFF2E7D32),
                        activeTrackColor: const Color(0xFFA8E6CF),
                      ),
                    ),
                    if (settings.notificationEnabled) ...[
                      const Divider(height: 24),
                      _buildSettingRow(
                        icon: '🌙',
                        title: '방해금지 시간',
                        subtitle: settings.dndEnabled
                            ? settings.dndTimeRangeText
                            : '알림을 받지 않을 시간대를 설정합니다',
                        trailing: Switch(
                          value: settings.dndEnabled,
                          onChanged: (value) => settings.setDndEnabled(value),
                          activeThumbColor: const Color(0xFF2E7D32),
                          activeTrackColor: const Color(0xFFA8E6CF),
                        ),
                      ),
                      if (settings.dndEnabled) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const SizedBox(width: 36),
                            Expanded(
                              child: _buildTimeButton(
                                context,
                                label: '시작',
                                time: settings.dndStartTime,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: settings.dndStartTime,
                                  );
                                  if (picked != null) {
                                    await settings.setDndStartTime(picked);
                                  }
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('~', style: TextStyle(fontSize: 18)),
                            ),
                            Expanded(
                              child: _buildTimeButton(
                                context,
                                label: '종료',
                                time: settings.dndEndTime,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: settings.dndEndTime,
                                  );
                                  if (picked != null) {
                                    await settings.setDndEndTime(picked);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      _buildSettingRow(
                        icon: '📋',
                        title: '일일 요약 알림',
                        subtitle: settings.dailySummaryEnabled
                            ? '매일 ${_formatTime(settings.dailySummaryTime)}에 미완료 할일을 알려줍니다'
                            : '하루가 끝날 때 미완료 할일을 알려줍니다',
                        trailing: Switch(
                          value: settings.dailySummaryEnabled,
                          onChanged: (value) async {
                            final todoProvider = context.read<TodoProvider>();
                            await settings.setDailySummaryEnabled(value);
                            await todoProvider.scheduleDailySummaryNotification();
                          },
                          activeThumbColor: const Color(0xFF2E7D32),
                          activeTrackColor: const Color(0xFFA8E6CF),
                        ),
                      ),
                      if (settings.dailySummaryEnabled) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const SizedBox(width: 36),
                            Expanded(
                              child: _buildTimeButton(
                                context,
                                label: '알림 시간',
                                time: settings.dailySummaryTime,
                                onTap: () async {
                                  final todoProvider = context.read<TodoProvider>();
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: settings.dailySummaryTime,
                                  );
                                  if (picked != null) {
                                    await settings.setDailySummaryTime(picked);
                                    await todoProvider.scheduleDailySummaryNotification();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      _buildSettingRow(
                        icon: '🧪',
                        title: '알림 테스트',
                        subtitle: '알림이 정상 작동하는지 테스트합니다',
                        trailing: TextButton(
                          onPressed: () {
                            NotificationService().showTestNotification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('테스트 알림을 보냈습니다'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Text('테스트'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 데이터 관리 섹션
              _buildSectionCard(
                emoji: '📁',
                title: '데이터 관리',
                child: Consumer<TodoProvider>(
                  builder: (context, todoProvider, _) {
                    final archivedCount = todoProvider.getArchivedTodos().length;
                    final trashCount = todoProvider.getTrashTodos().length;

                    return Column(
                      children: [
                        _buildNavigationRow(
                          context,
                          icon: '📦',
                          title: '보관함',
                          subtitle: archivedCount > 0
                              ? '$archivedCount개의 보관된 할일'
                              : '완료된 할일을 보관합니다',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildNavigationRow(
                          context,
                          icon: '🗑️',
                          title: '휴지통',
                          subtitle: trashCount > 0
                              ? '$trashCount개의 삭제된 할일'
                              : '삭제된 할일은 30일 후 자동 삭제됩니다',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TrashScreen()),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // 업적 섹션
              _buildSectionCard(
                emoji: '🏆',
                title: '업적',
                child: _buildNavigationRow(
                  context,
                  icon: '🎖️',
                  title: '내 업적',
                  subtitle: '획득한 업적을 확인합니다',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 정보 섹션
              _buildSectionCard(
                emoji: 'ℹ️',
                title: '정보',
                child: Column(
                  children: [
                    _buildSettingRow(
                      icon: '📱',
                      title: '앱 버전',
                      subtitle: '1.0.0',
                      trailing: const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String emoji,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA8E6CF).withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildNavigationRow(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildTimeButton(
    BuildContext context, {
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FFF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA8E6CF)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$hour:$minute',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
