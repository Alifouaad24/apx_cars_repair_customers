import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Showschadualcases extends StatefulWidget {
  const Showschadualcases({super.key});

  @override
  State<Showschadualcases> createState() => _ShowschadualcasesState();
}

class _ShowschadualcasesState extends State<Showschadualcases> {
  final List<Map<String, dynamic>> items = [
    {
      "title": "New Schedule",
      "icon": Icons.add_circle_outline_rounded,
      "color": const Color(0xFF2563EB),
    },
    {
      "title": "Today's Appointments",
      "icon": Icons.today_rounded,
      "color": const Color(0xFF0F766E),
    },
    {
      "title": "Late Appointments",
      "icon": Icons.schedule_rounded,
      "color": const Color(0xFFDC2626),
    },
    {
      "title": "Postponed Appointments",
      "icon": Icons.pause_circle_outline_rounded,
      "color": const Color(0xFFD97706),
    },
    {
      "title": "Scheduled Appointments",
      "icon": Icons.event_available_rounded,
      "color": const Color(0xFF7C3AED),
    },
    {
      "title": "Unscheduled Appointments",
      "icon": Icons.event_busy_rounded,
      "color": const Color(0xFF475569),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        centerTitle: true,
        title: Text(
          'Appointments',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16.h,
            crossAxisSpacing: 16.w,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = items[index];

            return _buildCard(
              title: item['title'],
              icon: item['icon'],
              color: item['color'],
              onTap: () {},
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: 65.w,
              height: 65.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Icon(
                icon,
                color: color,
                size: 34.r,
              ),
            ),

            SizedBox(height: 18.h),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}