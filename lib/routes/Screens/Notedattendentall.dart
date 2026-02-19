import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:google_fonts/google_fonts.dart';

class Notedattendentall extends StatefulWidget {
  const Notedattendentall({super.key});

  @override
  State<Notedattendentall> createState() => _NotedattendentallState();
}

class _NotedattendentallState extends State<Notedattendentall> {
  final TextEditingController _searchCtrl = TextEditingController();

  int selectedIndex = 0;

  final List<String> categories = [
    AppStrings.tr("កំណត់ត្រាទាំងអស់"),
    AppStrings.tr("យឺតយ៉ាវ"),
    AppStrings.tr("បុគ្គលិកក្រៅការិយាល័យ"),
    AppStrings.tr("បានអនុម័ត"),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.lightSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WorkSmart',
              style: GoogleFonts.hanuman(
                fontWeight: FontWeight.w700,
                color: AppColors.lightSurface,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  AppStrings.tr('កំណត់ត្រាវត្តមានផ្ទាល់'),
                  style: GoogleFonts.hanuman(
                    fontSize: 12,
                    color: AppColors.lightSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.secondary),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Filter clicked')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 8),
          _buildCategories(),
          const SizedBox(height: 42),
          _buildNotedStaff(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 50,
        child: TextField(
          controller: _searchCtrl,
          onChanged: (context) => setState(() {}),
          style: const TextStyle(color: Color(0xFFCAC3C3)),
          decoration: InputDecoration(
            hintText: 'ស្វែងរកបុគ្គលិក…',
            hintStyle: const TextStyle(color: AppColors.cagories),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF7F8AA3),
            ),
            filled: true,
            fillColor: AppColors.lightSurface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 35,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(categories[index], index);
        },
      ),
    );
  }

  Widget _buildCategoryItem(String title, int index) {
    final bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cagories,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: GoogleFonts.hanuman(
            color: AppColors.textLight,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildNotedStaff() {
    return Stack(
      clipBehavior:
          Clip.none, // IMPORTANT: allows the dot to show outside the card
      children: [
        Positioned(
          left: -6,
          top: 24,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),

        Container(
          width: double.infinity, // helps avoid unbounded-width issues in rows
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Marcus Chen",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "០៩:៤១ ព្រឹក • ២ នាទីមុន",
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E4A34),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.success, width: 2),
                    ),
                    child: Text(
                      AppStrings.tr("ទាន់ពេល"),
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.amber, size: 18),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      AppStrings.tr("១២៣ ផ្លូវពាណិជ្ជកម្ម, តំបន់ខាងជើង"),
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.asset(
                      "assets/map_preview.png",
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          AppStrings.tr("២០០ ម៉ែត្រ ពីការិយាល័យកណ្តាល"),
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
