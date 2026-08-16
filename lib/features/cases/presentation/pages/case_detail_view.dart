import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/CarsDataModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart'
    hide CarBrandModel;
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/cases/presentation/pages/EmptyCarCard.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/ActionButton.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/CarInfoCard.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/EmptyServices.dart';
import 'package:apx_cars_repair/features/cases/presentation/widgets/ServiceCard.dart';
import 'package:apx_cars_repair/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          return const Scaffold(body: Center(child: Text('No Order selected')));
        }

        final CarInfoModel? primaryCarInfo = controller.currentCase?.carInfo;
        final List<OrderImage> carImages =
            controller.currentCase?.orderImages ?? const [];
        final bool hasImages = carImages.isNotEmpty;
        final bool hasServices = currentCase.orderDetails != null;

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
                    // stretch:true كان يتعارض مع سحب PageView الأفقي - أزلناه
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _carTitle(primaryCarInfo),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            primaryCarInfo?.carYear?.carYearNumber ?? '',
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
                                  itemCount: carImages.length,
                                  onPageChanged: (i) =>
                                      setState(() => _currentImageIndex = i),
                                  itemBuilder: (context, index) =>
                                      Image.network(
                                        carImages[index].ImageUrl,
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
                                // أزرار تنقل يدوية - تعمل مضمون حتى لو السحب تعطل لأي سبب
                                if (carImages.length > 1) ...[
                                  Positioned(
                                    left: 4,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: _NavArrow(
                                        icon: Icons.chevron_left_rounded,
                                        onTap: () {
                                          if (_currentImageIndex > 0) {
                                            _pageController.previousPage(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: _NavArrow(
                                        icon: Icons.chevron_right_rounded,
                                        onTap: () {
                                          if (_currentImageIndex <
                                              carImages.length - 1) {
                                            _pageController.nextPage(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                                // image count indicator
                                if (carImages.length > 1)
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
                                        '${_currentImageIndex + 1} / ${carImages.length}',
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
                        // Car Info: تفاصيل السيارة إذا موجودة، وإلا بطاقة "إضافة سيارة"
                        primaryCarInfo != null
                            ? CarInfoCard(
                                carInfo: primaryCarInfo,
                                customer: currentCase.customer,
                                scheduleDate: currentCase.scheduleDt,
                              )
                            : EmptyCarCard(
                                onAddCar: () =>
                                    showAddCarDialog(controller, currentCase),
                              ),

                        const SizedBox(height: 16),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // "أضف صور" يحتاج سيارة موجودة مسبقًا لأن الصور تابعة للسيارة لا للطلب
                              if (primaryCarInfo != null)
                                Expanded(
                                  child: ActionButton(
                                    label: controller.isImagesAdding
                                        ? 'Adding…'
                                        : 'Add Photos',
                                    icon: Icons.add_a_photo_rounded,
                                    color: primary,
                                    onTap: () =>
                                        controller.showImagePickerOptions(
                                          currentCase.globalOrderId!,
                                        ),
                                  ),
                                ),
                              if (primaryCarInfo != null)
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
                                    showAddServiceDialog(
                                      controller,
                                      currentCase,
                                    );
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
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (!hasServices)
                          EmptyServices()
                        else
                          Column(
                            children: currentCase.orderDetails!.map((detail) {
                              return ServiceCard(service: detail);
                            }).toList(),
                          ),
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

  String _carTitle(CarInfoModel? car) {
    final brand = car?.carBrand?.carBrandName ?? '';
    final model = car?.carModel?.carModelName ?? '';
    final title = '$brand $model'.trim();
    return title.isEmpty ? 'بدون سيارة' : title;
  }
}

// زر تنقل صغير شفاف يُستخدم فوق صور الهيدر للتنقل بالنقر (بديل مضمون للسحب)
class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// السيارة تابعة لكل OrderServiceModel وليس للطلب مباشرة (الطلب عام: ممكن
// يكون شحن/توصيل بلا سيارة). هذي الدالة تدور بأمان تام بدون "!" غير محمي.
CarInfoModel? _resolvePrimaryCarInfo(List<OrderServiceModel>? services) {
  if (services == null || services.isEmpty) return null;
  for (final s in services) {
    if (s.carInfo != null) return s.carInfo;
  }
  return null;
}

// ═══════════════════════════════════════════════════════════════════════
// إضافة سيارة جديدة للطلب - البراند والموديل حقول نصية حرة (بدون قوائم/IDs)
// ملاحظة: يفترض هذا الكود وجود بالـ CaseController:
//   - Future<int?> addCarToCase(Map<String, dynamic> data)
//     (يرجع CarInfoTblId الجديد حتى نقدر نفتح منتقي الصور فورًا بعده)
// إذا الاسم أو التوقيع مختلف بالكونترولر عندك، أرسله لي لأطابقه بدقة.
// ═══════════════════════════════════════════════════════════════════════
void showAddCarDialog(CaseController controller, dynamic currentCase) {
  bool isSubmitting = false;
  final brandController = TextEditingController(text: '');
  final modelController = TextEditingController(text: '');
  final yearController = TextEditingController(text: '');
  controller.vinController.text = '';

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: StatefulBuilder(
        builder: (context, setDState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary, primaryDark]),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Add Car',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<CarBrandModel>(
                        value: controller.selectedBrand,
                        decoration: modernDropdownDecoration(
                          label: 'Brand',
                          icon: Icons.directions_car_filled_rounded,
                        ),
                        items: controller.brands.map((brand) {
                          return DropdownMenuItem(
                            value: brand,
                            child: Text(brand.carBrandName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDState(() {
                            controller.selectedBrand = value;
                            controller.selectedModel = null;
                            controller.models = controller.allModels;
                            controller.models = controller.allModels
                                .where((e) => e.carBrandId == value?.carBrandId)
                                .toList();
                            controller.update();
                          });
                          controller.update();
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<CarModel>(
                        value: controller.selectedModel,
                        decoration: modernDropdownDecoration(
                          label: 'Model',
                          icon: Icons.category_rounded,
                        ),
                        items: controller.models
                            .where(
                              (m) =>
                                  m.carBrandId ==
                                  controller.selectedBrand?.carBrandId,
                            )
                            .map((model) {
                              return DropdownMenuItem<CarModel>(
                                value: model, // <-- هنا التعديل
                                child: Text(model.carModelName),
                              );
                            })
                            .toList(),
                        onChanged: controller.selectedBrand == null
                            ? null
                            : (value) {
                                setDState(() {
                                  controller.selectedModel = value;
                                  controller.update();
                                });
                              },
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<CarYearModel>(
                        value: controller.selectedYear,
                        decoration: modernDropdownDecoration(
                          label: 'Year',
                          icon: Icons.calendar_month_rounded,
                        ),
                        items: controller.years.map((year) {
                          return DropdownMenuItem<CarYearModel>(
                            value: year,
                            child: Text(year.carYearNumber),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDState(() {
                            controller.selectedYear = value;
                            controller.update();
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: modernField(
                            controller: controller.vinController,
                            label: "VIN Number",
                            icon: Icons.pin_outlined,
                            // ⬇️ هذا كان السبب: بدون هذا السطر، الزر ما يتفعّل
                            // إذا كتبت VIN بآخر شي بدون رجوع للحقول الثانية.
                            onChanged: () => setDState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: IconButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE0F7FA),
                              foregroundColor: const Color(0xFF155E75),
                              side: const BorderSide(
                                color: Color(0xFF99DDE7),
                                width: 1,
                              ),
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
                                setDState(() {});
                                return;
                              }

                              if (result is Map) {
                                controller.fillFromScannedCarData(
                                  Map<String, dynamic>.from(result),
                                );
                                setDState(() {});
                              }
                            },
                            icon: const Icon(Icons.qr_code_scanner_rounded),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          controller.selectedBrand = null;
                          controller.selectedModel = null;
                          controller.selectedYear = null;
                          controller.vinController.clear();
                          brandController.clear();
                          modelController.clear();
                          yearController.clear();
                          Get.back();
                        },
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
                        onPressed:
                            isSubmitting ||
                                controller.selectedBrand == null ||
                                controller.selectedModel == null ||
                                controller.selectedYear == null
                            ? null
                            : () async {
                                try {
                                  setDState(() => isSubmitting = true);

                                  final data = {
                                    "customerId": currentCase?.globalCustomerId,
                                    "orderId": currentCase?.globalOrderId,
                                    "brand":
                                        controller.selectedBrand!.carBrandName,
                                    "model":
                                        controller.selectedModel!.carModelName,
                                    "year":
                                        controller.selectedYear!.carYearNumber,
                                    "vinNumber":
                                        controller.vinController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : controller.vinController.text.trim(),
                                  };

                                  final success = await controller.addCarToCase(
                                    data,
                                  );

                                  if (success) {
                                    Get.back();
                                    controller.getCases();
                                    Get.back();
                                  }
                                } finally {
                                  if (Get.isDialogOpen ?? false) {
                                    setDState(() => isSubmitting = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isSubmitting
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Confirm',
                                  key: ValueKey('text'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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

// ═══════════════════════════════════════════════════════════════════════
// إضافة / تعديل خدمة على الطلب
// ═══════════════════════════════════════════════════════════════════════
void showAddServiceDialog(
  CaseController controller,
  GlobalOrderModel currentCase,
) {
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
                    const Icon(
                      Icons.build_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      controller.isEditService ? 'Edit Service' : 'Add Service',
                      style: const TextStyle(
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
                                  "serviceId":
                                      controller.selectedService?.serviceId,
                                  "globalOrderId":
                                      controller.currentCase?.globalOrderId,
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
                                  await controller.editDetail(data);
                                } else {
                                  await controller.addDetailToOrder(data);
                                }
                                Get.back();
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
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
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

Widget _field(
  TextEditingController controller,
  String label,
  bool required, {
  TextInputType keyboard = TextInputType.text,
  IconData icon = Icons.edit_outlined,
  VoidCallback? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      onChanged: (_) => onChanged?.call(),
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
      borderSide: const BorderSide(color: Color(0xFF0E7490), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
  VoidCallback? onChanged,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    onChanged: (_) => onChanged?.call(),
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

InputDecoration modernDropdownDecoration({
  required String label,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5),
    ),
  );
}
