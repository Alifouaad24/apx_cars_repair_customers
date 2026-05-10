import 'dart:convert';

import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/core/services/mapService.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/domain/entities/Customer.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/AddCustomerUseCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/EditCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/bindCustomerWithImage.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/deleteCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/show_customers_useCase.dart';
import 'package:apx_cars_repair/features/customers/presentation/pages/showCustomers_view.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' hide LatLng;
import 'package:url_launcher/url_launcher.dart';

class CustomerController extends GetxController {
  final AddCustomerUseCase addCustomerUseCase;
  final ShowCustomersUsecase showCustomersUsecase;
  final EditCustomerUseCase editCustomerUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;
  final BindCustomerWithImageUseCase bindCustomerWithImageUseCase;
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
    this.deleteCustomerUseCase,
    this.bindCustomerWithImageUseCase,
  );

  List<CustomerModel> customers = [];
  List<CustomerModel> allCustomers = [];
  var isLoading = false;

  @override
  void onInit() {
    super.onInit();
    getCustomers();
    getCurrentLocation();
  }

  pickCustomerImage({int? customerId, bool fromCamera = false}) async {
    var picked = await ImagePicker().pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (picked != null) {
      final result = await bindCustomerWithImageUseCase(customerId!, picked);

      result.fold(
        (failure) {
          Get.snackbar("Error", failure.message);
        },
        (_) {
          Get.snackbar("Success", "Image bound to customer successfully");
          getCustomers();
        },
      );
    } else {
      Get.snackbar("No Image", "No image was selected.");
    }
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

  Future<void> deleteCustomer(int customerId) async {
    isLoading = true;
    update();
    final result = await deleteCustomerUseCase(customerId);

    result.fold(
      (failure) {
        Get.snackbar("Error", failure.message);
      },
      (_) {
        Get.snackbar("Success", "Customer deleted successfully");
        getCustomers();
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

  //////////////////////////////
  ///
  ///
  AddressSearchService addressSearchService = AddressSearchService();
  LatLng currentLocation = const LatLng(40.7128, -74.0060);
  LatLng? selectedLocation;
  GoogleMapController? mapController;

  String latitude = "";
  String longitude = "";

  String line1 = "";
  String city = "";
  String state = "";
  String postalCode = "";
  String country = "";

  bool isLoadingMap = true;

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

  void moveCamera(LatLng pos) {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();

    currentLocation = LatLng(position.latitude, position.longitude);

    isLoadingMap = false;
    update();
  }

  Future<void> getAddress(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lng',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.apx.carsrepair'},
      );

      final data = jsonDecode(response.body);

      final address = data['address'];
      latitude = lat.toStringAsFixed(6);

      longitude = lng.toStringAsFixed(6);

      selectedLocation = LatLng(lat, lng);

      line1 = '${address['road'] ?? ''}';

      city = address['city'] ?? address['town'] ?? address['village'] ?? '';

      state = address['state'] ?? '';

      postalCode = address['postcode'] ?? '';

      country = address['country'] ?? '';
      line1Controller.text = line1;
      cityController.text = city;
      stateController.text = state;
      zipController.text = postalCode;

      update();
    } catch (e) {
      print(e);
    }
  }

  bool isSearchLoading = false;
  var results = <dynamic>[];
  TextEditingController addressSearchController = TextEditingController();

  Future<void> search(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      results.clear();
      update();
      return;
    }

    try {
      isSearchLoading = true;
      update();

      final data = await addressSearchService.searchAddress(normalizedQuery);

      results = List<dynamic>.from(data);
    } catch (e) {
      results.clear();
    } finally {
      isSearchLoading = false;
      update();
    }
  }
}
