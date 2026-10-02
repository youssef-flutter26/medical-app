import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationSearchBar extends StatefulWidget {
  const LocationSearchBar({
    super.key,
    required this.onSearch,
  });

  final ValueChanged<String> onSearch;

  @override
  State<LocationSearchBar> createState() =>
      _LocationSearchBarState();
}

class _LocationSearchBarState extends State<LocationSearchBar> {
  final TextEditingController controller =
  TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,

        // Search while typing.
        onChanged: widget.onSearch,

        textInputAction:
        TextInputAction.search,

        decoration: InputDecoration(
          hintText:
          'Search Doctor, Hospital',

          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade500,
          ),

          prefixIcon: Icon(
            Icons.search,
            size: 22.sp,
            color: Colors.grey.shade600,
          ),

          border: InputBorder.none,

          enabledBorder:
          InputBorder.none,

          focusedBorder:
          InputBorder.none,

          contentPadding:
          EdgeInsets.symmetric(
            vertical: 15.h,
            horizontal: 4.w,
          ),
        ),
      ),
    );
  }
}