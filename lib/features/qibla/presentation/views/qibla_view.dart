import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/qibla/presentation/viewmodels/qibla_view_model.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/compass_widget.dart';
import 'package:provider/provider.dart';

class QiblaView extends StatelessWidget {
  const QiblaView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => QiblaViewModel(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Consumer<QiblaViewModel>(
            builder: (context, viewModel, child) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Qibla Direction',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Point your device towards the Qibla',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const Spacer(),
                  CompassWidget(
                    isDark: isDark,
                    rotationAngle: viewModel.rotationAngle,
                    qiblaDirection: viewModel.qiblaDirection,
                    deviceHeading: viewModel.deviceHeading,
                    hasCompassData: viewModel.hasCompassData,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppTheme.darkCardGradient
                          : AppTheme.lightCardGradient,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppTheme.appOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              viewModel.locationName,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Qibla: ${viewModel.qiblaDirection.toStringAsFixed(1)}° ${viewModel.qiblaDirectionLabel(viewModel.qiblaDirection)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark ? Colors.white60 : Colors.black45,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
