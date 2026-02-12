import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminAttendace extends StatefulWidget {
    const AdminAttendace({super.key}); 
@override
  State<AdminAttendace> createState() => _AdminAttendaceState();
}

class _AdminAttendaceState extends State<AdminAttendace> {
  DateTime _currentViewDate = DateTime.now();
  int? _selectedDay;


  final Map<int, Map<String, dynamic>> attendanceData = {
    1: {'s': 'present', 'c': Colors.green},
    2: {'s': 'late', 'c': Colors.orange},
    5: {'s': 'absent', 'c': Colors.red},
    10: {'s': 'present', 'c': Colors.green},
    15: {'s': 'late', 'c': Colors.orange},
    20: {'s': 'present', 'c': Colors.green},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2A27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F2A27),
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios, color: Colors.white),
        title: const Text(
          "របាយការណ៍វត្តមាន",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 15),
          Icon(Icons.more_vert, color: Colors.white),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Summary Cards =====
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    "មធ្យមភាគវត្តមាន",
                    "៩៤.២%",
                    "+២%",
                    true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    "បុគ្គលិកសរុប",
                    "១២៤",
                    "សកម្ម",
                    false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== Calendar =====
            _buildCalendarSection(),

            const SizedBox(height: 25),

            const Text(
              "ស្ថិតិបុគ្គលិក",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _buildEmployeeTableHeader(),
            const SizedBox(height: 10),

            _buildEmployeeItem("សុខ ចាន់", "WS-001", "២២ ថ្ងៃ", "០២", "០០", Colors.orange),
            _buildEmployeeItem("កញ្ញា ស្រីនា", "WS-042", "២២ ថ្ងៃ", "០០", "០២", Colors.blue),
            _buildEmployeeItem("សេង បូរិន", "WS-018", "២១ ថ្ងៃ", "០៥", "០១", Colors.red),
            _buildEmployeeItem("លីដា រតនា", "WS-102", "២២ ថ្ងៃ", "០១", "០០", Colors.pink),

            const SizedBox(height: 25),

         
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_upload_outlined, color: Colors.black),
                label: const Text(
                  "ទាញយកជា CSV / PDF",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= SUMMARY CARD =================

  Widget _summaryCard(
      String title, String value, String subValue, bool trendUp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D3A36),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              if (trendUp)
                const Icon(Icons.trending_up, color: Colors.green, size: 16),
              Text(
                subValue,
                style: TextStyle(
                    color: trendUp ? Colors.green : Colors.white38,
                    fontSize: 12),
              )
            ],
          )
        ],
      ),
    );
  }


  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D322F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildCalendarTopBar(),
          const SizedBox(height: 10),
          _buildWeekDays(),
          const SizedBox(height: 10),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _getMonthYearText(_currentViewDate),
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white70),
              onPressed: () => _updateMonth(-1),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white70),
              onPressed: () => _updateMonth(1),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildWeekDays() {
    final days = ["ច", "អ", "ព", "ព្រ", "សុ", "ស", "អា"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days
          .map((d) => const Text(
                "",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ))
          .toList()
          .asMap()
          .entries
          .map((e) => Text(days[e.key],
              style: const TextStyle(color: Colors.white38, fontSize: 12)))
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    int daysInMonth =
        DateUtils.getDaysInMonth(_currentViewDate.year, _currentViewDate.month);

    int firstWeekday =
        DateTime(_currentViewDate.year, _currentViewDate.month, 1).weekday;

    List<Widget> cells = [];

    for (int i = 1; i < firstWeekday; i++) {
      cells.add(_buildDayCell(0, true));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      cells.add(_buildDayCell(day, false));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: cells,
    );
  }

  Widget _buildDayCell(int day, bool isGrey) {
    bool isSelected = _selectedDay == day && !isGrey;

    var dayData = isGrey ? null : attendanceData[day];
    Color? dotColor =
        (dayData != null && dayData['s'] != "no_data") ? dayData['c'] : null;

    return GestureDetector(
      onTap: isGrey
          ? null
          : () {
              setState(() {
                _selectedDay = day;
              });
            },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color:
                  isSelected ? const Color(0xFF00796B) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              isGrey || day == 0 ? "" : "$day",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (!isGrey && dotColor != null)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  void _updateMonth(int change) {
    setState(() {
      _currentViewDate =
          DateTime(_currentViewDate.year, _currentViewDate.month + change);
      _selectedDay = null;
    });
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      "មករា",
      "កុម្ភៈ",
      "មីនា",
      "មេសា",
      "ឧសភា",
      "មិថុនា",
      "កក្កដា",
      "សីហា",
      "កញ្ញា",
      "តុលា",
      "វិច្ឆិកា",
      "ធ្នូ"
    ];
    return "${months[date.month - 1]} ${date.year}";
  }



  Widget _buildEmployeeTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF233E3A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Expanded(
              flex: 3,
              child: Text("ឈ្មោះ",
                  style: TextStyle(color: Colors.white38, fontSize: 12))),
          Expanded(
              child: Text("វត្តមាន",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38))),
          Expanded(
              child: Text("យឺត",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38))),
          Expanded(
              child: Text("អវត្តមាន",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38))),
        ],
      ),
    );
  }

  Widget _buildEmployeeItem(String name, String id, String total,
      String late, String absent, Color avatarColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D322F),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: avatarColor.withOpacity(0.3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          LinearGradient(colors: [avatarColor, Colors.white24]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                    Text(id,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
          Expanded(
              child: Text(total,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white))),
          Expanded(
              child: Text(late,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.orange))),
          Expanded(
              child: Text(absent,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}