import 'dart:io';
import 'package:intl/intl.dart';
import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/AddCascUseCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/BindImagesWithCase_useCase.dart';
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
import 'package:dio/dio.dart';

class CaseController extends GetxController {
  CustomerController customerController = Get.find<CustomerController>();
  ShowCasesUsecase showCasesUsecase;
  ChangeCaseServiceStatus changeCaseServiceStatus;
  EditServiceToCaseUseCase editServiceToCaseUseCase;
  AddServiceToCaseUseCase addServiceToCaseUseCase;
  GetAllServiceUseCase getAllServiceUseCase;
  DeletecaseserviceUsecase deletecaseserviceUsecase;
  AddCaseUseCase addCaseUseCase;
  EditCaseUseCase editCaseUseCase;
  AddCaseServiceNote addCaseServiceNote;
  BindImagesWithCaseUseCase bindImagesWithCaseUseCase;
  List<CaseModel> cases = [];
  List<CaseModel> allCases = [];
  List<CustomerModel> customers = [];
  CustomerModel? selectedCustomer;
  bool isLoading = false;
  bool isEdit = false;
  CaseModel? currentCase;
  List<ServiceModel> Services = [];
  bool isEditService = false;

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

  List<File> images = [];
  CaseController(
    this.showCasesUsecase,
    this.addCaseUseCase,
    this.editCaseUseCase,
    this.bindImagesWithCaseUseCase,
    this.getAllServiceUseCase,
    this.addServiceToCaseUseCase,
    this.editServiceToCaseUseCase,
    this.addCaseServiceNote,
    this.changeCaseServiceStatus,
    this.deletecaseserviceUsecase,
  );

  @override
  void onInit() async {
    super.onInit();


    Future.wait([
          getCases(),
     getAllServices(),
     loadCustomers(),
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
        _,
      ) async {
        Get.snackbar(
          "Success",
          "${selectedImages.length} images added successfully",
        );
        Get.back();
        Get.back();
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

  Future<void> showImagePickerOptions(int caseId) async {
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
                takeMultiImages(caseId);
              },
            ),

            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                takeImageFromCamera(caseId);
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
    final scannedValue = _pickValue(data, const ['scannedValue']);

    if (vin.isNotEmpty) {
      vinNumberController.text = vin;
    }
    if (year.isNotEmpty) {
      yearController.text = year;
    }
    if (brand.isNotEmpty) {
      brandController.text = brand;
    }
    if (model.isNotEmpty) {
      modelController.text = model;
    }

    if (scannedValue.isNotEmpty) {
      vinNumberController.text = scannedValue;
    }

    update();
  }

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
      "customerId": selectedCustomer!.globalCustomerId,
      "vinNumber": vinNumberController.text.trim(),
      "year": yearController.text.trim(),
      "brand": brandController.text.trim(),
      "model": modelController.text.trim(),
      "visitDate": sendDateToApi
          ? DateFormat('yyyy-MM-dd').format(visitDate)
          : null,
    };

    final result = await addCaseUseCase(data);

    result.fold((failure) => Get.snackbar("Error", failure.message), (data) {
      Get.snackbar("Success", "Case added successfully");

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

  Future<void> addServiceToCase(Map<String, dynamic> data) async {
    if (selectedService?.serviceId == null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.defaultDialog(
          title: "Error",
          middleText: "Please select a service",
          textConfirm: "OK",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back();
          },
        );
      });

      update();
      return;
    }

    isEditingCase = true;
    update();

    final result = await addServiceToCaseUseCase(
      (data['caseId'] as num).toInt(),
      data,
    );

    result.fold(
      (failure) {
        Get.snackbar("Error", failure.message);
        isEditingCase = false;
        update();
      },

      (data) {
        final serviceToAdd = data.service != null || selectedService == null
            ? data
            : CaseService(
                caseServiceId: data.caseServiceId,
                caseId: data.caseId,
                serviceId: data.serviceId,
                resolved: data.resolved,
                notes: data.notes,
                cost: data.cost,
                discount: data.discount,
                paid: data.paid,
                service: ServiceModel1(
                  serviceId: selectedService!.serviceId,
                  description: selectedService!.description,
                  serviceIcon: selectedService!.serviceIcon,
                  serviceRoute: selectedService!.serviceRoute,
                ),
                caseServiceNotes: data.caseServiceNotes,
              );

        currentCase!.caseServices?.add(serviceToAdd);
        Get.snackbar("Success", "Service added to case successfully");

        getCases();
        isEditingCase = false;
        update();
        Get.toNamed(AppRoutes.main);
      },
    );
  }

  int? editingServiceId;
  bool isEditingCaseService = false;
  TextEditingController serviceNoteController = TextEditingController();

  Future<bool> editService(Map<String, dynamic> data) async {
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
        },
      );
    } finally {
      isEditingCaseService = false;
      update();
      Get.toNamed(AppRoutes.main);
    }

    return isSuccess;
  }

  bool isDeletingCaseService = false;
  Future<bool> deleteCaseService(int serviceId) async {
    isDeletingCaseService = true;
    update();
    var isSuccess = false;

    try {
      final result = await deletecaseserviceUsecase(serviceId);

      await result.fold(
        (failure) async {
          Get.snackbar("Error", failure.message);
        },
        (data) async {
          isSuccess = true;
          Get.snackbar("Success", "Service deleted successfully");
          currentCase?.caseServices?.removeWhere(
            (s) => s.caseServiceId == serviceId,
          );
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

    result.fold((failure) => Get.snackbar("Error", failure.message), (data) {
      Get.snackbar("Success", "Note added successfully");
      getCases();
      Get.back();
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
      final service = currentCase?.caseServices?.firstWhere(
        (e) => e.caseServiceId == serviceId,
      );

      if (service != null) {
        service.resolved = resolved;
      }
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
}
