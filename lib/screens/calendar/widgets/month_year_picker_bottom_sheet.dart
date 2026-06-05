import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../theme.dart';

class MonthYearPickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;

  const MonthYearPickerBottomSheet({
    super.key,
    required this.initialDate,
  });

  @override
  State<MonthYearPickerBottomSheet> createState() => _MonthYearPickerBottomSheetState();
}

class _MonthYearPickerBottomSheetState extends State<MonthYearPickerBottomSheet> {
  late int _selectedYear;
  late int _selectedMonth;

  late FixedExtentScrollController _yearController;
  late FixedExtentScrollController _monthController;

  // 선택 가능한 연도 범위 (2020년 ~ 2035년)
  final int _startYear = 2020;
  final int _endYear = 2035;
  late List<int> _years;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;

    _years = List.generate(_endYear - _startYear + 1, (index) => _startYear + index);

    final initialYearIndex = _years.indexOf(_selectedYear);
    _yearController = FixedExtentScrollController(initialItem: initialYearIndex >= 0 ? initialYearIndex : 0);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth - 1);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 상단 헤더 영역 (완료 버튼 포함)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '날짜 선택',
                    style: AppTextStyle.body2B.copyWith(
                      color: AppColors.grayScale9,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 선택 완료 시 부모 창에 DateTime 전달하며 닫기
                      Navigator.pop(context, DateTime(_selectedYear, _selectedMonth, 1));
                    },
                    child: Text(
                      '완료',
                      style: AppTextStyle.body2B.copyWith(
                        color: AppColors.mainColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.gray2),
            // CupertinoPicker 선택 휠 영역
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // 연도 선택 휠
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _yearController,
                        itemExtent: 42.0,
                        backgroundColor: AppColors.white,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedYear = _years[index];
                          });
                        },
                        children: _years.map((year) {
                          return Center(
                            child: Text(
                              '$year년',
                              style: const TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 18,
                                color: AppColors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // 월 선택 휠
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: _monthController,
                        itemExtent: 42.0,
                        backgroundColor: AppColors.white,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            _selectedMonth = index + 1;
                          });
                        },
                        children: List.generate(12, (index) {
                          final m = index + 1;
                          return Center(
                            child: Text(
                              '$m월',
                              style: const TextStyle(
                                fontFamily: AppTextStyle.fontFamily,
                                fontSize: 18,
                                color: AppColors.black,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
