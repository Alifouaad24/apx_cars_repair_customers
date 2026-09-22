import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class CrmDashboardView extends StatelessWidget {
  const CrmDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -80,
              left: -80,
              child: _backgroundCircle(
                size: 220,
                color: const Color(0xFFEAF2FF),
              ),
            ),

            Positioned(
              top: 80,
              right: -100,
              child: _backgroundCircle(
                size: 220,
                color: const Color(0xFFF0F6FF),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 32,
              ),
              child: Column(
                children: [

              

                  // Cards
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _TypeCard(
                          title: 'Customers',
                          description: 'Manage your customers\nand their information',
                          icon: Icons.people_alt_rounded,
                          iconColor: const Color(0xFF3478F6),
                          iconBackground: const Color(0xFFEAF2FF),
                          bottomColor: const Color(0xFFE8F1FF),
                          buttonColor: const Color(0xFF3478F6),
                          onTap: () {
                            Get.toNamed(AppRoutes.showCustomers);
                          },
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _TypeCard(
                          title: 'Consumer business',
                          description: 'Manage businesses and details',
                          icon: Icons.storefront_rounded,
                          iconColor: const Color(0xFF12B894),
                          iconBackground: const Color(0xFFE3F8F3),
                          bottomColor: const Color(0xFFDDF7F0),
                          buttonColor: const Color(0xFF12B894),
                          onTap: () {
                            Get.toNamed(AppRoutes.showConsumerBusinesses);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _backgroundCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TypeCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color bottomColor;
  final Color buttonColor;
  final VoidCallback onTap;

  const _TypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.bottomColor,
    required this.buttonColor,
    required this.onTap,
  });

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 430,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Bottom decoration
              Positioned(
                bottom: -35,
                left: -30,
                right: -30,
                child: Container(
                  height: 125,
                  decoration: BoxDecoration(
                    color: widget.bottomColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(100),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 42,
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: widget.iconBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 48,
                        color: widget.iconColor,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF173675),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Description
                    Text(
                      widget.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Color(0xFF7183A2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const Spacer(),

                    // Arrow button
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: widget.buttonColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.buttonColor.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 29,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}