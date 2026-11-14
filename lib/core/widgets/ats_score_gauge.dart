import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../extensions/size_extensions.dart';
import '../theme/app_text_styles.dart';

/// Animated Circular ATS Compatibility Gauge Widget.
class AtsScoreGauge extends StatefulWidget {
  final int score;
  final double? size;
  final String label;

  const AtsScoreGauge({
    super.key,
    required this.score,
    this.size,
    this.label = 'ATS Score',
  });

  @override
  State<AtsScoreGauge> createState() => _AtsScoreGaugeState();
}

class _AtsScoreGaugeState extends State<AtsScoreGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final targetProgress = (widget.score / 100.0).clamp(0.0, 1.0);
    _animation = Tween<double>(begin: 0.0, end: targetProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 75) return AppColors.scoreHigh;
    if (score >= 50) return AppColors.scoreMedium;
    return AppColors.scoreLow;
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(widget.score);
    final gaugeSize = widget.size ?? (context.screenWidth * 0.34);

    return Semantics(
      label: '${widget.label} is ${widget.score}%',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final animatedScore = (_animation.value * 100).round();

            return SizedBox(
              width: gaugeSize,
              height: gaugeSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Track
                  SizedBox(
                    width: gaugeSize,
                    height: gaugeSize,
                    child: const CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 10,
                      color: AppColors.secondarySurface,
                    ),
                  ),
                  // Animated Progress Arc
                  SizedBox(
                    width: gaugeSize,
                    height: gaugeSize,
                    child: CircularProgressIndicator(
                      value: _animation.value,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: scoreColor,
                    ),
                  ),
                  // Center Score & Label
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$animatedScore%',
                        style: AppTextStyles.screenHeading.copyWith(
                          fontSize: gaugeSize * 0.26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mainText,
                        ),
                      ),
                      Text(
                        widget.label,
                        style: AppTextStyles.metadata.copyWith(
                          fontSize: gaugeSize * 0.09,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
