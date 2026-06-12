import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../../core/theme/klinik_colors.dart';
import '../../core/theme/klinik_typography.dart';
import '../../core/theme/klinik_animations.dart';

enum _NetState { online, offline, syncing }

class NetworkStatusIndicator extends StatefulWidget {
  const NetworkStatusIndicator({super.key});

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator>
    with SingleTickerProviderStateMixin {
  _NetState _state = _NetState.online;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: KlinikAnimations.syncPulse,
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.4, end: 1.0).animate(_pulseController);

    _checkInitialConnectivity();
    Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    if (!mounted) return;
    final isOffline = results.every((r) => r == ConnectivityResult.none);
    setState(() => _state = isOffline ? _NetState.offline : _NetState.online);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final String label;

    switch (_state) {
      case _NetState.online:
        dotColor = KlinikColors.online;
        label = 'En ligne';
      case _NetState.offline:
        dotColor = KlinikColors.offline;
        label = 'Hors ligne';
      case _NetState.syncing:
        dotColor = KlinikColors.syncing;
        label = 'Sync…';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: KlinikColors.surfaceVariant,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _state == _NetState.syncing
              ? AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => _Dot(color: dotColor, opacity: _pulse.value),
                )
              : _Dot(color: dotColor),
          const SizedBox(width: 6),
          Text(label, style: KlinikTypography.captionStrong()),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double opacity;

  const _Dot({required this.color, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
