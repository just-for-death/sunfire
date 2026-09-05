import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../core/services/settings_service.dart';
import '../../core/widgets/sunfire_badge.dart';
import 'widgets/section_title.dart';
import 'widgets/settings_prop_tile.dart';
import 'widgets/settings_subpage_scaffold.dart';

class ReaderSettingsScreen extends StatefulWidget {
  const ReaderSettingsScreen({super.key});

  @override
  State<ReaderSettingsScreen> createState() => _ReaderSettingsScreenState();
}

class _ReaderSettingsScreenState extends State<ReaderSettingsScreen> {
  final SettingsService _settings = SettingsService.instance;

  void _showRadioDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F1F24),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((opt) {
              final isSelected = opt == currentValue;
              return ListTile(
                title: Text(opt),
                trailing: isSelected ? const Icon(Icons.check_rounded, color: Colors.greenAccent) : null,
                onTap: () {
                  onSelected(opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildPresetChip(String label, double speed) {
    final isSelected = (_settings.defaultAutoScrollSpeed - speed).abs() < 5.0;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white70)),
      selected: isSelected,
      selectedColor: primaryColor.withValues(alpha: 0.35),
      backgroundColor: const Color(0x1AFFFFFF),
      side: BorderSide(color: isSelected ? primaryColor : Colors.white24, width: 0.8),
      onSelected: (_) {
        HapticFeedback.selectionClick();
        _settings.defaultAutoScrollSpeed = speed;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return SettingsSubpageScaffold(
          title: 'Reader',
          body: ListView(
            children: [
              // ── 1. VIEWER & MODES ──
              const SectionTitle(title: 'Viewer & Modes'),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.view_day_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Default Reading Mode', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.readingMode, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Default Reading Mode',
                    options: const ['Long Strip', 'Long Strip (Gaps)', 'Paged LTR', 'Paged RTL (Manga)'],
                    currentValue: _settings.readingMode,
                    onSelected: (val) => _settings.readingMode = val,
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.palette_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Reader Background Theme', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.readerTheme, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Background Theme',
                    options: const ['Black', 'Dark Gray', 'White'],
                    currentValue: _settings.readerTheme,
                    onSelected: (val) => _settings.readerTheme = val,
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.filter_b_and_w_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Color Filter / Night Tint', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.colorFilter, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Color Filter',
                    options: const ['None', 'Invert Colors', 'Grayscale', 'Amber Tint', 'Sepia'],
                    currentValue: _settings.colorFilter,
                    onSelected: (val) => _settings.colorFilter = val,
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: const Icon(Icons.aspect_ratio_outlined),
                title: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    const Text('Default Image Scale', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    SunfireBadge.local(),
                  ],
                ),
                subtitle: Text(_settings.scaleType, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                onTap: () {
                  _showRadioDialog(
                    title: 'Default Image Scale',
                    options: const ['Fit Width', 'Fit Height', 'Fit Screen', 'Original'],
                    currentValue: _settings.scaleType,
                    onSelected: (val) => _settings.scaleType = val,
                  );
                },
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),

              // ── 2. NAVIGATION & INTERACTION ──
              const SectionTitle(title: 'Navigation & Gestures'),
              SettingsPropTile(
                title: '3-Zone Tap Navigation',
                subtitle: 'Tap left/right sides to turn pages, middle for reader overlay',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.tapZonesEnabled,
                onBoolChanged: (val) => _settings.tapZonesEnabled = val,
              ),
              SettingsPropTile(
                title: 'Invert Tap Zones',
                subtitle: 'Swap previous and next page tap areas',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.invertTapZones,
                onBoolChanged: (val) => _settings.invertTapZones = val,
              ),
              SettingsPropTile(
                title: 'Crop White Borders',
                subtitle: 'Trim page whitespace margins automatically',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.cropBorders,
                onBoolChanged: (val) => _settings.cropBorders = val,
              ),
              SettingsPropTile(
                title: 'Volume Key Page Turn',
                subtitle: 'Use physical volume rocker keys to flip pages',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.volumeKeyTurn,
                onBoolChanged: (val) => _settings.volumeKeyTurn = val,
              ),
              SettingsPropTile(
                title: 'Seamless Chapter Transitions',
                subtitle: 'Show transition cards between consecutive chapters',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.seamlessTransitions,
                onBoolChanged: (val) => _settings.seamlessTransitions = val,
              ),
              SettingsPropTile(
                title: 'Keep Screen Awake',
                subtitle: 'Prevent device display from sleeping while reading',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.keepScreenAwake,
                onBoolChanged: (val) => _settings.keepScreenAwake = val,
              ),

              const Divider(height: 1, color: Color(0x1AFFFFFF)),

              // ── 3. AUTO-SCROLL (WEBTOON / LONG STRIP) ──
              const SectionTitle(title: 'Auto-Scroll (Webtoon & Long Strip)'),

              // Live Speed Simulator Viewport
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: _AutoScrollLivePreview(speed: _settings.defaultAutoScrollSpeed),
              ),

              // Speed Presets Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quick Presets', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white70)),
                        Text(
                          '${_settings.defaultAutoScrollSpeed.round()} px/s',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildPresetChip('Slow (25 px/s)', 25.0),
                        _buildPresetChip('Normal (50 px/s)', 50.0),
                        _buildPresetChip('Fast (120 px/s)', 120.0),
                        _buildPresetChip('⚡ Faster (250 px/s)', 250.0),
                        _buildPresetChip('🚀 Turbo (500 px/s)', 500.0),
                        _buildPresetChip('💨 Hyper (800 px/s)', 800.0),
                      ],
                    ),
                  ],
                ),
              ),

              // Stepper + Slider Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0x22FFFFFF),
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.remove_rounded, size: 18),
                      tooltip: '-10 px/s',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _settings.defaultAutoScrollSpeed = (_settings.defaultAutoScrollSpeed - 10.0).clamp(10.0, 1000.0);
                      },
                    ),
                    Expanded(
                      child: Slider(
                        value: _settings.defaultAutoScrollSpeed.clamp(10.0, 1000.0),
                        min: 10.0,
                        max: 1000.0,
                        divisions: 99,
                        activeColor: primaryColor,
                        label: '${_settings.defaultAutoScrollSpeed.round()} px/s',
                        onChanged: (val) => _settings.defaultAutoScrollSpeed = val,
                      ),
                    ),
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0x22FFFFFF),
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      tooltip: '+10 px/s',
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _settings.defaultAutoScrollSpeed = (_settings.defaultAutoScrollSpeed + 10.0).clamp(10.0, 1000.0);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Behavioral Switches
              SettingsPropTile(
                title: 'Pause on Touch / Drag',
                subtitle: 'Temporarily pause scrolling while touching or inspecting panels',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.autoScrollPauseOnTouch,
                onBoolChanged: (val) => _settings.autoScrollPauseOnTouch = val,
              ),
              SettingsPropTile(
                title: 'Smooth Ease-In Acceleration',
                subtitle: 'Gradually ramp up scroll velocity over 400ms instead of an abrupt start',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.autoScrollSmoothEaseIn,
                onBoolChanged: (val) => _settings.autoScrollSmoothEaseIn = val,
              ),
              SettingsPropTile(
                title: 'Auto-Advance to Next Chapter',
                subtitle: 'Seamlessly continue auto-scrolling into the next chapter at bottom',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.autoScrollAutoNextChapter,
                onBoolChanged: (val) => _settings.autoScrollAutoNextChapter = val,
              ),
              SettingsPropTile(
                title: 'Show Floating HUD Controller',
                subtitle: 'Display the floating speed and pause pill during reading',
                scope: SettingScope.local,
                kind: SettingsPropKind.switchTile,
                boolValue: _settings.autoScrollShowFloatingHud,
                onBoolChanged: (val) => _settings.autoScrollShowFloatingHud = val,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AutoScrollLivePreview extends StatefulWidget {
  final double speed;
  const _AutoScrollLivePreview({required this.speed});

  @override
  State<_AutoScrollLivePreview> createState() => _AutoScrollLivePreviewState();
}

class _AutoScrollLivePreviewState extends State<_AutoScrollLivePreview> with SingleTickerProviderStateMixin {
  late final ScrollController _controller;
  Ticker? _ticker;
  Duration? _lastElapsed;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _startPreviewTicker();
  }

  void _startPreviewTicker() {
    _ticker = createTicker((elapsed) {
      if (!mounted || !_controller.hasClients) return;
      if (_lastElapsed == null) {
        _lastElapsed = elapsed;
        return;
      }
      final dt = (elapsed - _lastElapsed!).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;
      final safeDt = dt.clamp(0.0, 0.05);

      final max = _controller.position.maxScrollExtent;
      final cur = _controller.offset;
      if (max > 0 && cur >= max) {
        _controller.jumpTo(0);
        return;
      }
      final step = widget.speed * safeDt;
      _controller.jumpTo((cur + step).clamp(0.0, max));
    });
    _ticker?.start();
  }

  @override
  void dispose() {
    _ticker?.stop();
    _ticker?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF131318),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Stack(
        children: [
          ListView.builder(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 40,
            itemBuilder: (context, index) {
              final isCard = index % 3 == 0;
              if (isCard) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.15),
                        const Color(0x22FFFFFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_stories_rounded, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Webtoon Panel ${(index ~/ 3) + 1}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xDD0F0F14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryColor.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_circle_fill_rounded, size: 12, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE PREVIEW: ${widget.speed.round()} px/s',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
