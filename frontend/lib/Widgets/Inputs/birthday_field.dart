import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:intl/intl.dart';

class BirthdayField extends StatefulWidget {
  const BirthdayField({super.key});

  @override
  State<BirthdayField> createState() => BirthdayFieldState();
}

class BirthdayFieldState extends State<BirthdayField> {
  final months = [
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
    'December'
  ];

  final days = List.generate(31, (index) => (index + 1).toString());

  final List<String> years = <String>[];

  late String daysValue, monthsValue, yearsValue;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    monthsValue = months[now.month - 1];
    daysValue = now.day.toString();
    yearsValue = now.year.toString();
    for (int i = int.parse(yearsValue) - 70; i <= int.parse(yearsValue); i++) {
      years.add(i.toString());
    }
  }

  get _basicDropDownShell => (
          {required String initialValue, required List<String> values}) =>
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              border: Border.all(
                  color: const Color.fromARGB(255, 235, 235, 235), width: .3),
              borderRadius: BorderRadius.circular(3)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color.fromARGB(255, 66, 66, 66),
              icon: const Icon(Icons.keyboard_arrow_down),
              value: initialValue,
              elevation: 0,
              style:
                  AppTextStyles.primaryTextStyle.copyWith(color: Colors.black),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  if (values == months) {
                    monthsValue = value!;
                  } else if (values == days) {
                    daysValue = value!;
                  } else if (values == years) {
                    yearsValue = value!;
                  }
                });
              },
              items: values
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: AppTextStyles.primaryTextStyle,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ));

  get selectedDate => () =>
      DateFormat('MMMM-dd-yyyy').parse('$monthsValue-$daysValue-$yearsValue');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _basicDropDownShell(initialValue: monthsValue, values: months),
          _basicDropDownShell(initialValue: daysValue, values: days),
          _basicDropDownShell(initialValue: yearsValue, values: years)
        ],
      ),
    );
  }
}
