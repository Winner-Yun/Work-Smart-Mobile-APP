import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/user_model/user_profile.dart';
import 'package:intl/intl.dart';

class SickLeaveRequestScreen extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const SickLeaveRequestScreen({super.key, this.loginData});

  @override
  State<SickLeaveRequestScreen> createState() => _SickLeaveRequestScreenState();
}

class _SickLeaveRequestScreenState extends State<SickLeaveRequestScreen> {
  static const int _sickLeaveTotal = 5;
  late int _sickLeaveUsed;
  late int _sickLeaveRemaining;
  late UserProfile _currentUser;
  late String? loggedInUserId;

  PlatformFile? _pickedFile;
  DateTime? _selectedDate;
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    loggedInUserId = widget.loginData?['uid'];
    _loadData();
  }

  void _loadData() {
    final currentUserData = usersFinalData.firstWhere(
      (user) => user['uid'] == (loggedInUserId ?? "user_winner_777"),
      orElse: () => usersFinalData[0],
    );
    _currentUser = UserProfile.fromJson(currentUserData);

    // Calculate sick leave used from leave records - sum actual days, not record count
    final sickLeaves = _currentUser.leaveRecords
        .where((leave) => leave.type.toLowerCase().contains('sick'))
        .toList();
    _sickLeaveUsed = sickLeaves.fold(
      0,
      (sum, leave) => sum + leave.durationInDays,
    );
    _sickLeaveRemaining = _sickLeaveTotal - _sickLeaveUsed;
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
        });
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopInfoCard(context),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(AppStrings.tr('request_details'), context),
                  const SizedBox(height: 15),
                  _buildInputCard(context, [
                    _buildLabel(AppStrings.tr('reason_for_sickness'), context),
                    _buildTextField(
                      context: context,
                      hint: AppStrings.tr('sickness_reason_hint'),
                      icon: Icons.edit_note,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel(AppStrings.tr('leave_date'), context),
                    _buildDatePickerField(context),
                  ]),
                  const SizedBox(height: 25),
                  _buildSectionTitle(
                    AppStrings.tr('medical_documents'),
                    context,
                  ),
                  const SizedBox(height: 15),
                  _buildUploadArea(context),
                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
                ],
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
            ),
          ],
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
        icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.tr('request_sick_leave_title'),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildTopInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.medical_services,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                    AppStrings.tr('sick_leave'),
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
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBalanceInfo(
                  'Used',
                  '$_sickLeaveUsed days',
                  Colors.orange,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
                _buildBalanceInfo(
                  'Remaining',
                  '$_sickLeaveRemaining days',
                  Colors.green,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
                _buildBalanceInfo(
                  'Total',
                  '$_sickLeaveTotal days',
                  Theme.of(context).colorScheme.primary,
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
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
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

  Widget _buildDatePickerField(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color:
            Theme.of(context).inputDecorationTheme.fillColor ??
            (isDark ? Colors.grey.shade800 : Colors.grey.shade50),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Leave Date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate != null
                          ? _dateFormatter.format(_selectedDate!)
                          : 'Tap to select date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selectedDate != null
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(
                                context,
                              ).textTheme.bodySmall?.color?.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, List<Widget> children) {
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
        children: children,
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pickedFile != null
                ? Colors.green
                : Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _pickedFile != null
                  ? Icons.check_circle_outline
                  : Icons.add_photo_alternate_outlined,
              size: 40,
              color: _pickedFile != null
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              _pickedFile != null
                  ? '${AppStrings.tr('attached_file')}${_pickedFile!.name}'
                  : AppStrings.tr('upload_medical_cert'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _pickedFile != null
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: _pickedFile != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            if (_pickedFile != null) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.tr('tap_to_change_file'),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    ).animate().scale(delay: 400.ms);
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          AppStrings.tr('submit_official_request'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
      ),
    ),
  );

  Widget _buildSectionTitle(String text, BuildContext context) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  );

  Widget _buildTextField({
    required BuildContext context,
    required String hint,
    IconData? icon,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Theme.of(context).colorScheme.primary,
          selectionHandleColor: Theme.of(context).colorScheme.primary,
          selectionColor: (Theme.of(
            context,
          ).colorScheme.primary).withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, size: 20, color: Colors.grey),
          filled: true,
          fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }
}
