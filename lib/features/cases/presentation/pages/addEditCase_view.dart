import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderStatusModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddeditCaseView extends StatefulWidget {
  const AddeditCaseView({super.key});

  @override
  State<AddeditCaseView> createState() => _AddeditCaseViewState();
}

class _AddeditCaseViewState extends State<AddeditCaseView> {
  static const Color _primary = Color(0xFF0E7490);
  static const Color _primaryDark = Color(0xFF155E75);
  static const Color _surface = Color(0xFFF8FAFC);
  static const Color _mutedText = Color(0xFF475569);

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
              controller.isUpdate ? "Edit Order" : "Add Order",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE2F8FB), Color(0xFFF8FAFC)],
                    stops: [0.0, 0.45],
                  ),
                ),
              ),
              Positioned(
                top: -40,
                right: -30,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x3322D3EE),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -40,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x1A0E7490),
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // _heroBanner(controller),
                        // const SizedBox(height: 14),
                        // _softInfoTile(),
                        const SizedBox(height: 2),
                        _sectionTitle(
                          "Order Information",
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
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Please select customer";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: const [
                                Icon(
                                  Icons.note_alt_outlined,
                                  color: Color(0xFF0F766E),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Notes",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            _field(
                              controller.notesController,
                              "Notes",
                              false,
                              icon: Icons.note,
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.date_range,
                                  color: Color(0xFF0F766E),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Scaduale Date",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: controller.visitDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  controller.visitDate = pickedDate;
                                  controller.update();
                                }
                              },
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      color: Color(0xFF0F766E),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(controller.visitDate),
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: const [
                                Icon(
                                  Icons.timelapse,
                                  color: Color(0xFF0F766E),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Scaduale Time",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () async {
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: controller.visitTime,
                                );

                                if (pickedTime != null) {
                                  controller.visitTime = pickedTime;
                                  controller.update();
                                }
                              },
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Color(0xFF0F766E),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      controller.visitTime.format(context),
                                      style: const TextStyle(
                                        color: Color(0xFF334155),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<ServiceModel>(
                              value: controller.selectedService,
                              decoration: _inputDecoration(
                                label: "Select Service",
                                icon: Icons.design_services,
                              ),
                              items: controller.Services.map((se) {
                                return DropdownMenuItem<ServiceModel>(
                                  value: se,
                                  child: Text(se.description),
                                );
                              }).toList(),
                              onChanged: (value) {
                                controller.selectedService = value;
                                controller.update();
                              },
                            ),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<OrderStatusModel>(
                              value: controller.selectedStatus,
                              decoration: _inputDecoration(
                                label: "Select Status",
                                icon: Icons.cases,
                              ),
                              items: controller.OrderStatus.map((status) {
                                return DropdownMenuItem<OrderStatusModel>(
                                  value: status,
                                  child: Text(status.statusAr),
                                );
                              }).toList(),
                              onChanged: (value) {
                                controller.selectedStatus = value;
                                controller.update();
                              },
                              validator: (value) {
                                if (value == null) {
                                  return "Please select Status";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),
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
                                      controller.isUpdate ? controller.editCase() :
                                      controller.submitCase();
                                    }
                                  },
                                  icon: Icon(
                                    controller.isAddingCase
                                        ? Icons.hourglass_top_rounded
                                        : Icons.check_circle_outline,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    controller.isAddingCase
                                        ? "Submitting..."
                                        : (controller.isEdit
                                              ? "Save Changes"
                                              : "Submit Order"),
                                    style: const TextStyle(
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
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFBFEFF)],
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
