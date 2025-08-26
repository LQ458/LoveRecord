import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../business_logic/providers/theme_provider.dart';

class ThemeBrightnessSelector extends ConsumerWidget {
  const ThemeBrightnessSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    
    return themeState.when(
      data: (state) => _buildSelector(context, ref, state.brightnessMode),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading theme')),
    );
  }

  Widget _buildSelector(BuildContext context, WidgetRef ref, ThemeBrightnessMode currentMode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: ThemeBrightnessMode.values.map((mode) {
            final isSelected = mode == currentMode;
            return Expanded(
              child: _buildOption(context, ref, mode, isSelected, isDark),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    WidgetRef ref,
    ThemeBrightnessMode mode,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => _onModeChanged(ref, mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF424242) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mode.icon,
              size: 24,
              color: isSelected
                  ? (isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121))
                  : (isDark ? const Color(0xFF757575) : Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              mode.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? (isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121))
                    : (isDark ? const Color(0xFF757575) : Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onModeChanged(WidgetRef ref, ThemeBrightnessMode mode) {
    ref.read(themeNotifierProvider.notifier).setBrightnessMode(mode);
  }
}

/// Alternative modern slider-style selector
class ThemeBrightnessSlider extends ConsumerWidget {
  const ThemeBrightnessSlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeNotifierProvider);
    
    return themeState.when(
      data: (state) => _buildSlider(context, ref, state.brightnessMode),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading theme')),
    );
  }

  Widget _buildSlider(BuildContext context, WidgetRef ref, ThemeBrightnessMode currentMode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = ThemeBrightnessMode.values.indexOf(currentMode);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Theme Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121),
              ),
            ),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D2D) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Animated background indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: (currentIndex * (MediaQuery.of(context).size.width - 64) / 3),
                  top: 4,
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 64) / 3 - 8,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF424242) : Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Option buttons
                Row(
                  children: ThemeBrightnessMode.values.asMap().entries.map((entry) {
                    final index = entry.key;
                    final mode = entry.value;
                    final isSelected = mode == currentMode;
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onModeChanged(ref, mode),
                        child: SizedBox(
                          height: 60,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                mode.icon,
                                size: 20,
                                color: isSelected
                                    ? (isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121))
                                    : (isDark ? const Color(0xFF757575) : Colors.grey.shade600),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                mode.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? (isDark ? const Color(0xFFE0E0E0) : const Color(0xFF212121))
                                      : (isDark ? const Color(0xFF757575) : Colors.grey.shade600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onModeChanged(WidgetRef ref, ThemeBrightnessMode mode) {
    ref.read(themeNotifierProvider.notifier).setBrightnessMode(mode);
  }
} 