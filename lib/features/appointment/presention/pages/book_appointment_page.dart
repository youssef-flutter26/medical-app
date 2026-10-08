import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:medical_app/core/di/service_locator.dart';
import 'package:medical_app/core/error/result.dart';
import 'package:medical_app/core/theme/app_colors.dart';
import 'package:medical_app/core/theme/app_text_styles.dart';
import 'package:medical_app/features/appointment/domain/usecases/book_appointment.dart';
import 'package:medical_app/features/appointment/domain/usecases/get_booked_slots.dart';
import 'package:medical_app/features/home/domain/entities/doctor_entity.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key, required this.doctor});

  final DoctorEntity doctor;

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  late DateTime _selectedDate;

  TimeOfDay? _selectedTime;

  bool _isLoadingBookedSlots = false;
  bool _isBooking = false;

  Set<String> _bookedSlots = {};

  late final BookAppointment _bookAppointment;
  late final GetBookedSlots _getBookedSlots;

  @override
  void initState() {
    super.initState();

    _bookAppointment = GetIt.I<BookAppointment>();

    _getBookedSlots = getIt<GetBookedSlots>();

    _selectedDate = _getFirstAvailableDate();

    _loadBookedSlots();
  }

  String _dayKeyFromDate(DateTime date) {
    switch (date.weekday) {
      case DateTime.sunday:
        return 'sunday';
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      default:
        return 'sunday';
    }
  }

  DoctorSchedule? _getScheduleForDate(DateTime date) {
    final day = _dayKeyFromDate(date);

    for (final schedule in widget.doctor.schedule) {
      if (schedule.day.toLowerCase() == day) {
        return schedule;
      }
    }

    return null;
  }

  bool _isDoctorAvailableOnDay(DateTime date) {
    final schedule = _getScheduleForDate(date);

    return schedule?.enabled ?? false;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _getFirstAvailableDate() {
    final today = _dateOnly(DateTime.now());

    for (int i = 0; i < 60; i++) {
      final date = today.add(Duration(days: i));

      if (_isDoctorAvailableOnDay(date)) {
        return date;
      }
    }

    return today;
  }

  bool _isDateSelectable(DateTime date) {
    final today = _dateOnly(DateTime.now());

    final selected = _dateOnly(date);

    if (selected.isBefore(today)) {
      return false;
    }

    return _isDoctorAvailableOnDay(selected);
  }

  DateTime _firstDayOfCalendarMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  DateTime _lastDayOfCalendarMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  String _monthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[date.month - 1];
  }

  List<TimeOfDay> _generateTimeSlots(DoctorSchedule schedule) {
    final startParts = schedule.startTime.split(':');

    final endParts = schedule.endTime.split(':');

    if (startParts.length != 2 || endParts.length != 2) {
      return [];
    }

    final startHour = int.tryParse(startParts[0]);

    final startMinute = int.tryParse(startParts[1]);

    final endHour = int.tryParse(endParts[0]);

    final endMinute = int.tryParse(endParts[1]);

    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return [];
    }

    int currentMinutes = startHour * 60 + startMinute;

    final endMinutes = endHour * 60 + endMinute;

    final slots = <TimeOfDay>[];

    while (currentMinutes < endMinutes) {
      final hour = currentMinutes ~/ 60;

      final minute = currentMinutes % 60;

      slots.add(TimeOfDay(hour: hour, minute: minute));

      currentMinutes += 30;
    }

    return slots;
  }

  String _timeKey(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  bool _isPastSlot(DateTime date, TimeOfDay time) {
    final slotDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    return !slotDateTime.isAfter(DateTime.now());
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadBookedSlots() async {
    final doctorId = widget.doctor.id;

    if (doctorId == null || doctorId.isEmpty) {
      setState(() {
        _bookedSlots = {};
        _isLoadingBookedSlots = false;
      });

      return;
    }

    setState(() {
      _isLoadingBookedSlots = true;
    });

    final result = await _getBookedSlots(
      doctorId: doctorId,
      dateKey: _dateKey(_selectedDate),
    );

    if (!mounted) {
      return;
    }

    switch (result) {
      case SuccessAPI(:final data):
        setState(() {
          _bookedSlots = data;
          _isLoadingBookedSlots = false;

          if (_selectedTime != null &&
              data.contains(_timeKey(_selectedTime!))) {
            _selectedTime = null;
          }
        });

      case ErrorAPI(:final failure):
        debugPrint(
          'Failed to load booked slots: '
          '${failure.message}',
        );

        setState(() {
          _bookedSlots = {};
          _isLoadingBookedSlots = false;
        });

        _showMessage('Failed to load appointments.');
    }
  }

  Future<void> _selectDate(DateTime date) async {
    if (!_isDateSelectable(date)) {
      return;
    }

    setState(() {
      _selectedDate = _dateOnly(date);

      _selectedTime = null;
      _bookedSlots = {};
    });

    await _loadBookedSlots();
  }

  DateTime _appointmentDateTime() {
    final time = _selectedTime!;

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _confirmAppointment() async {
    if (_isBooking) {
      return;
    }

    if (_selectedTime == null) {
      _showMessage('Please select an appointment time.');
      return;
    }

    final doctorId = widget.doctor.id;

    if (doctorId == null || doctorId.isEmpty) {
      _showMessage('Doctor information is incomplete.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please login first.');
      return;
    }

    final time = _timeKey(_selectedTime!);

    // Re-check the slot before booking.
    if (_bookedSlots.contains(time)) {
      _showMessage('This appointment is already booked.');

      await _loadBookedSlots();

      return;
    }

    if (_isPastSlot(_selectedDate, _selectedTime!)) {
      _showMessage('This appointment time has already passed.');

      return;
    }

    setState(() {
      _isBooking = true;
    });

    final result = await _bookAppointment(
      doctorId: doctorId,
      doctorName: widget.doctor.name,
      patientId: user.uid,
      dateKey: _dateKey(_selectedDate),
      time: time,
      dateTime: _appointmentDateTime(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isBooking = false;
    });

    switch (result) {
      case SuccessAPI():
        _showSuccessDialog();

      case ErrorAPI(:final failure):
        _showMessage(failure.message);

        await _loadBookedSlots();
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 38.w),
          child: Container(
            padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 20.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFA5D8CE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 42.w,
                      height: 42.w,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.darkTeal,
                        size: 28.r,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 18.h),

                Text(
                  'Congratulations',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.inter18W700.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTeal,
                  ),
                ),

                SizedBox(height: 10.h),

                Text(
                  'Your appointment with '
                  'Dr. ${widget.doctor.name} '
                  'is confirmed for '
                  '${_formattedSelectedDate} '
                  'at ${_formatTime(_selectedTime!)}.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.inter12W400.copyWith(
                    fontSize: 12.sp,
                    height: 1.5,
                    color: AppColors.gray500,
                  ),
                ),

                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();

                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkTeal,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: AppTextStyles.inter14W500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  'Edit your appointment',
                  style: AppTextStyles.inter12W400.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String get _formattedSelectedDate {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[_selectedDate.month - 1]} '
        '${_selectedDate.day}, '
        '${_selectedDate.year}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.red),
    );
  }

  Widget _buildCalendarHeader() {
    final month = _selectedDate;

    return Row(
      children: [
        Text(
          '${_monthName(month)} ${month.year}',
          style: AppTextStyles.inter14W500.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.gray700,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _goToPreviousMonth,
          icon: Icon(
            Icons.chevron_left_rounded,
            size: 24.r,
            color: AppColors.gray600,
          ),
        ),
        IconButton(
          onPressed: _goToNextMonth,
          icon: Icon(
            Icons.chevron_right_rounded,
            size: 24.r,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  DateTime get _calendarMonth =>
      DateTime(_selectedDate.year, _selectedDate.month, 1);

  void _goToPreviousMonth() {
    final previous = DateTime(_calendarMonth.year, _calendarMonth.month - 1, 1);

    final today = _dateOnly(DateTime.now());

    if (previous.isBefore(DateTime(today.year, today.month, 1))) {
      return;
    }

    setState(() {
      _selectedDate = _findFirstSelectableDateInMonth(previous);

      _selectedTime = null;
    });

    _loadBookedSlots();
  }

  void _goToNextMonth() {
    final next = DateTime(_calendarMonth.year, _calendarMonth.month + 1, 1);

    setState(() {
      _selectedDate = _findFirstSelectableDateInMonth(next);

      _selectedTime = null;
    });

    _loadBookedSlots();
  }

  DateTime _findFirstSelectableDateInMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);

    final last = DateTime(month.year, month.month + 1, 0);

    final today = _dateOnly(DateTime.now());

    for (
      DateTime date = first;
      !date.isAfter(last);
      date = date.add(const Duration(days: 1))
    ) {
      if (date.isBefore(today)) {
        continue;
      }

      if (_isDoctorAvailableOnDay(date)) {
        return date;
      }
    }

    return first.isBefore(today) ? today : first;
  }

  Widget _buildCalendar() {
    return CalendarDatePicker(
      initialDate: _selectedDate,
      firstDate: _dateOnly(DateTime.now()),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      currentDate: DateTime.now(),
      selectableDayPredicate: _isDateSelectable,
      onDateChanged: _selectDate,
    );
  }

  Widget _buildTimeSlot(TimeOfDay time) {
    final key = _timeKey(time);

    final booked = _bookedSlots.contains(key);

    final past = _isPastSlot(_selectedDate, time);

    final selected = _selectedTime != null && _timeKey(_selectedTime!) == key;

    final disabled = booked || past;

    return InkWell(
      onTap: disabled
          ? null
          : () {
              setState(() {
                _selectedTime = time;
              });
            },
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.gray100
              : selected
              ? AppColors.darkTeal
              : AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: disabled
                ? AppColors.gray500
                : selected
                ? AppColors.darkTeal
                : AppColors.gray400,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formatTime(time),
                style: AppTextStyles.inter12W400.copyWith(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: disabled
                      ? AppColors.gray400
                      : selected
                      ? AppColors.white
                      : AppColors.gray600,
                ),
              ),
              if (booked) ...[
                SizedBox(height: 2.h),
                Text(
                  'Booked',
                  style: TextStyle(fontSize: 9.sp, color: AppColors.gray400),
                ),
              ] else if (past) ...[
                SizedBox(height: 2.h),
                Text(
                  'Passed',
                  style: TextStyle(fontSize: 9.sp, color: AppColors.gray400),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _getScheduleForDate(_selectedDate);

    final slots = schedule == null
        ? <TimeOfDay>[]
        : _generateTimeSlots(schedule);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.r,
            color: AppColors.gray700,
          ),
        ),
        title: Text(
          'Book Appointment',
          style: AppTextStyles.inter16W500.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.gray700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctor.name,
                      style: AppTextStyles.inter16W500.copyWith(
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTeal,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      widget.doctor.specialty,
                      style: AppTextStyles.inter12W400.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.gray500,
                      ),
                    ),

                    SizedBox(height: 18.h),

                    Text(
                      'Select Date',
                      style: AppTextStyles.inter14W500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray700,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x08000000),
                            blurRadius: 12.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                        border: Border.all(color: AppColors.gray100),
                      ),
                      child: Column(
                        children: [_buildCalendarHeader(), _buildCalendar()],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      'Select Hour',
                      style: AppTextStyles.inter14W500.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray700,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    if (_isLoadingBookedSlots)
                      const Center(child: CircularProgressIndicator())
                    else if (slots.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'No available appointments for this day.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.inter12W400.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8.h,
                          crossAxisSpacing: 8.w,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: slots.length,
                        itemBuilder: (_, index) {
                          return _buildTimeSlot(slots[index]);
                        },
                      ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x10000000),
                    blurRadius: 12.r,
                    offset: Offset(0, -3.h),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed:
                      _isBooking ||
                          _selectedTime == null ||
                          _isLoadingBookedSlots
                      ? null
                      : _confirmAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkTeal,
                    disabledBackgroundColor: AppColors.gray100,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: _isBooking
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Confirm',
                          style: AppTextStyles.inter16W500.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
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
