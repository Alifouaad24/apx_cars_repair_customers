import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowCases extends StatefulWidget {
  const ShowCases({super.key});

  @override
  State<ShowCases> createState() => _ShowCasesState();
}

class _ShowCasesState extends State<ShowCases> {
  static const Color _primary = Color(0xFF0E7490);
  static const Color _secondary = Color(0xFF155E75);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cases Dashboard'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed(AppRoutes.addEditCase),
          ),
        ],
      ),
      body: GetBuilder<CaseController>(
        builder: (controller) {
          if (controller.isLoading) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF5FBFC), Color(0xFFEAF4F7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: _primary),
              ),
            );
          }

          final totalCustomers = controller.cases
              .map((caseItem) => caseItem.customer.globalCustomerId)
              .toSet()
              .length;
          final isFiltered =
              controller.cases.length != controller.allCases.length;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF8FCFD), Color(0xFFEAF5F8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: controller.cases.isEmpty
                    ? _buildEmptyState(controller, isFiltered)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(
                            totalCases: controller.cases.length,
                            totalCustomers: totalCustomers,
                            isFiltered: isFiltered,
                            onAddPressed: () =>
                                Get.toNamed(AppRoutes.addEditCase),
                            onResetPressed: () {
                              controller.cases = controller.allCases;
                              controller.update();
                            },
                          ),
                          const SizedBox(height: 16),
                          // _buildSearchCard(),
                          // const SizedBox(height: 16),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.only(bottom: 8),
                              children: _buildGroupedCases(controller.cases),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard({
    required int totalCases,
    required int totalCustomers,
    required bool isFiltered,
    required VoidCallback onAddPressed,
    required VoidCallback onResetPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primary, _secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.directions_car_filled_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cases Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMetricChip(
                icon: Icons.folder_open_outlined,
                label: 'Cases',
                value: totalCases.toString(),
              ),
              const SizedBox(width: 10),
              _buildMetricChip(
                icon: Icons.people_outline,
                label: 'Customers',
                value: totalCustomers.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {},
        decoration: InputDecoration(
          hintText: 'Search cases or customers...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: const Icon(Icons.search, color: _primary),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: Colors.grey.shade400),
            onPressed: () {},
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: _primary, width: 1.2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState(CaseController controller, bool isFiltered) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _primary.withOpacity(0.16),
                      _secondary.withOpacity(0.16),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'No Cases Yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isFiltered
                    ? 'No results match your current filter. Clear it to see all cases.'
                    : 'Start by adding your first case.\nEverything will appear here in a clean, organized view.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.addEditCase),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              if (isFiltered) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      controller.cases = controller.allCases;
                      controller.update();
                    },
                    icon: const Icon(Icons.list_alt_outlined),
                    label: const Text('Show All Cases'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primary,
                      side: const BorderSide(color: _primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedCases(List<CaseModel> cases) {
    final grouped = <int, List<CaseModel>>{};

    for (final caseItem in cases) {
      grouped
          .putIfAbsent(caseItem.customer.globalCustomerId, () => [])
          .add(caseItem);
    }

    final sortedCustomerIds = grouped.keys.toList()
      ..sort((a, b) {
        final aName = grouped[a]!.first.customer.customerName.toLowerCase();
        final bName = grouped[b]!.first.customer.customerName.toLowerCase();
        return aName.compareTo(bName);
      });

    return sortedCustomerIds
        .map((customerId) => _customerCasesSection(grouped[customerId]!))
        .toList();
  }

  Widget _customerCasesSection(List<CaseModel> customerCases) {
    final customer = customerCases.first.customer;
    final customerName = customer.customerName.trim();
    final customerInitial = _customerInitial(customerName);
    final totalImages = customerCases.fold<int>(
      0,
      (sum, caseItem) => sum + (caseItem.images?.length ?? 0),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primary, _secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    customerInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.isEmpty ? 'Unnamed Customer' : customerName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.customerMobile,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  '$totalImages Photos',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: _primary,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 6),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: customerCases.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final caseItem = customerCases[index];
                return _caseImageTile(caseItem);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCaseImagesDialog(CaseModel caseItem) {
    final controller = PageController();
    final title = _caseTitle(caseItem);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 560),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_primary, _secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Swipe through the images attached to this case.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: caseItem.images?.length ?? 0,
                    itemBuilder: (context, index) {
                      final image = caseItem.images![index];

                      return Padding(
                        padding: const EdgeInsets.all(14),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            color: Colors.grey.shade100,
                            child: Image.network(
                              image.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                     Expanded(
  child: GetBuilder<CaseController>(
    builder: (controller) {
      return ElevatedButton.icon(
        onPressed: () {
          controller.takeMultiImages(caseItem.id);
        },
        icon: const Icon(Icons.camera_alt_outlined),
        label: controller.isImagesAdding ? const Text('Adding...') : const Text('Add Images'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    },
  ),
),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _caseImageTile(CaseModel caseItem) {
    final firstImage = (caseItem.images != null && caseItem.images!.isNotEmpty)
        ? caseItem.images!.first.imageUrl
        : null;
    final title = _caseTitle(caseItem);

    return InkWell(
      onTap: () => _showCaseImagesDialog(caseItem),
      child: Container(
        width: 158,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (firstImage == null)
                Container(
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                    size: 34,
                  ),
                ),
              if (firstImage != null)
                Image.network(firstImage, fit: BoxFit.cover),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 18, 10, 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xCC0F172A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${caseItem.images?.length ?? 0} images',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _caseTitle(CaseModel caseItem) {
    final title = '${caseItem.carInfo.brand} ${caseItem.carInfo.model}'.trim();
    return title.isEmpty ? 'Case' : title;
  }

  String _customerInitial(String customerName) {
    final trimmed = customerName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}
