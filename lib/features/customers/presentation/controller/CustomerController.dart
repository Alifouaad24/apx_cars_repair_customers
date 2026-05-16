import 'dart:convert';
import 'dart:ui' as ui;

import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/core/services/mapService.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/AddCustomerUseCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/EditCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/bindCustomerWithImage.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/deleteCustomer_useCase.dart';
import 'package:apx_cars_repair/features/customers/domain/usecases/show_customers_useCase.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
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
  Set<Marker> markers = {};
  final Map<String, LatLng> _geocodeCache = {};
  final Map<String, BitmapDescriptor> _markerIconCache = {};

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

    await result.fold(
      (failure) {
        Get.snackbar("Error", failure.message);
      },
      (data) async {
        customers = data;
        allCustomers = data;

        markers.clear(); // مهم

        for (var c in customers) {
          try {
            final latLng = await _getLatLngFromAddress(c);

            if (latLng == null) continue;

            BitmapDescriptor markerIcon;
            try {
              markerIcon = await _getMarkerIconWithLabel(c.customerName);
            } catch (e) {
              print(
                'Marker icon build error for customer ${c.globalCustomerId}: $e',
              );
              markerIcon = BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              );
            }

            markers.add(
              Marker(
                markerId: MarkerId(c.globalCustomerId.toString()),
                position: latLng,
                icon: markerIcon,
                anchor: const Offset(0.5, 1.0),
                infoWindow: InfoWindow(
                  title: c.customerName,
                  snippet: c.address?.line1 ?? "",
                ),
              ),
            );

            if (markers.length % 5 == 0) update();
          } catch (e) {
            print(
              'Marker generation error for customer ${c.globalCustomerId}: $e',
            );
            continue;
          }
        }
      },
    );

    isLoading = false;
    update();
  }

  Future<LatLng?> _getLatLngFromAddress(CustomerModel c) async {
    final parts = <String>[
      c.address?.line1 ?? "",
      c.address?.line2 ?? "",
      c.address?.usCity ?? "",
      c.address?.postCode ?? "",
      "USA",
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (parts.length < 2) return null;

    final address = parts.join(', ');

    final cached = _geocodeCache[address];
    if (cached != null) return cached;

    try {
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final latLng = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        _geocodeCache[address] = latLng;
        return latLng;
      }
    } on PlatformException catch (e) {
      if (e.code != 'IO_ERROR') {
        print("Geocoding platform error: $e");
      }
    } catch (e) {
      print("Geocoding error: $e");
    }

    final fallback = await _geocodeWithNominatim(address);
    if (fallback != null) {
      _geocodeCache[address] = fallback;
      return fallback;
    }

    return null;
  }

  Future<LatLng?> _geocodeWithNominatim(String address) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': address,
        'format': 'jsonv2',
        'limit': '1',
      });

      final response = await http
          .get(uri, headers: {'User-Agent': 'com.apx.carsrepair'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) return null;

      final first = decoded.first;
      final lat = double.tryParse(first['lat']?.toString() ?? '');
      final lon = double.tryParse(first['lon']?.toString() ?? '');

      if (lat == null || lon == null) return null;

      return LatLng(lat, lon);
    } catch (e) {
      print('Nominatim geocoding error: $e');
      return null;
    }
  }

  Future<Set<Marker>> buildMarkers() async {
    Set<Marker> tempMarkers = {};

    for (var c in customers) {
      try {
        final latLng = await _getLatLngFromAddress(c);

        if (latLng == null) continue;

        BitmapDescriptor markerIcon;
        try {
          markerIcon = await _getMarkerIconWithLabel(c.customerName);
        } catch (_) {
          markerIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          );
        }

        tempMarkers.add(
          Marker(
            markerId: MarkerId(c.globalCustomerId.toString()),
            position: latLng,
            icon: markerIcon,
            anchor: const Offset(0.5, 1.0),
            infoWindow: InfoWindow(
              title: c.customerName,
              snippet: c.address?.line1 ?? "",
            ),
          ),
        );
      } catch (e) {
        print('buildMarkers error for customer ${c.globalCustomerId}: $e');
        continue;
      }
    }

    return tempMarkers;
  }

  Future<BitmapDescriptor> _getMarkerIconWithLabel(String customerName) async {
    final normalizedName = customerName.trim().isEmpty
        ? 'Customer'
        : customerName.trim();

    final cached = _markerIconCache[normalizedName];
    if (cached != null) return cached;

    final displayName = normalizedName.length > 22
        ? '${normalizedName.substring(0, 22)}...'
        : normalizedName;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const horizontalPadding = 22.0;
    const bubbleHeight = 64.0;
    const pointerHeight = 16.0;
    const pinRadius = 12.0;
    const cornerRadius = 16.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: 520);

    final bubbleWidth = textPainter.width + (horizontalPadding * 2);
    final totalHeight = bubbleHeight + pointerHeight + (pinRadius * 2);

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, bubbleWidth, bubbleHeight),
      const Radius.circular(cornerRadius),
    );

    final bubblePaint = Paint()..color = const Color(0xFF0E7490);
    canvas.drawRRect(bubbleRect, bubblePaint);

    final centerX = bubbleWidth / 2;
    final pointerPath = Path()
      ..moveTo(centerX - 12, bubbleHeight - 1)
      ..lineTo(centerX + 12, bubbleHeight - 1)
      ..lineTo(centerX, bubbleHeight + pointerHeight)
      ..close();
    canvas.drawPath(pointerPath, bubblePaint);

    final pinCenter = Offset(centerX, bubbleHeight + pointerHeight + pinRadius);
    final pinPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(pinCenter, pinRadius, pinPaint);

    textPainter.paint(
      canvas,
      Offset(
        (bubbleWidth - textPainter.width) / 2,
        (bubbleHeight - textPainter.height) / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
      bubbleWidth.ceil(),
      totalHeight.ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (bytes == null) {
      return BitmapDescriptor.defaultMarker;
    }

    final icon = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
    _markerIconCache[normalizedName] = icon;
    return icon;
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
  LatLng currentLocation = const LatLng(39.7684, -86.1581);
  LatLng? deviceLocation;
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
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        isLoadingMap = false;
        update();
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      deviceLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Location error: $e');
    } finally {
      isLoadingMap = false;
      update();
    }
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

      markers = {
        ...markers.where((m) => m.markerId.value != "selected"),
        Marker(
          markerId: const MarkerId("selected"),
          position: selectedLocation!,
        ),
      };

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
