import 'package:flutter/material.dart';
import '../../../../features/attendance/domain/attendance_model.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/custom_card.dart';
import 'shift_selector.dart';

class CheckinCard extends StatelessWidget {
  final AttendanceModel? todayAttendance;
  final String selectedShift;
  final bool isLoading;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final ValueChanged onShiftChanged;

  const CheckinCard({
    super.key,
    this.todayAttendance,
    required this.selectedShift,
    required this.isLoading,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onShiftChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasCheckedIn =
        todayAttendance?.checkIn != null;

    final hasCheckedOut =
        todayAttendance?.hasCheckedOut ??
            false;

    return CustomCard(
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          ShiftSelector(
            selectedShift:
            selectedShift,
            enabled: false, // Luôn khóa, ca được tự động xác định
            onShiftChanged:
            onShiftChanged,
          ),

          const SizedBox(
            height:
            AppSpacing.md,
          ),

          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
            children: [
              Text(
                'Trạng thái hôm nay',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors
                      .textSecondary,
                ),
              ),
              _StatusBadge(
                attendance:
                todayAttendance,
              ),
            ],
          ),

          const SizedBox(
            height:
            AppSpacing.sm,
          ),

          Row(
            children: [
              Expanded(
                child:
                _TappableTimeBox(
                  label:
                  'Check In',

                  time: hasCheckedIn
                      ? DateHelper
                      .toTimeString(
                    todayAttendance!
                        .checkIn!,
                  )
                      : '--:--',

                  subText:
                  hasCheckedIn
                      ? 'Cách CT: ${todayAttendance!.distance.toStringAsFixed(0)}m'
                      : 'Nhấn để check in',

                  canTap:
                  !hasCheckedIn &&
                      !isLoading,

                  isLoading:
                  isLoading &&
                      !hasCheckedIn,

                  onTap:
                  onCheckIn,
                ),
              ),

              const SizedBox(
                width:
                AppSpacing.sm,
              ),

              Expanded(
                child:
                _TappableTimeBox(
                  label:
                  'Check Out',

                  time:
                  hasCheckedOut
                      ? DateHelper
                      .toTimeString(
                    todayAttendance!
                        .checkOut!,
                  )
                      : '--:--',

                  subText:
                  hasCheckedOut
                      ? 'Đã làm ${todayAttendance!.calculatedWorkHours.toStringAsFixed(1)} giờ'
                      : hasCheckedIn
                      ? 'Nhấn để check out'
                      : 'Chưa check in',

                  canTap:
                  hasCheckedIn &&
                      !hasCheckedOut &&
                      !isLoading,

                  isLoading:
                  isLoading &&
                      hasCheckedIn &&
                      !hasCheckedOut,

                  onTap:
                  onCheckOut,

                  isCheckOut:
                  true,
                ),
              ),
            ],
          ),
        ],
      ),
    );

  }
}

class _TappableTimeBox
    extends StatelessWidget {
  final String label;
  final String time;
  final String subText;
  final bool canTap;
  final bool isLoading;
  final bool isCheckOut;
  final VoidCallback onTap;

  const _TappableTimeBox({
    required this.label,
    required this.time,
    required this.subText,
    required this.canTap,
    required this.isLoading,
    required this.onTap,
    this.isCheckOut = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
      canTap ? onTap : null,
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 200,
        ),
        padding:
        const EdgeInsets.all(
          AppSpacing.sm + 2,
        ),
        decoration:
        BoxDecoration(
          color: canTap
              ? const Color(
            0xFFFFF4F4,
          )
              : AppColors
              .background,
          borderRadius:
          BorderRadius.circular(
            10,
          ),
          border: Border.all(
            color: canTap
                ? AppColors
                .primary
                .withValues(
              alpha: 0.4,
            )
                : AppColors
                .border,
            width:
            canTap ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Text(
                  label,
                  style:
                  TextStyle(
                    fontSize: 11,
                    color: AppColors
                        .textSecondary,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                    color:
                    AppColors.primary,
                  ),
                )
                    : Text(
                  time,
                  style:
                  TextStyle(
                    fontSize:
                    20,
                    fontWeight:
                    FontWeight
                        .w600,
                    color: time ==
                        '--:--'
                        ? AppColors
                        .textSecondary
                        : AppColors
                        .textPrimary,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  subText,
                  style:
                  TextStyle(
                    fontSize: 11,
                    color: canTap
                        ? AppColors
                        .primary
                        : AppColors
                        .textSecondary,
                  ),
                ),
              ],
            ),

            if (canTap)
              Positioned(
                top: 0,
                right: 0,
                child:
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal:
                    5,
                    vertical: 1,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    AppColors
                        .primary,
                    borderRadius:
                    BorderRadius.circular(
                      4,
                    ),
                  ),
                  child: Text(
                    isCheckOut
                        ? 'Tap'
                        : 'Tap',
                    style:
                    const TextStyle(
                      fontSize:
                      9,
                      color:
                      Colors
                          .white,
                      fontWeight:
                      FontWeight
                          .w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

  }
}

class _StatusBadge
    extends StatelessWidget {
  final AttendanceModel?
  attendance;

  const _StatusBadge({
    this.attendance,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    if (attendance == null) {
      return _badge(
        'Chưa chấm công',
        Colors.grey.shade200,
        AppColors
            .textSecondary,
      );
    }

    final badges = <Widget>[];

    if (attendance!.isLate) {
      badges.add(
        _badge(
          'Đi muộn',
          const Color(
            0xFFFAEEDA,
          ),
          const Color(
            0xFF633806,
          ),
        ),
      );
    }

    if (attendance!.isEarlyLeave) {
      badges.add(
        _badge(
          'Về sớm',
          const Color(
            0xFFFFE6E6,
          ),
          AppColors.error,
        ),
      );
    }

    if (badges.isEmpty) {
      if (attendance!
          .hasCheckedOut) {
        badges.add(
          _badge(
            'Hoàn thành',
            const Color(
              0xFFE6F1FB,
            ),
            const Color(
              0xFF0C447C,
            ),
          ),
        );
      } else {
        badges.add(
          _badge(
            'Đúng giờ',
            const Color(
              0xFFEAF3DE,
            ),
            AppColors.success,
          ),
        );
      }
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment:
      WrapAlignment.end,
      children: badges,
    );
  }

  Widget _badge(
      String text,
      Color bg,
      Color textColor,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration:
      BoxDecoration(
        color: bg,
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight:
          FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}