import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../providers/forest_provider.dart';
import '../widgets/swaying_plant.dart';

class ForestScreen extends StatelessWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 숲'),
      ),
      body: Consumer<ForestProvider>(
        builder: (context, forestProvider, _) {
          if (!forestProvider.initialized) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              return Column(
                children: [
                  // 통계 카드
                  _buildStatsCard(forestProvider, isWide),

                  // 현재 자라는 식물
                  if (forestProvider.currentPlant != null)
                    _buildCurrentPlantSection(
                      forestProvider.currentPlant!,
                      constraints.maxWidth,
                    ),

                  // 숲 뷰
                  Expanded(
                    child: _buildForestView(context, forestProvider),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(ForestProvider provider, bool isWide) {
    return Card(
      margin: EdgeInsets.all(isWide ? 20 : 16),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 20 : 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: '완료한 할일',
                  value: '${provider.totalTodosCompleted}',
                  color: const Color(0xFF66BB6A),
                  isWide: isWide,
                ),
                _buildStatItem(
                  icon: Icons.park,
                  label: '다 자란 식물',
                  value: '${provider.totalPlantsGrown}',
                  color: const Color(0xFF4CAF50),
                  isWide: isWide,
                ),
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: '연속 성장',
                  value: '${provider.currentStreak}일',
                  color: const Color(0xFFFF9800),
                  isWide: isWide,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPlantCount(
                  '풀',
                  provider.grassCount,
                  const Color(0xFF81C784),
                ),
                _buildPlantCount(
                  '꽃',
                  provider.flowerCount,
                  const Color(0xFFE91E63),
                ),
                _buildPlantCount(
                  '나무',
                  provider.treeCount,
                  const Color(0xFF4CAF50),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isWide,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: isWide ? 32 : 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isWide ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isWide ? 14 : 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPlantCount(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPlantSection(Plant plant, double screenWidth) {
    // 반응형 크기
    final plantSize = screenWidth > 600 ? 90.0 : 70.0;
    final horizontalMargin = screenWidth > 600 ? 20.0 : 16.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA5D6A7),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 식물 아이콘 (살랑살랑)
          SizedBox(
            width: plantSize,
            height: plantSize,
            child: SwayingPlant(plant: plant, size: plantSize, showGlow: true),
          ),
          const SizedBox(width: 16),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 자라는 ${plant.typeName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plant.growthStageName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                // 진행률 바
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: plant.growthProgress,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF66BB6A),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${plant.growthStage}/${plant.maxGrowthStage}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForestView(BuildContext context, ForestProvider provider) {
    final plants = provider.forestPlants;

    if (plants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.park_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '아직 숲에 식물이 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '할일을 완료해서 식물을 키워보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD), // 하늘
            Color(0xFFBBDEFB), // 하늘 아래
            Color(0xFFC8E6C9), // 잔디
            Color(0xFFA5D6A7), // 땅
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: _buildForestWithSwayingPlants(plants, constraints),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForestWithSwayingPlants(
      List<Plant> plants, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    return Stack(
      children: plants.asMap().entries.map((entry) {
        final index = entry.key;
        final plant = entry.value;

        // 반응형 위치 계산 - X는 가로 퍼센트
        final x = width * plant.positionX / 100;

        // 반응형 크기 계산
        double baseSize;
        switch (plant.type) {
          case PlantType.grass:
            baseSize = width * 0.08;
            break;
          case PlantType.flower:
            baseSize = width * 0.1;
            break;
          case PlantType.tree:
            baseSize = width * 0.15;
            break;
        }

        // 최소/최대 크기 제한
        final plantSize = baseSize.clamp(30.0, 100.0);

        // Y 위치: 하단 바닥 기준으로 위로 올라감
        // positionY가 30~70 범위이므로, 이를 0~40% 높이로 변환
        final yOffset = height * (plant.positionY - 30) / 100;

        return Positioned(
          left: x - plantSize / 2,
          bottom: yOffset, // bottom 기준으로 배치 (바닥에서 위로)
          child: SwayingPlant(
            plant: plant,
            size: plantSize,
            delayMs: index * 150,
          ),
        );
      }).toList(),
    );
  }
}
