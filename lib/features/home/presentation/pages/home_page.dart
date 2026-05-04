import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/widgets/result_vin_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.indigo],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Manage your customers easily",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// CUSTOMER CARD
            InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.showCustomers);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 15),

                    /// TEXT
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Customers",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "View and manage all customers",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const Icon(Icons.arrow_forward_ios, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// FUTURE CARDS (placeholder)
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    title: "Add Customer",
                    icon: Icons.person_add,
                    color: Colors.green,
                    onTap: () {
                      Get.toNamed(AppRoutes.addCustomer);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSmallCard(
                    title: "Scan Chaseh",
                    icon: Icons.qr_code_scanner_sharp,
                    color: Colors.orange,
                    onTap: () {
                      Get.toNamed(AppRoutes.scanChaseh);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildSmallCard(
                    title: "Search Car",
                    icon: Icons.search,
                    color: Colors.green,
                    onTap: () {
                      
                      Get.dialog(ResultVinDialog());
                    },
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: _buildSmallCard(
                    title: "About Us",
                    icon: Icons.info,
                    color: Colors.green,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
