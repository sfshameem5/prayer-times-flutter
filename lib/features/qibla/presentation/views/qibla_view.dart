import 'package:flutter/material.dart';
import 'package:prayer_times/config/theme.dart';
import 'package:prayer_times/features/qibla/presentation/viewmodels/qibla_view_model.dart';
import 'package:prayer_times/features/qibla/presentation/widgets/compass_widget.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
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
                    AppLocalizations.of(context)!.qiblaTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  if (!viewModel.isUnsupported)
                    Text(
                      AppLocalizations.of(context)!.qiblaSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.qiblaUnsupported,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  const Spacer(),
                  if (!viewModel.isUnsupported)
                    CompassWidget(
                      isDark: isDark,
                      rotationAngle: viewModel.rotationAngle,
                      qiblaDirection: viewModel.qiblaDirection,
                      deviceHeading: viewModel.deviceHeading,
                      hasCompassData: viewModel.hasCompassData,
                      isAligned: viewModel.isAligned,
                      angleDifference: viewModel.angleDifference,
                    )
                  else
                    Icon(
                      Icons.do_not_disturb_alt_rounded,
                      size: 96,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppTheme.darkCardGradient
                          : AppTheme.lightCardGradient,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.08,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.qiblaLocationLabel.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  viewModel.locationName,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          VerticalDivider(
                            width: 32,
                            thickness: 1,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.qiblaBearingLabel.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${viewModel.qiblaDirection.toStringAsFixed(1)}° ${viewModel.qiblaDirectionLabel(viewModel.qiblaDirection)}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            viewModel.needsCalibration
                                ? AppLocalizations.of(
                                    context,
                                  )!.qiblaCalibrateNeeded
                                : AppLocalizations.of(
                                    context,
                                  )!.qiblaCalibrateGeneral,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black26,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
