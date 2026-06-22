import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter();

  static TextStyle heading1 = _base.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = _base.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static TextStyle body = _base.copyWith(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static TextStyle bodySecondary = _base.copyWith(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = _base.copyWith(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static TextStyle statValue = _base.copyWith(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle buttonText = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}