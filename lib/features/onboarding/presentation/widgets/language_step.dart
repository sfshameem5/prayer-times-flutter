import 'package:flutter/material.dart';
import 'package:prayer_times/l10n/app_localizations.dart';
import 'package:prayer_times/config/theme.dart';

class LanguageStep extends StatelessWidget {
  final Locale selectedLocale;
  final ValueChanged<Locale> onLocaleSelected;

  const LanguageStep({
    super.key,
    required this.selectedLocale,
    required this.onLocaleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final strings = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(Icons.language_outlined, size: 64, color: AppTheme.appOrange),
          const SizedBox(height: 24),
          Text(
            strings.onboardingLanguageTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            strings.onboardingLanguageSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _LanguageTile(
            title: strings.languageEnglish,
            locale: const Locale('en'),
            selectedLocale: selectedLocale,
            onTap: onLocaleSelected,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _LanguageTile(
            title: strings.languageTamil,
            locale: const Locale('ta'),
            selectedLocale: selectedLocale,
            onTap: onLocaleSelected,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _LanguageTile(
            title: strings.languageSinhala,
            locale: const Locale('si'),
            selectedLocale: selectedLocale,
            onTap: onLocaleSelected,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final Locale locale;
  final Locale selectedLocale;
  final ValueChanged<Locale> onTap;
  final bool isDark;

  const _LanguageTile({
    required this.title,
    required this.locale,
    required this.selectedLocale,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = locale.languageCode == selectedLocale.languageCode;

    return GestureDetector(
      onTap: () => onTap(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkCardGradient
              : AppTheme.lightCardGradient,
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
          border: Border.all(
            color: isSelected
                ? AppTheme.appOrange
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.appOrange.withValues(alpha: isDark ? 0.2 : 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.translate,
              color: isSelected ? AppTheme.appOrange : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.appOrange
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.appOrange
                      : (isDark ? Colors.white30 : Colors.black26),
                  width: isSelected ? 2 : 1.5,
                ),
                color: isSelected ? AppTheme.appOrange : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
