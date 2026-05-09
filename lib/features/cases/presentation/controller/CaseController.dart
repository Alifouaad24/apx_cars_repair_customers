import 'dart:io';

import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/AddCascUseCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/BindImagesWithCase_useCase.dart';
import 'package:apx_cars_repair/features/cases/domain/usecases/EditCase_useCase.dart';
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
  AddCaseUseCase addCaseUseCase;
  EditCaseUseCase editCaseUseCase;
  BindImagesWithCaseUseCase bindImagesWithCaseUseCase;
  List<CaseModel> cases = [];
  List<CaseModel> allCases = [];
  List<CustomerModel> customers = [];
  CustomerModel? selectedCustomer;
  bool isLoading = false;
  bool isEdit = false;

  /// ================= FORM =================
  final formKey = GlobalKey<FormState>();

  /// ================= TEXT CONTROLLERS =================
  final customerIdController = TextEditingController();
  final vinNumberController = TextEditingController();

  final yearController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  List<File> images = [];
  CaseController(
    this.showCasesUsecase,
    this.addCaseUseCase,
    this.editCaseUseCase,
    this.bindImagesWithCaseUseCase,
  );

  @override
  void onInit() async {
    super.onInit();
    getCases();
    await loadCustomers();
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
