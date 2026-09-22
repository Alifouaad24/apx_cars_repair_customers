import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowConsumerbusinessViw extends StatefulWidget {
  const ShowConsumerbusinessViw({super.key});

  @override
  State<ShowConsumerbusinessViw> createState() =>
      _ShowConsumerbusinessViwState();
}

class _ShowConsumerbusinessViwState extends State<ShowConsumerbusinessViw> {
  static const _primary = Color(0xFF0F2A47);
  static const _accent = Color(0xFFF5A524);
  static const _bg = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<CustomerController>();
      controller.getConsumerBusinesses();
      // Fetch the lists early so they're ready by the time the user opens the sheet
      controller.getAvailableBusinesses();
      controller.getAvailableServices();
    });
  }

  void _openAddConsumerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddConsumerBusinessSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: GetBuilder<CustomerController>(
                builder: (controller) {
                  if (controller.fetchingData) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primary),
                    );
                  }

                  if (controller.consumerBusinesses.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    color: _primary,
                    onRefresh: () async {
                      await controller.getConsumerBusinesses();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: controller.consumerBusinesses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = controller.consumerBusinesses[index];
                        final business = item.consumerBusiness;
                        final service = item.service;
                        return _BusinessCard(
                          name: business.name,
                          service: service.name,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(onPressed: (){Get.back();}, icon: Icon(Icons.arrow_back)),
          const Expanded(
            child: Text(
              'Consumer Businesses',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
          ),
          GestureDetector(
            onTap: _openAddConsumerSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_primary, Color(0xFF1B4B78)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_outlined,
              size: 48,
              color: _primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No linked businesses yet',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "Add" to link a new business',
            style: TextStyle(fontSize: 12.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final String name;
  final String service;

  const _BusinessCard({required this.name, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _ShowConsumerbusinessViwState._primary,
                        _ShowConsumerbusinessViwState._accent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                                       Text(
                        'Service : $service',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet for adding a new consumer business.
/// Contains a Business dropdown, a Service dropdown, and Confirm/Cancel buttons.
class _AddConsumerBusinessSheet extends StatefulWidget {
  const _AddConsumerBusinessSheet();

  @override
  State<_AddConsumerBusinessSheet> createState() =>
      _AddConsumerBusinessSheetState();
}

class _AddConsumerBusinessSheetState
    extends State<_AddConsumerBusinessSheet> {
  static const _primary = Color(0xFF0F2A47);

  int? _selectedBusinessId;
  int? _selectedServiceId;

  Future<void> _onConfirm(CustomerController controller) async {
    if (_selectedBusinessId == null || _selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a business and a service')),
      );
      return;
    }

    await controller.addConsumerBusiness(
      businessId: _selectedBusinessId,
      serviceId: _selectedServiceId,
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CustomerController>(
      builder: (controller) {
        final List<BusinessModel> businesses = controller.availableBusinesses;
        final List<ServiceModel> services = controller.availableServices;
        final submitting = controller.addingConsumerBusiness;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const Text(
                  'Add consumer business',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose the business and the related service',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                _buildLabel('Business'),
                const SizedBox(height: 6),
                _buildDropdownContainer(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedBusinessId,
                      hint: const Text('Select business'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: businesses.map((b) {
                        return DropdownMenuItem<int>(
                          value: b.businessId,
                          child: Text(
                            b.businessName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: businesses.isEmpty
                          ? null
                          : (value) {
                              setState(() => _selectedBusinessId = value);
                            },
                    ),
                  ),
                ),
                if (businesses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'No businesses available',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),

                _buildLabel('Service'),
                const SizedBox(height: 6),
                _buildDropdownContainer(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedServiceId,
                      hint: const Text('Select service'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: services.map((s) {
                        return DropdownMenuItem<int>(
                          value: s.serviceId, // TODO: confirm the actual field name in ServiceModel
                          child: Text(
                            s.description, // TODO: confirm the actual field name in ServiceModel
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: services.isEmpty
                          ? null
                          : (value) {
                              setState(() => _selectedServiceId = value);
                            },
                    ),
                  ),
                ),
                if (services.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'No services available',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 26),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: submitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            submitting ? null : () => _onConfirm(controller),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.4,
                                ),
                              )
                            : const Text(
                                'Ok',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}