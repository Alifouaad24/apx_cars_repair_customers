import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/cases/presentation/pages/case_detail_view.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/FinanceChip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class ServiceCard extends StatelessWidget {
  const ServiceCard({required this.service});
  final dynamic service;

  @override
  Widget build(BuildContext context) {
    final isResolved = service.resolved == true;
    final statusColor = isResolved ? Colors.green : Colors.orange;

    return GetBuilder<CaseController>(
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header with status accent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    left: BorderSide(color: statusColor, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.transparent,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.miscellaneous_services_rounded,
                                        size: 36,
                                        color: Colors.blue,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    const Text(
                                      "Service Actions",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Choose what you want to do with this service",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 15,
                                      ),
                                    ),

                                    const SizedBox(height: 28),

                                    /// Edit Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Get.back();
                                          controller.isEditService = true;
                                          controller.selectedService =
                                              controller.Services.firstWhere(
                                                (s) =>
                                                    s.serviceId ==
                                                    service.service.serviceId,
                                              );

                                          controller.editingServiceId =
                                              service.caseServiceId;
                                          controller.costController.text =
                                              service.cost?.toString() ?? '';
                                          controller.paidController.text =
                                              service.paid?.toString() ?? '';
                                          controller.discountController.text =
                                              service.discount?.toString() ??
                                              '';
                                          controller.notesController.text =
                                              service.notes ?? '';

                                          controller.resolved =
                                              service.resolved;

                                          showAddServiceDialog(controller);
                                        },
                                        icon: const Icon(Icons.edit_rounded),
                                        label: const Text(
                                          "Edit Service",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 14),

                                    /// Delete Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        icon: const Icon(Icons.delete_rounded),
                                        label: const Text(
                                          "Delete Service",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),

                                    /// Cancel
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          isResolved
                              ? Icons.check_circle_rounded
                              : Icons.pending_rounded,
                          color: statusColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        service.service?.description ?? 'Unknown Service',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isResolved ? 'Resolved' : 'Pending',
                        style: TextStyle(
                          color: statusColor.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Notes
              if (service.notes != null && service.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          service.notes!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Financial row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    FinanceChip(
                      label: 'Cost',
                      value: '\$${service.cost ?? 0}',
                      color: const Color(0xFF0E7490),
                    ),
                    const SizedBox(width: 8),
                    FinanceChip(
                      label: 'Discount',
                      value: '\$${service.discount ?? 0}',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    FinanceChip(
                      label: 'Paid',
                      value: '\$${service.paid ?? 0}',
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notes_rounded,
                                      size: 36,
                                      color: Colors.blue,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  const Text(
                                    "Service Notes",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),
                                  if (service.caseServiceNotes == null ||
                                      service.caseServiceNotes!.isEmpty)
                                    Text(
                                      "No notes for this service",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 15,
                                      ),
                                    )
                                  else
                                    ...service.caseServiceNotes!.map((note) {
                                      return Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 3,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            note.notes ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  const SizedBox(height: 28),

                                  /// Close Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: () => Get.back(),
                                      icon: const Icon(Icons.close_rounded),
                                      label: const Text("Close"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Service notes",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller:
                                        controller.serviceNoteController,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      hintText: "Add note for this service",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade100,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            List<String> note = [];
                                            note.add(
                                              controller
                                                  .serviceNoteController
                                                  .text
                                                  .trim(),
                                            );
                                            final data = {"notes": note};
                                            controller.addNoteToCaseService(
                                              service.caseServiceId,
                                              data,
                                            );
                                          },
                                          child: Text(
                                            controller.addingNoteToService
                                                ? "Adding Note..."
                                                : "Add Note",
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Get.back(),
                                          child: Text("Cancel"),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.blueGrey,
                                            side: BorderSide(
                                              color: Colors.blueGrey.shade200,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            178,
                            178,
                            26,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "+",
                          style: TextStyle(
                            color: Color.fromARGB(255, 66, 26, 12),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
