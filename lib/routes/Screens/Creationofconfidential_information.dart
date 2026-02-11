import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreationofconfidentialInformation extends StatelessWidget {
  const CreationofconfidentialInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2A2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2A2A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'ការបង្កើតព័ត៍មានសម្ងាត់',
          style: GoogleFonts.hanuman(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _StepBar(active: false),
                  SizedBox(width: 10),
                  _StepBar(active: false),
                  SizedBox(width: 10),
                  _StepBar(active: true),
                ],
              ),
              const SizedBox(height: 44),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF7C07B), Color(0xFFF3A15A)],
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: -22,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF19B07E),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'ផ្ទៀងផ្ទាត់រួចរាល់',
                            style: GoogleFonts.hanuman(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              const Text(
                'សេចក្តីអនុម័តជោគជ័យ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'ការផ្ទៀងផ្ទាត់ជីវមាត្រត្រូវបញ្ចាក់',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFB7C9C7), height: 1.3),
              ),
              const SizedBox(height: 24),

              // User confidential info
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ព័ត៍មានសម្ងាត់អ្នកប្រើប្រាស់',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'កូដ/លេខសម្គាល់',
                  style: TextStyle(
                    color: Color(0xFFB7C9C7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _FieldCard(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'WS-2024-8892',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.copy, color: Color(0xFFB7C9C7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'លេខសម្ងាត់',
                  style: TextStyle(
                    color: Color(0xFFB7C9C7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _FieldCard(
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '••••••••••••••',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.visibility,
                        color: Color(0xFFB7C9C7),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.content_paste,
                        color: Color(0xFFFFC12E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '* លេខសម្ងាត់នេះមានសុពលភាពត្រឹមតែ 24 ម៉ោងប៉ុណ្ណោះ',
                  style: TextStyle(color: Color(0xFF6F8E8B)),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF163A39),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF245B57)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFB7C9C7)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ការចុចប៊ូតុងខាងក្រោមនឹងផ្ញើព័ត៍មានសម្ងាត់ទាំងនេះដោយស្វ័យប្រវត្តិទៅកាន់គណនី Telegram របស់បុគ្គលិក។',
                        style: TextStyle(color: Color(0xFFB7C9C7), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E6C60),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'បង្គើត និងផ្ញើទៅ Telegram',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'បោះបង់',
                  style: TextStyle(color: Color(0xFFB7C9C7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  final bool active;
  const _StepBar({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 6,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF19B07E) : const Color(0xFF153C3A),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final Widget child;
  const _FieldCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF123635),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D4B47)),
      ),
      child: child,
    );
  }
}
