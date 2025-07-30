import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../business_logic/providers/theme_provider.dart';
import '../../data/models/record.dart';
import '../themes/romantic_themes.dart';

/// Enhanced AI features widget with mood tracking and emotion visualization
class EnhancedAIFeaturesWidget extends ConsumerWidget {
  final List<Record> records;
  
  const EnhancedAIFeaturesWidget({
    super.key,
    required this.records,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMoodChart(context, romanticTheme),
        const SizedBox(height: 20),
        _buildEmotionInsights(context, romanticTheme),
        const SizedBox(height: 20),
        _buildMemoryStats(context, romanticTheme),
      ],
    );
  }
  
  Widget _buildMoodChart(BuildContext context, RomanticThemeData theme) {
    final moodData = _analyzeMoodData();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  '情感趋势',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: moodData,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: theme.gradient,
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: theme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: theme.gradient.map((c) => c.withOpacity(0.3)).toList(),
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmotionInsights(BuildContext context, RomanticThemeData theme) {
    final emotions = _analyzeEmotions();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  '情感洞察',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: emotions.entries.map((entry) {
                    final color = _getEmotionColor(entry.key, theme);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}%',
                      color: color,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 80,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: emotions.entries.map((entry) {
                final color = _getEmotionColor(entry.key, theme);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${entry.key} (${entry.value}%)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMemoryStats(BuildContext context, RomanticThemeData theme) {
    final stats = _calculateMemoryStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: theme.primary),
                const SizedBox(width: 8),
                Text(
                  '回忆统计',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2,
              children: stats.entries.map((entry) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: theme.gradient.map((c) => c.withOpacity(0.1)).toList(),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  List<FlSpot> _analyzeMoodData() {
    if (records.isEmpty) return [];
    
    // Simulate mood analysis over time
    final spots = <FlSpot>[];
    final sortedRecords = List<Record>.from(records)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    for (int i = 0; i < sortedRecords.length && i < 20; i++) {
      final record = sortedRecords[i];
      final mood = _calculateMoodScore(record);
      spots.add(FlSpot(i.toDouble(), mood));
    }
    
    return spots;
  }
  
  double _calculateMoodScore(Record record) {
    // Simple mood analysis based on content keywords
    final content = record.content.toLowerCase();
    double score = 5.0; // Neutral
    
    // Positive keywords
    if (content.contains('开心') || content.contains('快乐') || content.contains('幸福')) {
      score += 2.0;
    }
    if (content.contains('爱') || content.contains('喜欢') || content.contains('浪漫')) {
      score += 1.5;
    }
    if (content.contains('美好') || content.contains('温馨') || content.contains('甜蜜')) {
      score += 1.0;
    }
    
    // Negative keywords
    if (content.contains('伤心') || content.contains('难过') || content.contains('失落')) {
      score -= 2.0;
    }
    if (content.contains('生气') || content.contains('愤怒')) {
      score -= 1.5;
    }
    if (content.contains('疲惫') || content.contains('累')) {
      score -= 1.0;
    }
    
    return score.clamp(1.0, 10.0);
  }
  
  Map<String, int> _analyzeEmotions() {
    if (records.isEmpty) {
      return {
        '幸福': 40,
        '平静': 30,
        '兴奋': 20,
        '其他': 10,
      };
    }
    
    final emotions = <String, int>{};
    
    for (final record in records) {
      final content = record.content.toLowerCase();
      
      if (content.contains('开心') || content.contains('快乐') || content.contains('幸福')) {
        emotions['幸福'] = (emotions['幸福'] ?? 0) + 1;
      } else if (content.contains('平静') || content.contains('安静') || content.contains('舒服')) {
        emotions['平静'] = (emotions['平静'] ?? 0) + 1;
      } else if (content.contains('兴奋') || content.contains('激动') || content.contains('期待')) {
        emotions['兴奋'] = (emotions['兴奋'] ?? 0) + 1;
      } else if (content.contains('伤心') || content.contains('难过') || content.contains('失落')) {
        emotions['忧伤'] = (emotions['忧伤'] ?? 0) + 1;
      } else if (content.contains('生气') || content.contains('愤怒')) {
        emotions['愤怒'] = (emotions['愤怒'] ?? 0) + 1;
      } else {
        emotions['其他'] = (emotions['其他'] ?? 0) + 1;
      }
    }
    
    // Convert to percentages
    final total = emotions.values.fold(0, (a, b) => a + b);
    if (total == 0) return {'其他': 100};
    
    final percentages = <String, int>{};
    emotions.forEach((key, value) {
      percentages[key] = ((value / total) * 100).round();
    });
    
    return percentages;
  }
  
  Map<String, int> _calculateMemoryStats() {
    return {
      '总记录数': records.length,
      '本月记录': records.where((r) {
        final now = DateTime.now();
        return r.createdAt.year == now.year && r.createdAt.month == now.month;
      }).length,
      '媒体文件': records.fold(0, (sum, r) => sum + r.mediaFiles.length),
      '标签数量': records.expand((r) => r.tags).toSet().length,
    };
  }
  
  Color _getEmotionColor(String emotion, RomanticThemeData theme) {
    switch (emotion) {
      case '幸福':
        return Colors.amber;
      case '平静':
        return Colors.blue;
      case '兴奋':
        return Colors.orange;
      case '忧伤':
        return Colors.indigo;
      case '愤怒':
        return Colors.red;
      default:
        return theme.secondary;
    }
  }
}

/// Mood tracking input widget
class MoodTrackerWidget extends ConsumerStatefulWidget {
  final Function(String mood, double intensity) onMoodSubmitted;
  
  const MoodTrackerWidget({
    super.key,
    required this.onMoodSubmitted,
  });
  
  @override
  ConsumerState<MoodTrackerWidget> createState() => _MoodTrackerWidgetState();
}

class _MoodTrackerWidgetState extends ConsumerState<MoodTrackerWidget> {
  String _selectedMood = '😊';
  double _intensity = 5.0;
  
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'name': '开心', 'color': Colors.amber},
    {'emoji': '😍', 'name': '爱意', 'color': Colors.pink},
    {'emoji': '😌', 'name': '平静', 'color': Colors.blue},
    {'emoji': '🥰', 'name': '甜蜜', 'color': Colors.pinkAccent},
    {'emoji': '😢', 'name': '伤心', 'color': Colors.indigo},
    {'emoji': '😠', 'name': '生气', 'color': Colors.red},
    {'emoji': '😴', 'name': '疲惫', 'color': Colors.grey},
    {'emoji': '🤗', 'name': '温暖', 'color': Colors.orange},
  ];
  
  @override
  Widget build(BuildContext context) {
    final romanticTheme = ref.watch(currentRomanticThemeDataProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mood, 
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFFE0E0E0) 
                      : const Color(0xFF212121)
                ),
                const SizedBox(width: 8),
                Text(
                  '今天的心情如何？',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mood selection
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['emoji'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = mood['emoji'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (mood['color'] as Color).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? mood['color'] as Color
                            : (Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF3A3A3A) 
                                : const Color(0xFFE0E0E0)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          mood['emoji'],
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected 
                                ? mood['color'] as Color
                                : (Theme.of(context).brightness == Brightness.dark 
                                    ? const Color(0xFFB0B0B0) 
                                    : const Color(0xFF757575)),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Intensity slider
            Text(
              '强度: ${_intensity.toInt()}/10',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: _intensity,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFFE0E0E0) 
                  : const Color(0xFF212121),
              inactiveColor: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF3A3A3A) 
                  : const Color(0xFFE0E0E0),
              onChanged: (value) {
                setState(() {
                  _intensity = value;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final moodName = _moods.firstWhere((m) => m['emoji'] == _selectedMood)['name'];
                  widget.onMoodSubmitted(moodName, _intensity);
                },
                icon: const Icon(Icons.add),
                label: const Text('记录心情'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFF424242) 
                      : const Color(0xFFF5F5F5),
                  foregroundColor: Theme.of(context).brightness == Brightness.dark 
                      ? const Color(0xFFE0E0E0) 
                      : const Color(0xFF212121),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}