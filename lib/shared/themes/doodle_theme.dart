import 'package:flutter/material.dart';

import '../../core/constants/doodle_colors.dart';
import '../../core/constants/doodle_typography.dart';

/// Todoodle 앱의 Doodle 컨셉 테마
///
/// 낙서장/노트 느낌의 따뜻하고 손그림 스타일 테마입니다.
class DoodleTheme {
  DoodleTheme._();

  /// Light Theme - 낮의 낙서장
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // === Color Scheme ===
      colorScheme: ColorScheme.light(
        primary: DoodleColors.primary,
        onPrimary: Colors.white,
        primaryContainer: DoodleColors.primaryLight,
        onPrimaryContainer: DoodleColors.primaryDark,
        secondary: DoodleColors.highlightPink,
        onSecondary: Colors.white,
        secondaryContainer: DoodleColors.highlightPink.withValues(alpha: 0.3),
        onSecondaryContainer: DoodleColors.pencilDark,
        tertiary: DoodleColors.inkBlue,
        onTertiary: Colors.white,
        surface: DoodleColors.paperWhite,
        onSurface: DoodleColors.pencilDark,
        surfaceContainerHighest: DoodleColors.paperCream,
        error: DoodleColors.error,
        onError: Colors.white,
        outline: DoodleColors.paperGrid,
        outlineVariant: DoodleColors.pencilLight.withValues(alpha: 0.3),
      ),

      // === Scaffold ===
      scaffoldBackgroundColor: DoodleColors.paperCream,

      // === AppBar ===
      appBarTheme: AppBarTheme(
        backgroundColor: DoodleColors.paperCream,
        foregroundColor: DoodleColors.pencilDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: DoodleTypography.titleLarge.copyWith(
          color: DoodleColors.pencilDark,
        ),
        iconTheme: const IconThemeData(
          color: DoodleColors.pencilDark,
        ),
      ),

      // === Card ===
      cardTheme: CardThemeData(
        color: DoodleColors.paperWhite,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: DoodleColors.pencilLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),

      // === FAB ===
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DoodleColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // === Chip ===
      chipTheme: ChipThemeData(
        backgroundColor: DoodleColors.highlightYellow.withValues(alpha: 0.5),
        selectedColor: DoodleColors.highlightGreen,
        labelStyle: DoodleTypography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: DoodleColors.pencilLight.withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // === Input ===
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DoodleColors.paperWhite,
        hintStyle: DoodleTypography.hint,
        labelStyle: DoodleTypography.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: DoodleColors.pencilLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: DoodleColors.pencilLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: DoodleColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: DoodleColors.error,
            width: 1.5,
          ),
        ),
      ),

      // === Buttons ===
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DoodleColors.primary,
          foregroundColor: Colors.white,
          textStyle: DoodleTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DoodleColors.pencilDark,
          textStyle: DoodleTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(
            color: DoodleColors.pencilLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DoodleColors.inkBlue,
          textStyle: DoodleTypography.button,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // === Checkbox ===
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DoodleColors.primary;
          }
          return DoodleColors.paperWhite;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(
          color: DoodleColors.pencilLight,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // === Switch ===
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DoodleColors.primary;
          }
          return DoodleColors.pencilLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DoodleColors.primaryLight;
          }
          return DoodleColors.paperGrid;
        }),
      ),

      // === Slider ===
      sliderTheme: SliderThemeData(
        activeTrackColor: DoodleColors.primary,
        inactiveTrackColor: DoodleColors.paperGrid,
        thumbColor: DoodleColors.primary,
        overlayColor: DoodleColors.primary.withValues(alpha: 0.2),
      ),

      // === Dialog ===
      dialogTheme: DialogThemeData(
        backgroundColor: DoodleColors.paperWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: DoodleColors.pencilLight.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        titleTextStyle: DoodleTypography.titleLarge,
        contentTextStyle: DoodleTypography.bodyMedium,
      ),

      // === BottomSheet ===
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DoodleColors.paperWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        dragHandleColor: DoodleColors.pencilLight,
        dragHandleSize: Size(40, 4),
      ),

      // === Snackbar ===
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DoodleColors.pencilDark,
        contentTextStyle: DoodleTypography.bodyMedium.copyWith(
          color: DoodleColors.paperWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // === Divider ===
      dividerTheme: const DividerThemeData(
        color: DoodleColors.paperGrid,
        thickness: 1,
        space: 1,
      ),

      // === ListTile ===
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: DoodleTypography.titleMedium,
        subtitleTextStyle: DoodleTypography.bodySmall,
        iconColor: DoodleColors.pencilDark,
      ),

      // === Icon ===
      iconTheme: const IconThemeData(
        color: DoodleColors.pencilDark,
        size: 24,
      ),

      // === Text Theme ===
      textTheme: const TextTheme(
        displayLarge: DoodleTypography.headlineLarge,
        displayMedium: DoodleTypography.headlineMedium,
        displaySmall: DoodleTypography.headlineSmall,
        headlineLarge: DoodleTypography.headlineLarge,
        headlineMedium: DoodleTypography.headlineMedium,
        headlineSmall: DoodleTypography.headlineSmall,
        titleLarge: DoodleTypography.titleLarge,
        titleMedium: DoodleTypography.titleMedium,
        titleSmall: DoodleTypography.titleSmall,
        bodyLarge: DoodleTypography.bodyLarge,
        bodyMedium: DoodleTypography.bodyMedium,
        bodySmall: DoodleTypography.bodySmall,
        labelLarge: DoodleTypography.labelLarge,
        labelMedium: DoodleTypography.labelMedium,
        labelSmall: DoodleTypography.labelSmall,
      ),

      // === Tab Bar ===
      tabBarTheme: const TabBarThemeData(
        labelColor: DoodleColors.pencilDark,
        unselectedLabelColor: DoodleColors.pencilLight,
        labelStyle: DoodleTypography.labelLarge,
        unselectedLabelStyle: DoodleTypography.labelMedium,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: DoodleColors.primary,
            width: 3,
          ),
        ),
      ),

      // === Navigation Bar ===
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DoodleColors.paperWhite,
        indicatorColor: DoodleColors.primaryLight,
        labelTextStyle: const WidgetStatePropertyAll(DoodleTypography.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: DoodleColors.primaryDark);
          }
          return const IconThemeData(color: DoodleColors.pencilLight);
        }),
      ),

      // === Progress Indicator ===
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DoodleColors.primary,
        linearTrackColor: DoodleColors.paperGrid,
        circularTrackColor: DoodleColors.paperGrid,
      ),
    );
  }

  /// Dark Theme - 밤의 낙서장 (추후 구현)
  static ThemeData get dark {
    // TODO: Implement dark theme
    return light; // 임시로 light 반환
  }
}
