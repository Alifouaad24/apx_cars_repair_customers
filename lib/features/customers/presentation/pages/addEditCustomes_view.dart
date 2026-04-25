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
                      _field(
                        controller.lastNameController,
                        "Last Name",
                        false,
                      ),
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
                  _sectionTitle("Address (USA)"),

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
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black12,
                )
              ],
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
                      controller.isEdit ? controller.editCustomer(controller.currentCustomerId!) :
                     controller.addCustomer();
                    },
                    icon: Icon(controller.isEdit ? Icons.edit : Icons.add, color: Colors.white),
                    label: controller.isSaveLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(controller.isEdit ? "Update" : "Save", style: TextStyle(color: Colors.white)),
                  ),
                ),

                const SizedBox(width: 10),

                OutlinedButton.icon(
                  onPressed: controller.openInMaps,
                  icon: const Icon(Icons.map),
                  label: const Text("Map"),
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
        gradient: const LinearGradient(
          colors: [Colors.indigo, Colors.blue],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        controller.isEdit
            ? "Update customer details"
            : "Create a new customer",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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