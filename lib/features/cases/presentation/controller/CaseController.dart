import 'dart:io';
import 'package:apx_cars_repair/core/services/MultiOrderInvoices.dart';
import 'package:apx_cars_repair/core/services/ServiceItem.dart';
import 'package:apx_cars_repair/core/services/invoiceService.dart';
import 'package:apx_cars_repair/features/cases/data/models/CarsDataModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderDetailModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart'
    hide CarBrandModel;
import 'package:apx_cars_repair/features/cases/data/models/OrderStatusModel.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/BindImagesWithCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/addCar_to_order_usecase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/getCarInfo_usecase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/getOrderStatus_usecase.dart';
import 'package:intl/intl.dart';
import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/AddCascUseCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/EditCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/EditServiceToCaseUseCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/addCaseServiceNote.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/addServiceToCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/changeCaseServiceStatus.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/deleteCaseService_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/getAllService_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/show_cases_useCase.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class CaseController extends GetxController {
  CustomerController customerController = Get.find<CustomerController>();

  ShowCasesUsecase showCasesUsecase;
  GetorderstatusUsecase getorderstatusUsecase;
  AddCarToOrderUseCase addCarToOrderUseCase;
  ChangeCaseServiceStatus changeCaseServiceStatus;
  GetCarInfoUsecase getCarInfoUsecase;
  EditServiceToCaseUseCase editServiceToCaseUseCase;
  AddServiceToCaseUseCase addServiceToCaseUseCase;
  GetAllServiceUseCase getAllServiceUseCase;
  TimeOfDay visitTime = TimeOfDay.now();
  DeletecaseserviceUsecase deletecaseserviceUsecase;
  AddCaseUseCase addCaseUseCase;
  EditCaseUseCase editCaseUseCase;
  AddCaseServiceNote addCaseServiceNote;
  BindImagesWithCaseUseCase bindImagesWithCaseUseCase;
  List<GlobalOrderModel> cases = [];
  List<GlobalOrderModel> allCases = [];
  List<CustomerModel> customers = [];
  List<GlobalOrderModel> ordersToSendInvoice = [];
  List<CarBrandModel> brands = [];
  List<CarModel> models = [];
  List<CarModel> allModels = [];
  List<CarYearModel> years = [];
  CarBrandModel? selectedBrand;
  CarModel? selectedModel;
  CarYearModel? selectedYear;
  CustomerModel? selectedCustomer;
  bool isLoading = false;
  bool isUpdate = false;
  bool isEdit = false;
  GlobalOrderModel? currentCase;
  List<ServiceModel> Services = [];
  List<OrderStatusModel> OrderStatus = [];
  OrderStatusModel? selectedStatus;
  bool isEditService = false;
  int? currentOrderId;
  int? editingOrderDetailId;

  /// ================= FORM =================
  final formKey = GlobalKey<FormState>();

  /// ================= TEXT CONTROLLERS =================
  final customerIdController = TextEditingController();
  final vinNumberController = TextEditingController();

  final yearController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();

  ServiceModel? selectedService;
  int? selectedServiceId;
  bool? resolved;
  final notesController = TextEditingController();
  final costController = TextEditingController();
  final discountController = TextEditingController();
  final paidController = TextEditingController();
  var visitDate = DateTime.now();
  bool sendDateToApi = false;

  final List<File> images = [];

  // final List<CarBrandModel> carBrands;
  // final List<CarYear> carYears;
  // final CarBrandModel? selectedCarBrand;
  // final CarModel? selectedCarModel;
  // final CarYear? selectedCarYear;
  // final TextEditingController vinController;

  CaseController(
    this.showCasesUsecase,
    this.addCaseUseCase,
    this.editCaseUseCase,
    this.getorderstatusUsecase,
    this.bindImagesWithCaseUseCase,
    this.getAllServiceUseCase,
    this.addServiceToCaseUseCase,
    this.editServiceToCaseUseCase,
    this.addCaseServiceNote,
    this.changeCaseServiceStatus,
    this.deletecaseserviceUsecase,
    this.addCarToOrderUseCase,
    this.getCarInfoUsecase,
  );

  @override
  void onInit() async {
    super.onInit();

    Future.wait([
      getCases(),
      getAllServices(),
      getOrderStatus(),
      loadCustomers(),
      getAllCarsData(),
    ]);
  }

  Future<void> getAllServices() async {
    final result = await getAllServiceUseCase();

    result.fold((failure) => Get.snackbar("Error", failure.message), (data) {
      Services = data
          .where((s) => s.businessServices.first.businessId == 40)
          .toList();
      update();
    });
  }

  Future<void> loadCustomers() async {
    await customerController.getCustomers();
    customers = customerController.customers;
    update();
  }

  Future<void> getCases() async {
    isLoading = true;
    update();

    final result = await showCasesUsecase();

    result.fold(
      (failure) {
        Get.snackbar("Error", failure.message);
      },
      (data) {
        cases = data;
        allCases = data;
      },
    );

    isLoading = false;
    update();
  }

  Future<void> getOrderStatus() async {
    isLoading = true;
    update();

    final result = await getorderstatusUsecase();

    result.fold(
      (failure) {
        Get.snackbar("Error", failure.message);
      },
      (data) {
        OrderStatus = data;
      },
    );

    isLoading = false;
    update();
  }

  Future<void> getAllCarsData() async {
    var result = await getCarInfoUsecase();

    result.fold(
      (error) {
        // معالجة الخطأ
      },
      (data) {
        print("Brands Count = ${data.brands.length}");
        print("Models Count = ${data.models.length}");
        print("Years Count = ${data.years.length}");

        brands = data.brands;
        models = data.models;
        allModels = data.models;
        years = data.years;

        print("Controller Models Count = ${models.length}");

        update();
      },
    );
  }

  bool isImagesAdding = false;
  Future<void> takeMultiImages(int caseId) async {
    try {
      final picked = await _picker.pickMultiImage();
      if (picked.isEmpty) {
        Get.snackbar("Info", "No images selected");
        return;
      }
      isImagesAdding = true;
      update();
      final selectedImages = picked.map((e) => File(e.path)).toList();

      final result = await bindImagesWithCaseUseCase(caseId, selectedImages);

      result.fold((failure) => Get.snackbar("Error", failure.message), (
        success,
      ) async {
        Get.snackbar(
          "Success",
          "${selectedImages.length} images added successfully",
        );
        Get.back();
        currentCase!.orderImages = success;
        await getCases();
        isImagesAdding = false;
        update();
      });
    } catch (e) {
      isImagesAdding = false;
      update();
      Get.snackbar("Error", "Failed to pick images");
    }
  }

  Future<void> showImagePickerOptions(int orderId) async {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                takeMultiImages(orderId);
              },
            ),

            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                takeImageFromCamera(orderId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> takeImageFromCamera(int caseId) async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);

      if (picked == null) {
        Get.snackbar("Info", "No image selected");
        return;
      }

      isImagesAdding = true;
      update();

      final selectedImage = File(picked.path);

      final result = await bindImagesWithCaseUseCase(caseId, [selectedImage]);

      result.fold(
        (failure) {
          isImagesAdding = false;
          update();

          Get.snackbar("Error", failure.message);
          print(failure.message);
        },
        (_) async {
          Get.snackbar("Success", "Image added successfully");

          Get.back();
          Get.back();

          await getCases();

          isImagesAdding = false;
          update();
        },
      );
    } catch (e) {
      print(e);

      isImagesAdding = false;
      update();

      Get.snackbar("Error", "Failed to capture image");
    }
  }

  void fillFromScannedCarData(Map<String, dynamic> data) {
    final vin = _pickValue(data, const [
      'vin',
      'vinNumber',
      'vin_number',
      'chaseh',
      'chasehNumber',
      'chaseh_number',
      'chassis',
      'chassisNumber',
      'chassis_number',
    ]);

    final year = _pickValue(data, const ['year', 'manufactureYear']);
    final brand = _pickValue(data, const ['brand', 'make', 'manufacturer']);
    final model = _pickValue(data, const ['model', 'vehicleModel']);
    final scannedValue = _pickValue(data, const ['Vin']);

    // ===== Brand =====
    if (brand.isNotEmpty) {
      CarBrandModel? foundBrand;

      try {
        foundBrand = brands.firstWhere(
          (e) => e.carBrandName.toLowerCase() == brand.toLowerCase(),
        );
      } catch (_) {}

      if (foundBrand == null) {
        foundBrand = CarBrandModel(
          carBrandId: -(DateTime.now().millisecondsSinceEpoch),
          carBrandName: brand,
        );

        brands.add(foundBrand);
      }

      selectedBrand = foundBrand;
    }

    // ===== Model =====
    if (model.isNotEmpty && selectedBrand != null) {
      CarModel? foundModel;

      try {
        foundModel = allModels.firstWhere(
          (e) =>
              e.carModelName.toLowerCase() == model.toLowerCase() &&
              e.carBrandId == selectedBrand!.carBrandId,
        );
      } catch (_) {}

      if (foundModel == null) {
        foundModel = CarModel(
          carModelId: -(DateTime.now().millisecondsSinceEpoch),
          carBrandId: selectedBrand!.carBrandId,
          carModelName: model,
        );

        allModels.add(foundModel);
      }

      selectedModel = foundModel;
    }

    // تحديث موديلات البراند المختار
    if (selectedBrand != null) {
      models = allModels
          .where((e) => e.carBrandId == selectedBrand!.carBrandId)
          .toList();
    }

    // ===== Year =====
    CarYearModel? foundYear;

    try {
      foundYear = years.firstWhere((e) => e.carYearNumber == year);
    } catch (_) {}

    selectedYear =
        foundYear ??
        CarYearModel(
          carYearId: -(DateTime.now().millisecondsSinceEpoch),
          carYearNumber: year,
        );

    if (!years.any((e) => e.carYearNumber == year)) {
      years.add(selectedYear!);
    }

    // ===== VIN =====
    if (vin.isNotEmpty) {
      vinController.text = vin;
    }

    if (scannedValue.isNotEmpty) {
      vinNumberController.text = scannedValue;
    }

    update();
  }

  final vinController = TextEditingController();
  String _pickValue(Map<String, dynamic> source, List<String> keys) {
    final direct = _pickValueFromSingleMap(source, keys);
    if (direct.isNotEmpty) return direct;

    for (final value in source.values) {
      if (value is Map) {
        final nested = _pickValue(Map<String, dynamic>.from(value), keys);
        if (nested.isNotEmpty) return nested;
      }
    }

    return '';
  }

  String _pickValueFromSingleMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    final normalizedMap = <String, dynamic>{};

    source.forEach((key, value) {
      normalizedMap[_normalizeKey(key)] = value;
    });

    for (final key in keys) {
      final value = normalizedMap[_normalizeKey(key)];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  String _normalizeKey(String key) {
    return key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  /// ================= IMAGES =================
  final ImagePicker _picker = ImagePicker();

  /// ================= PICK IMAGES =================
  Future<void> pickImages() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);

      if (picked == null) return;

      images.add(File(picked.path));
      update();
    } catch (e) {
      Get.snackbar("Camera Error", "No camera available on this device");
    }
  }

  /// ================= REMOVE IMAGE =================
  void removeImage(File img) {
    images.remove(img);

    update();
  }

  bool isAddingCase = false;

  /// ================= SUBMIT CASE =================
  Future<void> submitCase() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final customerId = selectedCustomer?.globalCustomerId;

    if (customerId == null) {
      Get.snackbar("Error", "Please select customer");
      return;
    }

    isAddingCase = true;
    update();
    final data = {
      "globalCustomerId": selectedCustomer!.globalCustomerId,
      "business_id": 40,
      "notes": notesController.text.trim(),
      "OrderStatusId": selectedStatus?.orderStatusId,
      "schedule_time":
          "${visitTime.hour.toString().padLeft(2, '0')}:${visitTime.minute.toString().padLeft(2, '0')}",
      "schedule_dt": DateFormat('yyyy-MM-dd').format(visitDate),
      "service_id": selectedService?.serviceId,
    };

    final result = await addCaseUseCase(data);

    result.fold((failure) => Get.snackbar("Error", failure.message), (data) {
      Get.snackbar("Success", "Order added successfully");

      getCases();
      clearForm();

      Get.offNamed(AppRoutes.showCases);
    });
    isAddingCase = false;
    update();
  }

  Future<void> editCase() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final customerId = selectedCustomer?.globalCustomerId;

    if (customerId == null) {
      Get.snackbar("Error", "Please select customer");
      return;
    }

    isAddingCase = true;
    update();
    final data = {
      "globalCustomerId": selectedCustomer!.globalCustomerId,
      "business_id": 40,
      "notes": notesController.text.trim(),
      "OrderStatusId": selectedStatus?.orderStatusId,
      "service_id": selectedService?.serviceId,
      "schedule_time":
          "${visitTime.hour.toString().padLeft(2, '0')}:${visitTime.minute.toString().padLeft(2, '0')}",
      "schedule_dt": DateFormat('yyyy-MM-dd').format(visitDate),
    };

    final result = await editCaseUseCase(currentOrderId!, data);

    result.fold((failure) => Get.snackbar("Error", failure.message), (data) {
      Get.snackbar("Success", "Order updated successfully");

      getCases();
      clearForm();

      Get.offNamed(AppRoutes.showCases);
    });
    isAddingCase = false;
    update();
  }

  void clearForm() {
    customerIdController.clear();
    vinNumberController.clear();
    yearController.clear();
    brandController.clear();
    modelController.clear();
    images.clear();
    update();
  }

  bool isEditingCase = false;

  // Future<void> addDetailToOrder(Map<String, dynamic> data) async {
  //   update();

  //   try {
  //     final result = await addServiceToCaseUseCase(data);

  //     await result.fold(
  //       (failure) async {
  //         Get.snackbar("Error", failure.message);
  //         print(failure);
  //       },
  //       (data) async {
  //         Get.snackbar("Success", "Service edited successfully");
  //         await getCases();
  //         print(data);
  //       },
  //     );
  //   } finally {
  //     isEditingCaseService = false;
  //     update();
  //     Get.toNamed(AppRoutes.main);
  //   }
  // }

  Future<void> addDetailToOrder(Map<String, dynamic> data) async {
    isEditingCaseService = true;
    update();

    try {
      final result = await addServiceToCaseUseCase(data);

      await result.fold(
        (failure) async {
          Get.snackbar("Error", failure.message);
        },
        (data) async {
          Get.snackbar("Success", "Service edited successfully");

          // Reload cases from API
          await getCases();

          // Refresh current case from the newly loaded list
          if (currentCase != null) {
            final updatedCase = cases.firstWhereOrNull(
              (e) => e.globalOrderId == currentCase!.globalOrderId,
            );

            if (updatedCase != null) {
              currentCase = updatedCase;
            }
          }

          update();

          print("Service added successfully");
          print(data);
        },
      );
    } finally {
      isEditingCaseService = false;
      update();

      Get.offAllNamed(AppRoutes.main);
    }
  }

  int? editingServiceId;
  bool isEditingCaseService = false;
  TextEditingController serviceNoteController = TextEditingController();

  Future<bool> editDetail(Map<String, dynamic> data) async {
    if (editingServiceId == null) {
      Get.snackbar("Error", "No service selected for editing");
      return false;
    }

    isEditingCaseService = true;
    update();
    var isSuccess = false;

    try {
      final result = await editServiceToCaseUseCase(editingServiceId!, data);

      await result.fold(
        (failure) async {
          Get.snackbar("Error", failure.message);
        },
        (data) async {
          isSuccess = true;
          Get.snackbar("Success", "Service edited successfully");
          await getCases();
          isEditingCaseService = false;
          update();
          Get.toNamed(AppRoutes.main);
        },
      );
    } finally {}

    return isSuccess;
  }

  bool isDeletingCaseService = false;
  Future<bool> deleteCaseService(int serviceId) async {
    isDeletingCaseService = true;
    update();

    bool isSuccess = false;

    try {
      final result = await deletecaseserviceUsecase(serviceId);

      await result.fold(
        (failure) async {
          Get.snackbar("Error", failure.message);
        },
        (data) async {
          isSuccess = true;
          currentCase!.orderDetails!.removeWhere(
            (el) => el.globalOrderDetailId == serviceId,
          );

          Get.snackbar("Success", "Service deleted successfully");

          await getCases();
        },
      );
    } finally {
      isDeletingCaseService = false;
      update();
    }

    return isSuccess;
  }

  bool addingNoteToService = false;
  Future<void> addNoteToCaseService(
    int serviceId,
    Map<String, dynamic> data,
  ) async {
    addingNoteToService = true;
    update();
    final result = await addCaseServiceNote(serviceId, data);
    var detail = currentCase!.orderDetails!.firstWhere(
      (e) => e.globalOrderDetailId == serviceId,
    );
    detail.caseServiceNotes?.add(
      new CaseServiceNotesModel(
        caseServiceNotesId: DateTime.now().microsecond,
        notes: data['notes'][0],
        oredesServicesId: serviceId,
      ),
    );
    update();
    result.fold((failure) => Get.snackbar("Error", failure.message), (data) {
      getCases();
      addingNoteToService = false;

      update();
      Get.back();
      Get.snackbar("Success", "Note added successfully");
    });
    addingNoteToService = false;
    update();
  }

  Future<void> changeServiceStatus(int serviceId, bool resolved) async {
    isEditingCaseService = true;
    update();
    final data = {'resulved': resolved};

    final result = await changeCaseServiceStatus(serviceId, data);

    result.fold((failure) => Get.snackbar("Error", failure.message), (data) {
      Get.snackbar("Success", "Service status updated successfully");
      getCases();
    });
    isEditingCaseService = false;
    update();
  }

  @override
  void onClose() {
    customerIdController.dispose();
    vinNumberController.dispose();

    yearController.dispose();
    brandController.dispose();
    modelController.dispose();

    super.onClose();
  }

  bool addCarToOrder = false;

  Future<bool> addCarToCase(Map<String, dynamic> data) async {
    var isSuccess = false;
    addCarToOrder = true;
    update();
    var result = await addCarToOrderUseCase(data);
    result.fold(
      (error) {
        addCarToOrder = false;
        update();
      },
      (carInfo) {
        Get.offAndToNamed(AppRoutes.main);
        addCarToOrder = false;
        update();
        isSuccess = true;
      },
    );
    return isSuccess;
  }

  bool isSendingInvoice = false;
  Future<bool> sendReceiptEmail({
    required String toEmail,
    required String customerName,
    required String orderId,
    required GlobalOrderModel order,
  }) async {
    isSendingInvoice = true;
    update();

    try {
      // 1️⃣ جهّز بيانات الفاتورة من بيانات الطلب
      final invoiceData = ReciptData(
        invoiceNumber: orderId,
        date: DateFormat('MM/dd/yyyy').format(DateTime.now()),

        customerName: customerName,
        customerPhone: order.customer?.customerMobile ?? '',
        customerEmail: toEmail,
        customerAddress: '', // عدّل حسب اسم الحقل الفعلي عندك إن وُجد

        vehicleMakeModel:
            '${order.carInfo?.carBrand?.carBrandName ?? ''} ${order.carInfo?.carModel!.carModelName ?? ''}'
                .trim(),
        vehicleYear: order.carInfo?.carYear?.carYearNumber.toString() ?? '',
        vin: order.carInfo?.vinNumber ?? '',
        plate: '', // عدّل حسب اسم الحقل الفعلي عندك إن وُجد
        mileage: '', // عدّل حسب اسم الحقل الفعلي عندك إن وُجد

        services: (order.orderDetails ?? [])
            .map(
              (d) => ServiceItem(
                description: d.service?.description ?? '',
                qty: 1,
                rate: (d.cost ?? 0).toDouble(),
              ),
            )
            .toList(),

        technicianNotes: order.notes ?? '',
      );

      // 2️⃣ ولّد الـ PDF بالتصميم الجديد
      final pdfBytes = await generateInvoicePdf(invoiceData);

      // 3️⃣ جهّز الإيميل وأرسله (نفس منطقك الأصلي بدون تغيير)
      final smtpServer = gmail('alifouaad24@gmail.com', 'tdhhwaczycgqemmh');

      final message = Message()
        ..from = const Address('alifouaad24@gmail.com', 'The Giest')
        ..recipients.add(toEmail)
        ..subject = 'Invoice #$orderId'
        ..text = 'مرفق فاتورتك يا $customerName'
        ..attachments = [
          StreamAttachment(
            Stream.fromIterable([pdfBytes]),
            'application/pdf',
            fileName: 'invoice_$orderId.pdf',
          ),
        ];

      final sendReport = await send(message, smtpServer);
      print('تم الإرسال: $sendReport');
      return true;
    } on MailerException catch (e) {
      print('فشل الإرسال: $e');
      for (var p in e.problems) {
        print('المشكلة: ${p.code}: ${p.msg}');
      }
      return false;
    } finally {
      isSendingInvoice = false;
      update();
    }
  }

  bool isSendingRecipt = false;
  Future<bool> sendInvoiceEmail({
    required String toEmail,
    required String customerName,
    required String orderId,
    required GlobalOrderModel order,
  }) async {
    isSendingRecipt = true;
    update();

    try {
      // 1️⃣ جهّز بيانات الفاتورة من بيانات الطلب
      final invoiceData = InvoiceData(
        invoiceNumber: orderId,
        date: DateFormat('MM/dd/yyyy').format(DateTime.now()),

        customerName: customerName,
        customerPhone: order.customer?.customerMobile ?? '',
        customerEmail: toEmail,
        customerAddress: '', // عدّل حسب اسم الحقل الفعلي عندك إن وُجد

        vehicleMakeModel:
            '${order.carInfo?.carBrand?.carBrandName ?? ''} ${order.carInfo?.carModel!.carModelName ?? ''}'
                .trim(),
        vehicleYear: order.carInfo?.carYear?.carYearNumber.toString() ?? '',
        vin: order.carInfo?.vinNumber ?? '',
        plate: '', // عدّل حسب اسم الحقل الفعلي عندك إن وُجد
        mileage: '', // عدّل حسب اسم الحقل الفعلي عندك إن وُجد

        services: (order.orderDetails ?? [])
            .map(
              (d) => InvoiceItem(
                description: d.service?.description ?? '',
                qty: 1,
                rate: (d.cost ?? 0).toDouble(),
              ),
            )
            .toList(),

        technicianNotes: order.notes ?? '',
      );

      // 2️⃣ ولّد الـ PDF بالتصميم الجديد
      final pdfBytes = await generateInvoiceeePdf(invoiceData);

      // 3️⃣ جهّز الإيميل وأرسله (نفس منطقك الأصلي بدون تغيير)
      final smtpServer = gmail('alifouaad24@gmail.com', 'tdhhwaczycgqemmh');

      final message = Message()
        ..from = const Address('alifouaad24@gmail.com', 'The Giest')
        ..recipients.add(toEmail)
        ..subject = 'Invoice #$orderId'
        ..text = 'مرفق فاتورتك يا $customerName'
        ..attachments = [
          StreamAttachment(
            Stream.fromIterable([pdfBytes]),
            'application/pdf',
            fileName: 'invoice_$orderId.pdf',
          ),
        ];

      final sendReport = await send(message, smtpServer);
      print('تم الإرسال: $sendReport');
      return true;
    } on MailerException catch (e) {
      print('فشل الإرسال: $e');
      for (var p in e.problems) {
        print('المشكلة: ${p.code}: ${p.msg}');
      }
      return false;
    } finally {
      isSendingRecipt = false;
      update();
    }
  }

  Future<bool> sendMultiOrderInvoiceEmail() async {
    if (ordersToSendInvoice.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لم يتم اختيار أي طلب لإرسال الفاتورة',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    isSendingRecipt = true;
    update();

    try {
      // 1️⃣ كل الطلبات لنفس الزبون (متأكد أصلاً من toggleListOrders) -> نأخذ بيانات الزبون من أول طلب
      final firstOrder = ordersToSendInvoice.first;
      final customerName = firstOrder.customer?.customerName ?? '';
      final customerEmail = firstOrder.customer?.customerEmail ?? '';
      final customerPhone = firstOrder.customer?.customerMobile ?? '';

      // 2️⃣ حوّل كل طلب إلى صف بالجدول (VIN / QTY / AMOUNT)
      final orderRows = ordersToSendInvoice.map((order) {
        final details = order.orderDetails ?? [];
        final totalAmount = details.fold<double>(
          0,
          (sum, d) => sum + (d.cost ?? 0).toDouble(),
        );

        return InvoiceOrderRow(
          vin: order.carInfo?.vinNumber ?? '',
          qty: details.length,
          amount: totalAmount,
        );
      }).toList();

      // 3️⃣ احسب نطاق التاريخ (أقدم -> أحدث) اعتماداً على تاريخ كل طلب
      // عدّل "scheduleDt" لو عندك حقل تاريخ إنشاء مختلف (مثل createdAt)
      final orderDates =
          ordersToSendInvoice
              .map(
                (o) => o.scheduleDt != null
                    ? DateTime.tryParse(o.scheduleDt!)
                    : null,
              )
              .whereType<DateTime>()
              .toList()
            ..sort();

      final dateFormat = DateFormat('MM/dd/yyyy');
      final dateFrom = orderDates.isNotEmpty
          ? dateFormat.format(orderDates.first)
          : dateFormat.format(DateTime.now());
      final dateTo = orderDates.isNotEmpty
          ? dateFormat.format(orderDates.last)
          : dateFormat.format(DateTime.now());

      // 4️⃣ رقم فاتورة مؤقت (عدّله حسب نظام الترقيم عندك، مثلاً من السيرفر)
      final invoiceNumber = DateTime.now().millisecondsSinceEpoch.toString();

      // 5️⃣ ابنِ بيانات الفاتورة المجمّعة
      final invoiceData = MultiOrderInvoiceData(
        invoiceNumber: invoiceNumber,
        dateFrom: dateFrom,
        dateTo: dateTo,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        customerAddress: '', // عدّل حسب اسم الحقل الفعلي عندك إن وُجد
        orders: orderRows,
        technicianNotes: '',
      );

      // 6️⃣ ولّد الـ PDF
      final pdfBytes = await generateMultiOrderInvoicePdf(invoiceData);

      // 7️⃣ جهّز الإيميل وأرسله (نفس منطقك الأصلي)
      final smtpServer = gmail('alifouaad24@gmail.com', 'tdhhwaczycgqemmh');

      final message = Message()
        ..from = const Address('alifouaad24@gmail.com', 'The Giest')
        ..recipients.add(customerEmail)
        ..subject = 'Invoice #$invoiceNumber'
        ..text = 'مرفق فاتورتك يا $customerName'
        ..attachments = [
          StreamAttachment(
            Stream.fromIterable([pdfBytes]),
            'application/pdf',
            fileName: 'invoice_$invoiceNumber.pdf',
          ),
        ];

      final sendReport = await send(message, smtpServer);
      print('تم الإرسال: $sendReport');
      Get.snackbar(
        'نجاح',
        'تم ارسال الفاتورة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        backgroundColor: const Color.fromARGB(255, 86, 164, 1),
        colorText: Colors.white,
      );
      // 8️⃣ نظّف القائمة بعد نجاح الإرسال
      ordersToSendInvoice.clear();

      return true;
    } on MailerException catch (e) {
      print('فشل الإرسال: $e');
      for (var p in e.problems) {
        print('المشكلة: ${p.code}: ${p.msg}');
      }
      return false;
    } finally {
      isSendingRecipt = false;
      update();
    }
  }

  void toggleListOrders(GlobalOrderModel model) {
    final index = ordersToSendInvoice.indexWhere(
      (o) => o.globalOrderId == model.globalOrderId,
    );

    if (index != -1) {
      ordersToSendInvoice.removeAt(index);
      update();
      return;
    }

    if (ordersToSendInvoice.isNotEmpty) {
      final currentCustomerId =
          ordersToSendInvoice.first.customer?.globalCustomerId;
      final newCustomerId = model.customer?.globalCustomerId;

      if (currentCustomerId != newCustomerId) {
        Get.snackbar(
          'تنبيه',
          'لا يمكنك اختيار طلبات لأكثر من زبون واحد في نفس الفاتورة',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          backgroundColor: const Color.fromARGB(255, 220, 92, 13),
          colorText: Colors.white,
        );
        return;
      }
    }
    ordersToSendInvoice.add(model);
    update();
  }
}
