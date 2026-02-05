import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SickLeaveRequestScreen extends StatefulWidget {
  const SickLeaveRequestScreen({super.key});

  @override
  State<SickLeaveRequestScreen> createState() => _SickLeaveRequestScreenState();
}

class _SickLeaveRequestScreenState extends State<SickLeaveRequestScreen> {
  PlatformFile? _pickedFile;

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
                  _buildSectionTitle('ព័ត៌មានលម្អិតនៃសំណើ', context),
                  const SizedBox(height: 15),
                  _buildInputCard(context, [
                    _buildLabel('មូលហេតុនៃជំងឺ', context),
                    _buildTextField(
                      context: context,
                      hint: 'បញ្ជាក់ពីអាការៈជំងឺ...',
                      icon: Icons.edit_note,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('កាលបរិច្ឆេទឈប់សម្រាក', context),
                    _buildTextField(
                      context: context,
                      hint: 'ជ្រើសរើសថ្ងៃខែឆ្នាំ',
                      icon: Icons.calendar_today_rounded,
                    ),
                  ]),
                  const SizedBox(height: 25),
                  _buildSectionTitle('ឯកសារវេជ្ជសាស្ត្រ', context),
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

  // --- Formal UI Components ---

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
        'ពាក្យសុំច្បាប់ឈឺ',
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
      child: Row(
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
              const Text(
                'ប្រភេទច្បាប់',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                'ច្បាប់ឈឺ (Sick Leave)',
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
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
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
                  ? 'ឯកសារភ្ជាប់៖ ${_pickedFile!.name}'
                  : 'ចុចទីនេះដើម្បីភ្ជាប់លិខិតបញ្ជាក់ពីពេទ្យ',
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
                "ចុចម្ដងទៀតដើម្បីប្ដូរឯកសារ",
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
        child: const Text(
          'បញ្ជូនសំណើផ្លូវការ',
          style: TextStyle(
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
