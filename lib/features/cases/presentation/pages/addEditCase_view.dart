import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddeditCaseView extends StatefulWidget {
  const AddeditCaseView({super.key});

  @override
  State<AddeditCaseView> createState() => _AddeditCaseViewState();
}

class _AddeditCaseViewState extends State<AddeditCaseView> {
  static const Color _primary = Color(0xFF0E7490);
  static const Color _primaryDark = Color(0xFF155E75);
  static const Color _surface = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CaseController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: _surface,

          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primary, _primaryDark],
                ),
              ),
            ),
            title: Text(
              controller.isEdit ? "Edit Case" : "Add Case",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE2F8FB), Color(0xFFF8FAFC)],
                stops: [0.0, 0.45],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    _sectionTitle(
                      "Case Information",
                      Icons.directions_car_filled,
                    ),
                    _card(
                      children: [
                        DropdownButtonFormField<CustomerModel>(
                          value: controller.selectedCustomer,
                          decoration: _inputDecoration(
                            label: "Select Customer",
                            icon: Icons.person_outline,
                          ),
                          items: controller.customers.map((customer) {
                            return DropdownMenuItem<CustomerModel>(
                              value: customer,
                              child: Text(customer.customerName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.selectedCustomer = value;
                            controller.update();
                            print(value?.globalCustomerId);
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Please select customer";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _field(
                                controller.vinNumberController,
                                "VIN Number",
                                true,
                                icon: Icons.pin_outlined,
                              ),
                            ),
                            const SizedBox(width: 2),
                            SizedBox(
                              height: 50,
                              child: IconButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _primaryDark,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: () async {
                                  final result = await Get.toNamed(
                                    AppRoutes.scanChaseh,
                                    arguments: {'returnResult': true},
                                  );

                                  if (result is Map<String, dynamic>) {
                                    controller.fillFromScannedCarData(result);
                                    return;
                                  }

                                  if (result is Map) {
                                    controller.fillFromScannedCarData(
                                      Map<String, dynamic>.from(result),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                              ),
                            ),
                          ],
                        ),
                        _field(
                          controller.yearController,
                          "Year",
                          false,
                          keyboard: TextInputType.number,
                          icon: Icons.calendar_today_outlined,
                        ),
                        _field(
                          controller.brandController,
                          "Brand",
                          false,
                          icon: Icons.local_offer_outlined,
                        ),
                        _field(
                          controller.modelController,
                          "Model",
                          false,
                          icon: Icons.directions_car_outlined,
                        ),
                      ],
                    ),
                    // const SizedBox(height: 16),
                    // _sectionTitle(
                    //   "Vehicle Images",
                    //   Icons.photo_library_outlined,
                    // ),
                    // _card(
                    //   children: [
                    //     InkWell(
                    //       borderRadius: BorderRadius.circular(14),
                    //       onTap: () {
                    //         controller.pickImages();
                    //       },
                    //       child: Ink(
                    //         height: 58,
                    //         width: double.infinity,
                    //         decoration: BoxDecoration(
                    //           color: const Color(0xFFECFEFF),
                    //           borderRadius: BorderRadius.circular(14),
                    //           border: Border.all(
                    //             color: const Color(0xFF67E8F9),
                    //           ),
                    //         ),
                    //         child: const Row(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Icon(
                    //               Icons.add_photo_alternate_outlined,
                    //               color: _primaryDark,
                    //             ),
                    //             SizedBox(width: 10),
                    //             Text(
                    //               "Take Images",
                    //               style: TextStyle(
                    //                 fontWeight: FontWeight.w700,
                    //                 color: _primaryDark,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //     const SizedBox(height: 14),
                    //     if (controller.images.isNotEmpty)
                    //       Wrap(
                    //         spacing: 10,
                    //         runSpacing: 10,
                    //         children: controller.images.map<Widget>((img) {
                    //           return Stack(
                    //             children: [
                    //               ClipRRect(
                    //                 borderRadius: BorderRadius.circular(14),
                    //                 child: Image.file(
                    //                   img,
                    //                   width: 104,
                    //                   height: 104,
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //               ),
                    //               Positioned(
                    //                 right: 4,
                    //                 top: 4,
                    //                 child: GestureDetector(
                    //                   onTap: () {
                    //                     controller.removeImage(img);
                    //                   },
                    //                   child: Container(
                    //                     padding: const EdgeInsets.all(4),
                    //                     decoration: const BoxDecoration(
                    //                       color: Color(0xFFB91C1C),
                    //                       shape: BoxShape.circle,
                    //                     ),
                    //                     child: const Icon(
                    //                       Icons.close,
                    //                       size: 14,
                    //                       color: Colors.white,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           );
                    //         }).toList(),
                    //       )
                    //     else
                    //       Container(
                    //         width: double.infinity,
                    //         padding: const EdgeInsets.symmetric(vertical: 18),
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(12),
                    //           border: Border.all(
                    //             color: const Color(0xFFCBD5E1),
                    //           ),
                    //         ),
                    //         child: const Text(
                    //           "No images selected yet",
                    //           textAlign: TextAlign.center,
                    //           style: TextStyle(
                    //             color: Color(0xFF64748B),
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ),
                    //       ),
                    //   ],
                    // ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_primary, _primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33155E75),
                              blurRadius: 14,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            if (!controller.isAddingCase) {
                              controller.submitCase();
                            }
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                          ),
                          label: controller.isAddingCase
                              ? const Text(
                                  "Submitting...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : const Text(
                                  "Submit Case",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _heroBanner(CaseController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33155E75),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.isEdit ? "Update Case" : "Create New Case",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Fill in vehicle details, attach images, and save in one step.",
            style: TextStyle(color: Color(0xFFE0F2FE), fontSize: 13.5),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _primaryDark),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: Icon(icon, color: const Color(0xFF0F766E)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    bool required, {
    TextInputType keyboard = TextInputType.text,
    IconData icon = Icons.edit_outlined,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: _inputDecoration(label: label, icon: icon),
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
