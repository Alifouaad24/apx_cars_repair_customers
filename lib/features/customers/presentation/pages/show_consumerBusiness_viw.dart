import 'dart:async';

import 'package:apx_cars_repair/core/services/mapService.dart';
import 'package:apx_cars_repair/features/cases/data/models/ServiceModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/BusinessModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/SupplierModel.dart';
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
      builder: (_) =>
          _AddConsumerBusinessSheet(onAddNewBusiness: _openAddBusinessDialog),
    );
  }

  void _openDetailsSheet(SupplierFilterModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BusinessDetailsSheet(
        item: item,
        onAddAddress: () => _openAddAddressDialog(item),
      ),
    );
  }

  Future<void> _openAddAddressDialog(SupplierFilterModel item) async {
    final controller = Get.find<CustomerController>();
    final business = item.consumerBusiness;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddAddressDialog(
        businessName: business.name,
        searchService: controller.addressSearchService,
        onSubmit: (line1, line2, postCode, city) =>
            controller.bindBusinessWithNewAddress(
              businessId: business.id,
              line1: line1,
              line2: line2,
              postCode: postCode,
              usCity: city,
            ),
      ),
    );
  }

  Future<void> _openAddBusinessDialog() async {
    final controller = Get.find<CustomerController>();

    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddBusinessDialog(
        onSubmit: (name, email, phone) =>
            controller.addBusiness(name: name, email: email, phone: phone),
      ),
    );

    if (added == true && mounted) {
      await controller.getAvailableBusinesses(); // تحديث القائمة
      _openAddConsumerSheet(); // إعادة فتح الشيت
    }
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
                          onTap: () => _openDetailsSheet(item),
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
          IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back),
          ),
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
                  Icon(Icons.link, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Link',
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
  final VoidCallback? onTap;

  const _BusinessCard({required this.name, required this.service, this.onTap});

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
          onTap: onTap,
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
                    maxLines: 2,
                    softWrap: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
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
                        'Service : ${service?.trim().isNotEmpty == true ? service : 'All'}',
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

/// Bottom sheet showing the details of a linked consumer business.
class _BusinessDetailsSheet extends StatelessWidget {
  final SupplierFilterModel item;
  final VoidCallback onAddAddress;

  const _BusinessDetailsSheet({required this.item, required this.onAddAddress});

  static const _primary = Color(0xFF0F2A47);
  static const _accent = Color(0xFFF5A524);

  String _orDash(String value) => value.trim().isEmpty ? '-' : value;

  @override
  Widget build(BuildContext context) {
    final consumer = item.consumerBusiness;
    final provider = item.providerBusiness;
    final serviceName = item.service.name.trim().isNotEmpty
        ? item.service.name
        : 'All';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
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
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_primary, _accent]),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  consumer.name.isNotEmpty
                      ? consumer.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _orDash(consumer.name),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Consumer business',
                      style: TextStyle(fontSize: 12.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetailTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _orDash(consumer.email),
          ),
          if (consumer.phone.trim().isNotEmpty)
            _DetailTile(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: consumer.phone,
            ),
          if (consumer.address.trim().isNotEmpty)
            _DetailTile(
              icon: Icons.location_on_outlined,
              label: 'Address',
              value: consumer.address,
            )
          else
            _DetailTile(
              icon: Icons.location_off_outlined,
              label: 'Address',
              value: 'No address',
              trailing: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // close the details sheet
                  onAddAddress();
                },
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(foregroundColor: _primary),
              ),
            ),
          _DetailTile(
            icon: Icons.miscellaneous_services_outlined,
            label: 'Service',
            value: serviceName,
          ),
          _DetailTile(
            icon: Icons.storefront_outlined,
            label: 'Provider business',
            value: _orDash(provider.name),
          ),
          if (provider.email.trim().isNotEmpty)
            _DetailTile(
              icon: Icons.alternate_email,
              label: 'Provider email',
              value: provider.email,
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Bottom sheet for adding a new consumer business.
class _AddConsumerBusinessSheet extends StatefulWidget {
  final VoidCallback onAddNewBusiness;

  const _AddConsumerBusinessSheet({required this.onAddNewBusiness});

  @override
  State<_AddConsumerBusinessSheet> createState() =>
      _AddConsumerBusinessSheetState();
}

class _AddConsumerBusinessSheetState extends State<_AddConsumerBusinessSheet> {
  static const _primary = Color(0xFF0F2A47);

  int? _selectedBusinessId;
  int? _selectedServiceId;

  Future<void> _onConfirm(CustomerController controller) async {
    if (_selectedBusinessId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a business')));
      return;
    }

    await controller.addConsumerBusiness(
      businessId: _selectedBusinessId,
      serviceId: _selectedServiceId,
    );
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
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownContainer(
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
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Add new business',
                      onPressed: () {
                        Navigator.of(context).pop(); // يسكّر الشيت
                        widget.onAddNewBusiness(); // يفتح البوبب من الصفحة
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ],
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
                          value: s
                              .serviceId, // TODO: confirm the actual field name in ServiceModel
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
                        onPressed: submitting
                            ? null
                            : () => _onConfirm(controller),
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

/// Dialog for creating a new business: name, email, phone.
class _AddBusinessDialog extends StatefulWidget {
  final Future<bool> Function(String name, String email, String phone) onSubmit;

  const _AddBusinessDialog({required this.onSubmit});

  @override
  State<_AddBusinessDialog> createState() => _AddBusinessDialogState();
}

class _AddBusinessDialogState extends State<_AddBusinessDialog> {
  static const _primary = Color(0xFF0F2A47);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitted = true);
  if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final success = await widget.onSubmit(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add business, please try again'),
        ),
      );
    }
  }

  InputDecoration _decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  bool _submitted = false;

  // بعد أول محاولة حفظ: الكتابة في أحد الحقلين تزيل الخطأ من الآخر فورًا
  void _revalidateContact() {
    if (_submitted) _formKey.currentState?.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add new business',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Enter the business details',
                style: TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _label('Name'),
TextFormField(
  controller: _nameController,
  textInputAction: TextInputAction.next,
  decoration: _decoration('Business name', Icons.business_outlined),
  validator: (v) =>
      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
),
const SizedBox(height: 14),

_label('Email'),
TextFormField(
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  decoration: _decoration('example@mail.com', Icons.email_outlined),
  onChanged: (_) => _revalidateContact(),
  validator: (v) {
    final email = v?.trim() ?? '';
    final phone = _phoneController.text.trim();
    if (email.isEmpty && phone.isEmpty) return 'Enter email or phone';
    if (email.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Invalid email';
    }
    return null;
  },
),
const SizedBox(height: 14),

_label('Phone number'),
TextFormField(
  controller: _phoneController,
  keyboardType: TextInputType.phone,
  textInputAction: TextInputAction.done,
  onFieldSubmitted: (_) => _save(),
  decoration: _decoration('07xxxxxxxxx', Icons.phone_outlined),
  onChanged: (_) => _revalidateContact(),
  validator: (v) {
    final phone = (v ?? '').replaceAll(' ', '').trim();
    final email = _emailController.text.trim();
    if (phone.isEmpty && email.isEmpty) return 'Enter phone or email';
    if (phone.isNotEmpty && !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone)) {
      return 'Invalid phone number';
    }
    return null;
  },
),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
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
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text(
                              'Save',
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
      ),
    );
  }
}

