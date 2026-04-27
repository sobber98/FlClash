import 'dart:math';

import 'package:flutter/material.dart';

// Default indigo palette for light mode
const _kPrimary = Color(0xFF6366F1);
const _kSecondary = Color(0xFF818CF8);
const _kContainer = Color(0xFFE0E7FF);
const _kSurface = Color(0xFFF8FAFC);
const _kOnSurface = Color(0xFF1E293B);

/// The default light [ColorScheme] based on the indigo palette.
final defaultLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _kPrimary,
  onPrimary: Colors.white,
  primaryContainer: _kContainer,        // #E0E7FF – connect btn / feature icon bg
  onPrimaryContainer: _kOnSurface,
  secondary: _kSecondary,
  onSecondary: Colors.white,
  secondaryContainer: _kContainer,      // #E0E7FF – selected chip / nav indicator
  onSecondaryContainer: _kOnSurface,
  tertiary: _kSecondary,
  onTertiary: Colors.white,
  tertiaryContainer: _kContainer,
  onTertiaryContainer: _kOnSurface,
  error: const Color(0xFFBA1A1A),
  onError: Colors.white,
  errorContainer: const Color(0xFFFFDAD6),
  onErrorContainer: const Color(0xFF410002),
  surface: _kSurface,                   // #F8FAFC – scaffold background
  onSurface: _kOnSurface,
  // Surface container hierarchy (lightest → most elevated in light mode):
  //   Scaffold     Cards/sheets    Nav/overlay   Segment outer
  surfaceContainerLowest: _kSurface,    // #F8FAFC – scaffold bg
  surfaceContainerLow: Colors.white,    // #FFFFFF – plain cards, selected mode btn
  surfaceContainer: Colors.white,       // #FFFFFF – bottom nav bar, sheets
  surfaceContainerHigh: Colors.white,   // #FFFFFF – filled cards (CommonCard.filled)
  surfaceContainerHighest: _kContainer, // #E0E7FF – segment outer, card outline
  onSurfaceVariant: const Color(0xFF3E4A6B),
  outline: const Color(0xFF8595B0),
  outlineVariant: const Color(0xFFCBD5EE),
  shadow: Colors.black,
  scrim: Colors.black,
  inverseSurface: _kOnSurface,
  onInverseSurface: _kSurface,
  inversePrimary: _kSecondary,
  surfaceTint: _kPrimary,
);

extension ColorExtension on Color {
  Color get opacity80 {
    return withAlpha(204);
  }

  Color get opacity60 {
    return withAlpha(153);
  }

  Color get opacity50 {
    return withAlpha(128);
  }

  Color get opacity38 {
    return withAlpha(97);
  }

  Color get opacity30 {
    return withAlpha(77);
  }

  Color get opacity12 {
    return withAlpha(31);
  }

  Color get opacity15 {
    return withAlpha(38);
  }

  Color get opacity10 {
    return withAlpha(15);
  }

  Color get opacity3 {
    return withAlpha(8);
  }

  Color get opacity0 {
    return withAlpha(0);
  }

  int get value32bit {
    return _floatToInt8(a) << 24 |
        _floatToInt8(r) << 16 |
        _floatToInt8(g) << 8 |
        _floatToInt8(b) << 0;
  }

  int get alpha8bit => (0xff000000 & value32bit) >> 24;

  int get red8bit => (0x00ff0000 & value32bit) >> 16;

  int get green8bit => (0x0000ff00 & value32bit) >> 8;

  int get blue8bit => (0x000000ff & value32bit) >> 0;

  int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  Color lighten([double amount = 10]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.white;
    final HSLColor hsl = this == const Color(0xFF000000)
        ? HSLColor.fromColor(this).withSaturation(0)
        : HSLColor.fromColor(this);
    return hsl
        .withLightness(min(1, max(0, hsl.lightness + amount / 100)))
        .toColor();
  }

  String get hex {
    final value = toARGB32();
    final red = (value >> 16) & 0xFF;
    final green = (value >> 8) & 0xFF;
    final blue = value & 0xFF;
    return '#${red.toRadixString(16).padLeft(2, '0')}'
            '${green.toRadixString(16).padLeft(2, '0')}'
            '${blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color darken([final int amount = 10]) {
    if (amount <= 0) return this;
    if (amount > 100) return Colors.black;
    final HSLColor hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness(min(1, max(0, hsl.lightness - amount / 100)))
        .toColor();
  }

  Color blendDarken(
    BuildContext context, {
    double factor = 0.1,
  }) {
    final brightness = Theme.of(context).brightness;
    return Color.lerp(
      this,
      brightness == Brightness.dark ? Colors.white : Colors.black,
      factor,
    )!;
  }

  Color blendLighten(
    BuildContext context, {
    double factor = 0.1,
  }) {
    final brightness = Theme.of(context).brightness;
    return Color.lerp(
      this,
      brightness == Brightness.dark ? Colors.black : Colors.white,
      factor,
    )!;
  }
}

extension ColorSchemeExtension on ColorScheme {
  ColorScheme toPureBlack(bool isPrueBlack) => isPrueBlack
      ? copyWith(
          surface: Colors.black,
          surfaceContainer: surfaceContainer.darken(
            5,
          ),
        )
      : this;
}
