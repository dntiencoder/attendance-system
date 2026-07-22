import 'package:flutter/material.dart';
import '../../../../features/attendance/domain/attendance_model.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../shared/widgets/attendance_status_badges.dart';
import 'shift_selector.dart';

class CheckinCard extends StatelessWidget {
  final AttendanceModel? todayAttendance;
  final String selectedShift;
  final bool isLoading;
  final bool isOffDay;
  final bool isShiftEnded; // ← Thêm trường này
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final ValueChanged onShiftChanged;

  const CheckinCard({
    super.key,
    this.todayAttendance,
    required this.selectedShift,
    required this.isLoading,
    this.isOffDay = false,
    this.isShiftEnded = false, // Mặc định là false
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
              AttendanceStatusBadges(
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

                  // hasCheckedIn được ưu tiên kiểm tra trước isOffDay/
                  // isShiftEnded: đã có dữ liệu Check In thật (vd ca đêm hôm
                  // qua carryover sang ngày nghỉ bắt buộc hôm nay) thì phải
                  // hiển thị đúng dữ liệu đó, không được đè bằng nhãn suy ra
                  // từ "hôm nay" (ngày lịch) — cùng nguyên nhân với BUG-017.
                  subText: hasCheckedIn
                      ? 'Cách CT: ${todayAttendance!.distance.toStringAsFixed(0)}m'
                      : isOffDay
                        ? 'Nghỉ bắt buộc'
                        : isShiftEnded
                          ? 'Đã hết ca (Vắng)'
                          : 'Nhấn để check in',

                  canTap:
                  !isOffDay &&
                  !isShiftEnded && // Thêm điều kiện chưa hết ca
                  !hasCheckedIn &&
                      !isLoading,

                  isLoading:
                  isLoading &&
                      !hasCheckedIn,

                  onTap:
                  onCheckIn,

                  isDisabled: !hasCheckedIn && (isOffDay || isShiftEnded), // Chỉ xám khi thật sự chưa check in
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

                  // isOffDay không chặn Check Out: hoàn tất 1 ca đã lỡ bắt
                  // đầu hợp lệ (vd ca đêm hôm qua rollover sang sáng ngày
                  // nghỉ bắt buộc) phải luôn được phép, dù "hôm nay" theo
                  // lịch là ngày nghỉ. isOffDay chỉ còn ý nghĩa chặn Check In
                  // (không được BẮT ĐẦU ca mới vào ngày nghỉ).
                  subText: hasCheckedOut
                      ? 'Đã làm ${todayAttendance!.calculatedWorkHours.toStringAsFixed(1)} giờ'
                      : hasCheckedIn
                        ? 'Nhấn để check out'
                        : isOffDay
                          ? 'Nghỉ bắt buộc'
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

                  isDisabled: isOffDay && !hasCheckedIn, // Chỉ xám khi thật sự không có gì để check out
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
  final bool isDisabled; // Thêm trường này
  final VoidCallback onTap;

  const _TappableTimeBox({
    required this.label,
    required this.time,
    required this.subText,
    required this.canTap,
    required this.isLoading,
    required this.onTap,
    this.isCheckOut = false,
    this.isDisabled = false, // Mặc định là false
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
              : AppColors.background,
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
                    color: (time == '--:--' || isDisabled)
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
