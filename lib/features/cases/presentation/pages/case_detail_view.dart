import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/cases/presentation/pages/case_detail_view.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/ActionButton.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/CarInfoCard.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/EmptyServices.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/ServiceCard.dart';
import 'package:apx_cars_repair/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class CaseDetailView extends StatefulWidget {
  const CaseDetailView({super.key});

  @override
  State<CaseDetailView> createState() => _CaseDetailViewState();
}

class _CaseDetailViewState extends State<CaseDetailView> {
  int _currentImageIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CaseController>(
      builder: (controller) {
        final currentCase = controller.currentCase;
        if (currentCase == null) {
          return const Scaffold(body: Center(child: Text('No case selected')));
        }
        final hasImages =
            currentCase.images != null && currentCase.images!.isNotEmpty;

        return Scaffold(
          backgroundColor: surface,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // ─── Sliver App Bar ────────────────────────────────────────────
                  SliverAppBar(
                    expandedHeight: hasImages ? 260 : 140,
                    pinned: true,
                    stretch: true,
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      stretchModes: const [StretchMode.zoomBackground],
                      titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${currentCase.carInfo?.carBrand?.carBrandName} ${currentCase.carInfo?.carModel?.carModelName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            currentCase.carInfo?.carModel?.carYear?.carYearNumber ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      background: hasImages
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: currentCase.images!.length,
                                  onPageChanged: (i) =>
                                      setState(() => _currentImageIndex = i),
                                  itemBuilder: (context, index) =>
                                      Image.network(
                                        currentCase.images![index].imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 48,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                ),
                                // gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        primaryDark.withOpacity(0.85),
                                      ],
                                      stops: const [0.45, 1.0],
                                    ),
                                  ),
                                ),
                                // image count indicator
                                if (currentCase.images!.length > 1)
                                  Positioned(
                                    bottom: 52,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black45,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${_currentImageIndex + 1} / ${currentCase.images!.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [primary, primaryDark],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.directions_car_rounded,
                                  size: 72,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // ─── Body ──────────────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car Info Card
                        CarInfoCard(currentCase: currentCase),

                        const SizedBox(height: 16),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: ActionButton(
                                  label: controller.isImagesAdding
                                      ? 'Adding…'
                                      : 'Add Photos',
                                  icon: Icons.add_a_photo_rounded,
                                  color: primary,
                                  onTap: () => controller
                                      .showImagePickerOptions(currentCase.id),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ActionButton(
                                  label: 'Add Service',
                                  icon: Icons.build_circle_rounded,
                                  color: amber,
                                  onTap: () {
                                    controller.isEditService = false;
                                    controller.selectedService = null;
                                    controller.isEditingCaseService = false;
                                    controller.editingServiceId = null;
                                    controller.costController.text = '';
                                    controller.paidController.text = '';
                                    controller.discountController.text = '';

                                    controller.notesController.text = '';

                                    controller.resolved = null;
                                    showAddServiceDialog(controller);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Services header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Services',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${currentCase.caseServices?.length ?? 0}',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (currentCase.caseServices == null ||
                            currentCase.caseServices!.isEmpty)
                          EmptyServices()
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: currentCase.caseServices!.length,
                            itemBuilder: (context, index) {
                              final service = currentCase.caseServices![index];
                              return ServiceCard(service: service);
                            },
                          ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
              if (controller.isEditingCaseService)
                Container(
                  color: Colors.black45,
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }
}

void showAddServiceDialog(CaseController controller) {
  bool isSubmitting = false;
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: StatefulBuilder(
        builder: (context, setDState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dialog header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, primaryDark]),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.build_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      controller.isEditService ? 'Edit Service' : 'Add Service',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Dialog body
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    modernDropdown(controller, setDState),
                    const SizedBox(height: 16),
                    resolvedSwitch(controller, setDState),
                    const SizedBox(height: 16),
                    modernField(
                      controller: controller.notesController,
                      label: 'Notes',
                      icon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: modernField(
                            controller: controller.costController,
                            label: 'Cost',
                            icon: Icons.attach_money_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: modernField(
                            controller: controller.discountController,
                            label: 'Discount',
                            icon: Icons.discount_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    modernField(
                      controller: controller.paidController,
                      label: 'Paid',
                      icon: Icons.payment_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              // Dialog actions
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setDState(() => isSubmitting = true);
                                final data = {
                                  "caseId": controller.currentCase!.id,
                                  "serviceId":
                                      controller.selectedService?.serviceId,
                                  "resolved": controller.resolved,
                                  "notes": controller.notesController.text,
                                  "cost":
                                      double.tryParse(
                                        controller.costController.text,
                                      ) ??
                                      0,
                                  "discount":
                                      double.tryParse(
                                        controller.discountController.text,
                                      ) ??
                                      0,
                                  "paid":
                                      double.tryParse(
                                        controller.paidController.text,
                                      ) ??
                                      0,
                                };
                                debugPrint(data.toString());
                                if (controller.isEditService) {
                                  await controller.editService(data);
                                } else {
                                  await controller.addServiceToCase(data);

                                  Get.back();
                                }

                                if (context.mounted) {
                                  setDState(() => isSubmitting = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator()
                            : const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

Widget modernDropdown(CaseController controller, StateSetter setDState) {
  return DropdownButtonFormField<ServiceModel>(
    decoration: InputDecoration(
      labelText: 'Select Service',
      prefixIcon: const Icon(Icons.miscellaneous_services_rounded, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    value: controller.selectedService,
    items: controller.Services.map((service) {
      return DropdownMenuItem<ServiceModel>(
        value: service,
        child: Text(service.description),
      );
    }).toList(),
    onChanged: (value) => setDState(() => controller.selectedService = value),
  );
}

Widget resolvedSwitch(CaseController controller, StateSetter setDState) {
  final resolved = controller.resolved ?? false;
  return Container(
    decoration: BoxDecoration(
      color: resolved ? Colors.green.shade50 : Colors.orange.shade50,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: resolved ? Colors.green.shade200 : Colors.orange.shade200,
      ),
    ),
    child: SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      title: Text(
        resolved ? 'Resolved' : 'Pending',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: resolved ? Colors.green.shade700 : Colors.orange.shade700,
        ),
      ),
      secondary: Icon(
        resolved ? Icons.check_circle_rounded : Icons.pending_rounded,
        color: resolved ? Colors.green.shade600 : Colors.orange.shade600,
      ),
      value: resolved,
      activeColor: Colors.green.shade600,
      onChanged: (v) => setDState(() => controller.resolved = v),
    ),
  );
}

Widget modernField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
