import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowCustomers extends StatefulWidget {
  const ShowCustomers({super.key});

  @override
  State<ShowCustomers> createState() => _ShowCustomersState();
}

class _ShowCustomersState extends State<ShowCustomers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(title: const Text("Customers"), centerTitle: true),

      body: GetBuilder<CustomerController>(
        builder: (controller) {
          return controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.customers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// 🟣 أيقونة داخل دائرة
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.people_alt_outlined,
                            size: 60,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// 📝 العنوان
                        const Text(
                          "No Customers Yet",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// 🧾 الوصف
                        const Text(
                          "Start by adding your first customer.\nManage your clients easily from here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// ➕ زر إضافة
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.toNamed(AppRoutes.addCustomer);
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Add Customer"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.customers.length,
                  itemBuilder: (context, index) {
                    final c = controller.customers[index];

                    return _customerCard(c);
                  },
                );
        },
      ),
    );
  }

  /// ================= CUSTOMER CARD =================
  Widget _customerCard(dynamic c) {
    final address = c.address;
    final controller = Get.find<CustomerController>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Text(
                  c.customerName[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 10),

              /// NAME + MOBILE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      c.customerMobile,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              /// COUNTRY
              Chip(
                label: Text(
                  c.country?.name ?? "",
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// ADDRESS
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.red),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  "${address?.line1 ?? ""}, ${address?.line2 ?? ""}, ${address?.usCity ?? ""}, ${address?.postCode ?? ""}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// ACTIONS
          Row(
            children: [
              /// CALL
              IconButton(
                onPressed: () async {
                  final uri = Uri.parse("tel:${c.customerMobile}");
                  await launchUrl(uri);
                },
                icon: const Icon(Icons.call, color: Colors.green),
              ),

              /// MAP
              IconButton(
                onPressed: () async {
                  final addressText =
                      "${address?.line1 ?? ""}, ${address?.line2 ?? ""}, ${address?.usCity ?? ""}, ${address?.postCode ?? ""}, USA";

                  final url =
                      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addressText)}";

                  await launchUrl(Uri.parse(url));
                },
                icon: const Icon(Icons.map, color: Colors.blue),
              ),

              const Spacer(),

              /// EDIT
              TextButton.icon(
                onPressed: () {
                  controller.currentCustomerId = c.globalCustomerId;
                  controller.line1Controller.text = address?.line1 ?? "";
                  controller.line2Controller.text = address?.line2 ?? "";
                  controller.cityController.text = address?.usCity ?? "";
                  controller.zipController.text = address?.postCode ?? "";
                  controller.firstNameController.text = c.customerName
                      .split(" ")
                      .first;
                  controller.emailController.text = c.customerEmail ?? "";
                  controller.lastNameController.text =
                      c.customerName.split(" ").length > 1
                      ? c.customerName.split(" ").sublist(1).join(" ")
                      : "";
                  controller.phoneController.text = c.customerMobile;
                  controller.isEdit = true;

                  Get.toNamed(AppRoutes.addCustomer);
                },
                icon: const Icon(Icons.edit),
                label: const Text("Edit"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
