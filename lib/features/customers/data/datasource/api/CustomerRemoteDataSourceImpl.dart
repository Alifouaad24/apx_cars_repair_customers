import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/customers/data/datasource/api/CustomerRemoteDataSource.dart';
import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/SupplierModel.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final DioClient client;

  CustomerRemoteDataSourceImpl(this.client);

  @override
  Future<CustomerModel> addCustomer(Map<String, dynamic> customerData) async {
    final response = await client.dio.post("/customers", data: customerData);
    return CustomerModel.fromJson(response.data);
  }

  @override
  Future<List<CustomerModel>> showCustomers() async {
    final response = await client.dio.get(
      "/Customers/GetAllCustomersForApp/40",
    );
    return (response.data as List)
        .map((json) => CustomerModel.fromJson(json))
        .toList();
  }

  @override
  Future<CustomerModel> editCustomer(
    int customerId,
    Map<String, dynamic> customerData,
  ) async {
    final response = await client.dio.put(
      "/Customers/$customerId",
      data: customerData,
    );
    return CustomerModel.fromJson(response.data);
  }

  @override
  Future<CustomerModel> deleteCustomer(int customerId) async {
    final response = await client.dio.delete("/Customers/$customerId");
    return CustomerModel.fromJson(response.data);
  }

  @override
  Future<CustomerModel> bindCustomerWithImage(
    int customerId,
    XFile image,
  ) async {
    var formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(image.path, filename: image.name),
    });
    final response = await client.dio.put(
      "/Customers/BindImagesWithCustomer/$customerId",
      data: formData,
    );
    return CustomerModel.fromJson(response.data);
  }

  @override
  Future<List<SupplierFilterModel>> showConsumerBusiness() async {
    final response = await client.dio.get("/Supplier/GetConsumers/40");
    return (response.data as List)
        .map((el) => SupplierFilterModel.fromJson(el))
        .toList();
  }

  @override
  Future<SupplierFilterModel> addConsumerBusiness(
    Map<String, dynamic> data1,
  ) async {
    final response = await client.dio.post("/Supplier", data: data1);
    return SupplierFilterModel.fromJson(response.data);
  }

  @override
  Future<List<BusinessModel>> getAvailableBusinesses() async {
    final response = await client.dio.get(
      '/Business',
    ); // TODO: تأكد من الـ endpoint

    final businesses = (response.data as List)
        .map((e) => BusinessModel.fromJson(e))
        .toList();

    return _fillBusinessAddresses(businesses);
  }

  /// /Business only sends `address_id`s in businessAddresses, not the address
  /// itself. Looks those ids up in /Address and fills address / lat / lng.
  Future<List<BusinessModel>> _fillBusinessAddresses(
    List<BusinessModel> businesses,
  ) async {
    final needsLookup = businesses.any(
      (b) => b.address == null && b.latitude == null && b.addressIds.isNotEmpty,
    );
    if (!needsLookup) return businesses;

    final Map<int, Map> addressesById;
    try {
      final response = await client.dio.get('/Address');
      addressesById = {
        for (final a in (response.data as List).whereType<Map>())
          if (a['address_id'] is int) a['address_id'] as int: a,
      };
    } catch (_) {
      return businesses; // keep the list even if /Address fails
    }

    return businesses.map((b) {
      if (b.address != null || b.latitude != null) return b;
      for (final id in b.addressIds) {
        final a = addressesById[id];
        if (a == null) continue;
        final lat = double.tryParse('${a['latTute']}');
        final lng = double.tryParse('${a['lognTute']}');
        final text = BusinessModel.formatAddress(a);
        final hasCoords = lat != null && lng != null;
        if (hasCoords || text != null) {
          return b.copyWith(
            address: text,
            latitude: hasCoords ? lat : null,
            longitude: hasCoords ? lng : null,
          );
        }
      }
      return b;
    }).toList();
  }

  @override
  Future<List<ServiceModel>> getAvailableServices() async {
    final response = await client.dio.get(
      '/Service/40',
    ); // TODO: تأكد من الـ endpoint

    return (response.data as List)
        .map((e) => ServiceModel.fromJson(e))
        .toList();
  }

  @override
  Future<BusinessModel> addNewBusiness(Map<String, dynamic> data) async {
    final formData = FormData.fromMap(data);

    final response = await client.dio.post('/Business', data: formData);
    return BusinessModel.fromJson(response.data);
  }

  @override
  Future<void> bindBusinessWithNewAddress(Map<String, dynamic> data) async {
    await client.dio.post('/Business/BindBusinessWithNewAddress', data: data);
  }
}
