import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddeditcustomesView extends StatefulWidget {
  const AddeditcustomesView({super.key});

  @override
  State<AddeditcustomesView> createState() => _AddeditcustomesViewState();
}

class _AddeditcustomesViewState extends State<AddeditcustomesView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Colors.grey[100],

          appBar: AppBar(
            elevation: 2,
            backgroundColor: Colors.indigo,
            title: Text(
              controller.isEdit ? "Edit Customer" : "Add Customer",
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  /// ================= HEADER CARD =================
                  _headerCard(controller),

                  const SizedBox(height: 15),

                  /// ================= PERSONAL INFO =================
                  _sectionTitle("Personal Information"),

                  _card(
                    children: [
                      _field(
                        controller.firstNameController,
                        "First Name *",
                        true,
                      ),
                      _field(controller.lastNameController, "Last Name", false),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// ================= CONTACT =================
                  _sectionTitle("Contact"),

                  _card(
                    children: [
                      _field(
                        controller.phoneController,
                        "Phone *",
                        true,
                        keyboard: TextInputType.phone,
                      ),
                      _field(
                        controller.emailController,
                        "Email",
                        false,
                        keyboard: TextInputType.emailAddress,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// ================= ADDRESS =================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Address",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Select address from map",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            controller.addressSearchController.clear();
                            controller.results.clear(); 
                            Get.dialog(
                              GetBuilder<CustomerController>(
                                builder: (controller) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 20,
                                          color: Colors.black.withOpacity(0.1),
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        /// HEADER
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.blue,
                                              ),
                                            ),
                                
                                            const SizedBox(width: 12),
                                
                                            const Expanded(
                                              child: Text(
                                                "Search Address",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                
                                            InkWell(
                                              borderRadius: BorderRadius.circular(
                                                100,
                                              ),
                                              onTap: () => Get.back(),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Icon(Icons.close),
                                              ),
                                            ),
                                          ],
                                        ),
                                
                                        const SizedBox(height: 20),
                                
                                        /// SEARCH FIELD
                                        TextField(
                                          controller:
                                              controller.addressSearchController,
                                          onChanged: (value) {
                                            controller.search(value);
                                          },
                                          decoration: InputDecoration(
                                            hintText: "Type address here...",
                                            prefixIcon: const Icon(Icons.search),
                                            filled: true,
                                            fillColor: Colors.grey.shade100,
                                
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 14,
                                                ),
                                
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                16,
                                              ),
                                              borderSide: BorderSide.none,
                                            ),
                                
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                16,
                                              ),
                                              borderSide: BorderSide.none,
                                            ),
                                
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(
                                                16,
                                              ),
                                              borderSide: BorderSide(
                                                color: Colors.blue,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                
                                        const SizedBox(height: 16),
                                
                                        /// LOADING
                                        if (controller.isSearchLoading)
                                          const Padding(
                                            padding: EdgeInsets.all(20),
                                            child: CircularProgressIndicator(),
                                          ),
                                
                                        /// EMPTY
                                        if (!controller.isSearchLoading &&
                                            controller.results.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 30,
                                            ),
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.location_off,
                                                  size: 50,
                                                  color: Colors.grey.shade400,
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  "No addresses found",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                
                                        /// RESULTS
                                        if (controller.results.isNotEmpty)
                                          Container(
                                            height: 300,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(
                                                18,
                                              ),
                                            ),
                                
                                            child: ListView.separated(
                                              padding: const EdgeInsets.all(10),
                                              itemCount:
                                                  controller.results.length,
                                
                                              separatorBuilder: (_, __) =>
                                                  const SizedBox(height: 8),
                                
                                              itemBuilder: (context, index) {
                                                final item =
                                                    controller.results[index];
                                
                                                return Material(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                
                                                  child: InkWell(
                                                    borderRadius:
                                                        BorderRadius.circular(16),
                                
                                                    onTap: () {
                                                      controller
                                                              .addressSearchController
                                                              .text =
                                                          item['display_name'];
                                
                                                      Get.back();
                                                    },
                                
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            14,
                                                          ),
                                
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  10,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.blue
                                                                  .withOpacity(
                                                                    0.1,
                                                                  ),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                            child: const Icon(
                                                              Icons.location_on,
                                                              color: Colors.blue,
                                                              size: 20,
                                                            ),
                                                          ),
                                
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                
                                                              children: [
                                                                Text(
                                                                  item['name'] ??
                                                                      '',
                                                                  style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                
                                                                Text(
                                                                  item['display_name'] ??
                                                                      '',
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade700,
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                                }
                              ),
                            );
                          },

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 147, 177, 30),
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: const Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        InkWell(
                          borderRadius: BorderRadius.circular(12),

                          onTap: () {
                            Get.toNamed(AppRoutes.map);
                          },

                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: const Row(
                              children: [
                                Icon(
                                  Icons.map_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),

                                SizedBox(width: 6),

                                Text(
                                  "Map",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  _card(
                    children: [
                      _field(controller.line1Controller, "Line 1", false),
                      _field(controller.line2Controller, "Line 2", false),
                      _field(controller.cityController, "City", false),
                      _field(
                        controller.zipController,
                        "ZIP Code",
                        false,
                        keyboard: TextInputType.number,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          /// ================= BOTTOM BUTTON =================
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      controller.isEdit
                          ? controller.editCustomer(
                              controller.currentCustomerId!,
                            )
                          : controller.addCustomer();
                    },
                    icon: Icon(
                      controller.isEdit ? Icons.edit : Icons.add,
                      color: Colors.white,
                    ),
                    label: controller.isSaveLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            controller.isEdit ? "Update" : "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ================= WIDGETS =================

  Widget _headerCard(CustomerController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Colors.indigo, Colors.blue]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        controller.isEdit ? "Update customer details" : "Create a new customer",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    bool required, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return "$label is required";
                }
                return null;
              }
            : null,
      ),
    );
  }
}
