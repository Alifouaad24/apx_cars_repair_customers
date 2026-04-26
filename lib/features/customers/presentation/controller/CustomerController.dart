import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/domain/entities/Customer.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/AddCustomerUseCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/EditCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/show_customers_useCase.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/showCustomers_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerController extends GetxController {
  final AddCustomerUseCase addCustomerUseCase;
  final ShowCustomersUsecase showCustomersUsecase;
  final EditCustomerUseCase editCustomerUseCase;
  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final businessController = TextEditingController();

  // USA Address
  final line1Controller = TextEditingController();
  final line2Controller = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();
  int? currentCustomerId;
  bool isEdit = false;

  CustomerController(
    this.addCustomerUseCase,
    this.showCustomersUsecase,
    this.editCustomerUseCase,
  );

  List<CustomerModel> customers = [];
  List<CustomerModel> allCustomers = [];
  var isLoading = false;

  @override
  void onInit() {
    super.onInit();
    getCustomers();
  }

  Future<void> getCustomers() async {
    isLoading = true;
    update();

    final result = await showCustomersUsecase();

    result.fold(
      (failure) {
        Get.snackbar("Error", failure.message);
      },
      (data) {
        customers = data;
        allCustomers = data;
      },
    );

    isLoading = false;
    update();
  }

  bool isSaveLoading = false;

  void filterCustomers(String query) {
    if (query.isEmpty) {
      customers = allCustomers;
    } else {
      customers = allCustomers.where((c) {
        return c.customerName.toLowerCase().contains(query.toLowerCase()) ||
            c.customerMobile.contains(query) ||
            c.customerEmail.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    update();
  }

  Future<void> addCustomer() async {
    isSaveLoading = true;
    update();
    Map<String, dynamic> customerData = {
      "customerName": firstNameController.text + " " + lastNameController.text,
      "customerMobile": phoneController.text,
      "customerEmail": emailController.text,
      "country_id": 3,
      "businessId": 40,
      "address": {
        "line_1": line1Controller.text,
        "line_2": line2Controller.text,
        "stateId": 1,
        "us_City": cityController.text,
        "post_code": zipController.text,
        "countryId": 3,
        "landMark": "",
        "cityId": null,
        "areaId": null,
      },
    };

    final result = await addCustomerUseCase(customerData);

    result.fold(
      (failure) {
        Get.snackbar("Error", failure.message);
      },
      (_) {
        Get.snackbar("Success", "Customer added successfully");
        getCustomers();
        Get.toNamed(AppRoutes.home);
      },
    );

    isSaveLoading = false;
    update();
  }

  Future<void> editCustomer(int customerId) async {
    isSaveLoading = true;
    update();

    Map<String, dynamic> customerData = {
      "customerName": firstNameController.text + " " + lastNameController.text,
      "customerMobile": phoneController.text,
      "customerEmail": emailController.text,
      "country_id": 3,
      "businessId": 40,
      "address": {
        "line_1": line1Controller.text,
        "line_2": line2Controller.text,
        "stateId": 1,
        "us_City": cityController.text,
        "post_code": zipController.text,
        "countryId": 3,
        "landMark": "",
        "cityId": null,
        "areaId": null,
      },
    };

    final result = await editCustomerUseCase(customerId, customerData);

    result.fold(
      (failure) {
        Get.snackbar("Error", failure.message);
      },
      (_) {
        Get.snackbar("Success", "Customer edited successfully");
        getCustomers();
        Get.toNamed(AppRoutes.home);
      },
    );

    isSaveLoading = false;
    update();
  }

  Future<void> openInMaps() async {
    final address =
        "${line1Controller.text}, ${line2Controller.text}, ${cityController.text}, ${stateController.text}, ${zipController.text}";

    final url =
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}";

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", "Cannot open maps");
    }
  }
}
