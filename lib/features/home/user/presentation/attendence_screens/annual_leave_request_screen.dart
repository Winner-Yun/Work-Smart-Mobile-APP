import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:intl/intl.dart';

class AnnualLeaveRequestScreen extends StatefulWidget {
  const AnnualLeaveRequestScreen({super.key});

  @override
  State<AnnualLeaveRequestScreen> createState() =>
      _AnnualLeaveRequestScreenState();
}

class _AnnualLeaveRequestScreenState extends State<AnnualLeaveRequestScreen> {
  static const int _annualLeaveTotal = 18;
  late int _annualLeaveUsed;
  late int _annualLeaveRemaining;

  DateTime? _startDate;
  DateTime? _endDate;
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    // For demo: assuming user has used 6 annual leave days
    _annualLeaveUsed = 6;
    _annualLeaveRemaining = _annualLeaveTotal - _annualLeaveUsed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(context),
            const SizedBox(height: 25),
            _buildSectionTitle(AppStrings.tr('select_date'), context),
            const SizedBox(height: 15),
            _buildDateRangePicker(context),
            const SizedBox(height: 25),
            _buildSectionTitle(AppStrings.tr('reason_for_request'), context),
            const SizedBox(height: 15),
            _buildTextArea(context),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: const Icon(Icons.calendar_today, color: Colors.teal),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('leave_type'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    AppStrings.tr('annual_leave'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceInfo(
                  'Used',
                  '$_annualLeaveUsed days',
                  Colors.orange,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
                _buildBalanceInfo(
                  'Remaining',
                  '$_annualLeaveRemaining days',
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                ),
                _buildBalanceInfo(
                  'Total',
                  '$_annualLeaveTotal days',
                  Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildBalanceInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _dateColumn(
            context,
            AppStrings.tr('start_date'),
            _startDate == null
                ? AppStrings.tr('select_date')
                : _dateFormatter.format(_startDate!),
            onTap: () => _pickStartDate(context),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
          ),
          _dateColumn(
            context,
            AppStrings.tr('end_date'),
            _endDate == null
                ? AppStrings.tr('select_date')
                : _dateFormatter.format(_endDate!),
            onTap: _startDate == null ? null : () => _pickEndDate(context),
          ),
        ],
      ),
    );
  }

  Widget _dateColumn(
    BuildContext context,
    String label,
    String date, {
    VoidCallback? onTap,
  }) {
    final bool isDisabled = onTap == null;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDisabled ? Colors.grey.shade400 : Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                date,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDisabled
                      ? Colors.grey.shade400
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    setState(() {
      _startDate = picked;
      if (_endDate != null && !_endDate!.isAfter(_startDate!)) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate(BuildContext context) async {
    if (_startDate == null) return;

    final DateTime initial =
        _endDate ?? _startDate!.add(const Duration(days: 1));
    final DateTime firstDate = _startDate!.add(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(firstDate) ? initial : firstDate,
      firstDate: firstDate,
      lastDate: DateTime(_startDate!.year + 2),
    );

    if (picked == null) return;

    setState(() {
      _endDate = picked;
    });
  }

  Widget _buildTextArea(BuildContext context) {
    return TextField(
      maxLines: 5,
      decoration: InputDecoration(
        hintText: AppStrings.tr('enter_reason_hint'),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.5,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).iconTheme.color,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.tr('request_annual_leave_title'),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String text, BuildContext context) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  );

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          AppStrings.tr('submit_request'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