/// Dialog for linking a new address to a business.
/// Typing in Line 1 searches Google Places; picking a suggestion
/// fills Line 1, Line 2, Post code and City.
class _AddAddressDialog extends StatefulWidget {
  final String businessName;
  final AddressSearchService searchService;
  final Future<bool> Function(
    String line1,
    String line2,
    String postCode,
    String city,
  )
  onSubmit;

  const _AddAddressDialog({
    required this.businessName,
    required this.searchService,
    required this.onSubmit,
  });

  @override
  State<_AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<_AddAddressDialog> {
  static const _primary = Color(0xFF0F2A47);

  final _formKey = GlobalKey<FormState>();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _postCodeController = TextEditingController();
  final _cityController = TextEditingController();

  Timer? _debounce;
  int _searchSeq = 0; // used to ignore out-of-order search responses
  List<dynamic> _suggestions = [];
  bool _searching = false;
  bool _loadingDetails = false;
  bool _saving = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _postCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onLine1Changed(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      _searchSeq++;
      setState(() {
        _suggestions = [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    final seq = ++_searchSeq;
    setState(() => _searching = true);
    try {
      final data = await widget.searchService.searchAddress(query);
      if (!mounted || seq != _searchSeq) return;
      setState(() => _suggestions = List<dynamic>.from(data));
    } catch (_) {
      if (!mounted || seq != _searchSeq) return;
      setState(() => _suggestions = []);
    } finally {
      if (mounted && seq == _searchSeq) setState(() => _searching = false);
    }
  }

  Future<void> _selectSuggestion(dynamic item) async {
    final placeId = item['place_id']?.toString();
    if (placeId == null) return;

    _debounce?.cancel();
    _searchSeq++; // drop any in-flight search
    FocusScope.of(context).unfocus();
    setState(() {
      _suggestions = [];
      _searching = false;
      _loadingDetails = true;
    });

    try {
      final details = await widget.searchService.getPlaceDetails(placeId);
      if (!mounted) return;
      _line1Controller.text = details['line1']?.toString() ?? '';
      _line2Controller.text = details['line2']?.toString() ?? '';
      _postCodeController.text = details['postalCode']?.toString() ?? '';
      _cityController.text = details['city']?.toString() ?? '';
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load address details')),
      );
    } finally {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final success = await widget.onSubmit(
      _line1Controller.text.trim(),
      _line2Controller.text.trim(),
      _postCodeController.text.trim(),
      _cityController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (success) Navigator.of(context).pop(true);
  }

  InputDecoration _decoration(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
  );

  Widget? _line1Suffix() {
    if (!_searching && !_loadingDetails) return null;
    return const Padding(
      padding: EdgeInsets.all(14),
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: _primary),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, index) {
          final item = _suggestions[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.location_on_outlined,
              size: 20,
              color: Colors.grey.shade600,
            ),
            title: Text(
              item['description']?.toString() ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13),
            ),
            onTap: () => _selectSuggestion(item),
          );
        },
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    TextInputAction action = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: action,
          onFieldSubmitted: onSubmitted,
          decoration: _decoration(hint, icon),
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
              : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.businessName.trim().isEmpty
                    ? 'Search for the address or enter it manually'
                    : 'Address for ${widget.businessName}',
                style: const TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              _label('Line 1'),
              TextFormField(
                controller: _line1Controller,
                textInputAction: TextInputAction.next,
                onChanged: _onLine1Changed,
                decoration: _decoration(
                  'Start typing, e.g. 12554 ...',
                  Icons.search,
                  suffix: _line1Suffix(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Line 1 is required'
                    : null,
              ),
              if (_suggestions.isNotEmpty) _buildSuggestions(),
              const SizedBox(height: 14),

              _field(
                label: 'Line 2',
                controller: _line2Controller,
                hint: 'City, State, Country',
                icon: Icons.home_work_outlined,
              ),
              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _field(
                      label: 'City',
                      controller: _cityController,
                      hint: 'City',
                      icon: Icons.location_city_outlined,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      label: 'Post code',
                      controller: _postCodeController,
                      hint: 'ZIP',
                      icon: Icons.markunread_mailbox_outlined,
                      required: true,
                      keyboardType: TextInputType.number,
                      action: TextInputAction.done,
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
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
                      onPressed: (_saving || _loadingDetails) ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Text(
                              'Save',
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
      ),
    );
  }
}
