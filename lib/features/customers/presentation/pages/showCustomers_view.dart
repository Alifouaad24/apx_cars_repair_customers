import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
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

      appBar: AppBar(
        title: const Text("Customers"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(0, 19, 120, 131),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.addCustomer);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),

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
                        const SizedBox(height: 24),

                        if (controller.customers.length !=
                            controller.allCustomers.length)
                          ElevatedButton.icon(
                            onPressed: () {
                              controller.customers = controller.allCustomers;
                              controller.update();
                            },
                            icon: const Icon(Icons.list),
                            label: const Text("Show All Customers"),
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            controller.filterCustomers(value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search customers...",
                            hintStyle: TextStyle(color: Colors.grey.shade500),

                            /// 🔍 أيقونة البحث
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                            ),

                            /// ❌ زر مسح النص
                            suffixIcon: IconButton(
                              icon: Icon(Icons.close, color: Colors.grey),
                              onPressed: () {
                                controller.filterCustomers("");
                              },
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 1.5,
                              ),
                            ),

                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.customers.length,
                        itemBuilder: (context, index) {
                          final c = controller.customers[index];

                          return _customerCard(c);
                        },
                      ),
                    ),
                  ],
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
              TextButton.icon(
                onPressed: () async {
                  await Get.find<CaseController>().loadCustomers();
                  Get.find<CaseController>().selectedCustomer =
                      Get.find<CaseController>().customers.firstWhere(
                        (customer) =>
                            customer.globalCustomerId == c.globalCustomerId,
                      );
                  Get.toNamed(AppRoutes.addEditCase);
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text("New Case"),
              ),
            ],
          ),

          const SizedBox(height: 10),
          if (c.imageUrl != null && c.imageUrl.toString().isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    c.imageUrl,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text("Camera"),
                                onTap: () async {
                                  Get.back();

                                  controller.pickCustomerImage(
                                    customerId: c.globalCustomerId,
                                    fromCamera: true,
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo),
                                title: const Text("Gallery"),
                                onTap: () async {
                                  Get.back();

                                  controller.pickCustomerImage(
                                    customerId: c.globalCustomerId,
                                    fromCamera: false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text("Camera"),
                          onTap: () async {
                            Get.back();

                            controller.pickCustomerImage(
                              customerId: c.globalCustomerId,
                              fromCamera: true,
                            );
                          },
                        ),

                        ListTile(
                          leading: const Icon(Icons.photo),
                          title: const Text("Gallery"),
                          onTap: () async {
                            Get.back();

                            controller.pickCustomerImage(
                              customerId: c.globalCustomerId,
                              fromCamera: false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "Add Customer Image",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

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

                  final uri = Uri.parse(
                    "google.navigation:q=${Uri.encodeComponent(addressText)}",
                  );

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    final webUrl =
                        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(addressText)}";
                    await launchUrl(Uri.parse(webUrl));
                  }
                },
                icon: const Icon(Icons.map, color: Colors.blue),
              ),

              const Spacer(),
              // Delete Button
              IconButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: "Delete Customer",
                    middleText:
                        "Are you sure you want to delete this customer?",
                    textCancel: "Cancel",
                    textConfirm: "Delete",
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      controller.deleteCustomer(c.globalCustomerId);
                      Get.back();
                    },
                  );
                },
                icon: const Icon(Icons.delete, color: Colors.red),
              ),

              /// EDIT
              IconButton(
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
                icon: const Icon(Icons.edit, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
