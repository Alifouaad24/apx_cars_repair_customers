import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/cases/presentation/pages/orderItemView.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
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
    return GetBuilder<CaseController>(
      init: Get.isRegistered<CaseController>()
          ? null
          : CaseController(
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
              Get.find(),
            ),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text('Orders Dashboard'),
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
            if (controller.ordersToSendInvoice.length == 0)
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

            final now = DateTime.now();
            final totalTodayTasks = controller.cases.where((caseItem) {
              final date = caseItem.scheduleDt.isNotEmpty == true
                  ? DateTime.tryParse(caseItem.scheduleDt!)
                  : null;
              return date?.year == now.year &&
                  date?.month == now.month &&
                  date?.day == now.day;
            }).length;

            final isFiltered =
                controller.cases.length != controller.allCases.length;

            // ================= group orders by assignee (من أُسند إليه الطلب) =================
            final groupedByAssignee = _groupCasesByAssignee(controller.cases);
            final assigneeIds = groupedByAssignee.keys.toList()
              ..sort((a, b) {
                final aName = _assigneeNameOf(
                  groupedByAssignee[a]!.first,
                ).toLowerCase();
                final bName = _assigneeNameOf(
                  groupedByAssignee[b]!.first,
                ).toLowerCase();
                return aName.compareTo(bName);
              });
            // ====================================================================================

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
                              totalTodayTasks: totalTodayTasks,
                              isFiltered: isFiltered,
                              onAddPressed: () {
                                controller.isUpdate = true;
                                controller.currentOrderId = null;
                                controller.selectedCustomer = null;
                                controller.notesController.clear();
                                controller.visitDate = DateTime.now();
                                controller.visitTime = TimeOfDay.now();
                                Get.toNamed(AppRoutes.addEditCase);
                              },
                              onResetPressed: () {
                                controller.cases = controller.allCases;
                                controller.update();
                              },
                            ),
                            const SizedBox(height: 16),
                            // _buildSearchCard(),
                            // const SizedBox(height: 16),

                            // ================= list grouped by assignee =================
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                itemCount: assigneeIds.length,
                                itemBuilder: (context, index) {
                                  final assigneeOrders =
                                      groupedByAssignee[assigneeIds[index]]!;
                                  return _assigneeSummaryCard(
                                    context: context,
                                    controller: controller,
                                    assigneeOrders: assigneeOrders,
                                  );
                                },
                              ),
                            ),
                            // ===============================================================
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ========================================================================
  // grouping helpers — بحسب من أُسند إليه الطلب (assignee)
  // ========================================================================

  /// Groups the orders list by assignee id (assigneeId).
  /// Returns a map of assigneeId -> list of that assignee's orders.
  Map<dynamic, List<dynamic>> _groupCasesByAssignee(List cases) {
    final grouped = <dynamic, List<dynamic>>{};
    for (final item in cases) {
      final assigneeId = item.assigneeId ?? 'unassigned';
      grouped.putIfAbsent(assigneeId, () => []).add(item);
    }
    return grouped;
  }

  String _assigneeNameOf(dynamic order) {
    final name = order.assigneeName?.toString().trim();
    return (name == null || name.isEmpty) ? 'Unassigned' : name;
  }

  /// نوع الجهة المُسنَد إليها الطلب (Business / Customer) لعرضه كـ badge.
  String _assigneeTypeLabelOf(dynamic order) {
    final typeLabel = order.assigneeType?.type?.toString().trim();
    if (typeLabel != null && typeLabel.isNotEmpty) return typeLabel;

    if (order.assigneeTypeId == 1) return 'Business';
    if (order.assigneeTypeId == 2) return 'Customer';
    return '';
  }

  /// One row per assignee, styled like the reference design:
  /// avatar + name + type badge on the left, order count on the top-right.
  /// Tapping opens a bottom sheet listing that assignee's orders.
  Widget _assigneeSummaryCard({
    required BuildContext context,
    required CaseController controller,
    required List<dynamic> assigneeOrders,
  }) {
    final firstOrder = assigneeOrders.first;
    final assigneeName = _assigneeNameOf(firstOrder);
    final assigneeTypeLabel = _assigneeTypeLabelOf(firstOrder);
    final ordersCount = assigneeOrders.length;

    return Container(
      height: 130,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            _showAssigneeOrdersSheet(context, controller, assigneeOrders),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // خلفية بلون موحّد + الحرف الأول من الاسم (لا يوجد صورة للمُسنَد إليه)
            Container(
              color: _primary,
              child: Center(
                child: Text(
                  _assigneeInitial(assigneeName),
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // Dark gradient so text stays readable
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xCC0F172A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                ),
              ),
            ),

            // Orders count badge (top-right)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$ordersCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Type badge (top-left) — Business / Customer
            if (assigneeTypeLabel.isNotEmpty)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    assigneeTypeLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

            // Name (bottom-left)
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    assigneeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens a bottom sheet listing all orders belonging to one assignee,
  /// reusing the same OrderListItem widget and tap behavior as before.
  void _showAssigneeOrdersSheet(
    BuildContext context,
    CaseController controller,
    List<dynamic> assigneeOrders,
  ) {
    final assigneeName = _assigneeNameOf(assigneeOrders.first);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        controller.ordersToSendInvoice = [];
        return GetBuilder<CaseController>(
          builder: (controller) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'طلبات $assigneeName',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),

                          if (controller.ordersToSendInvoice.length > 0)
                            controller.isSendingRecipt
                                ? Container(
                                    margin: EdgeInsetsGeometry.all(2),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {
                                      controller.sendMultiOrderInvoiceEmail();
                                    },
                                  ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: GetBuilder<CaseController>(
                        builder: (controller) {
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: assigneeOrders.length,
                            itemBuilder: (context, index) {
                              final order = assigneeOrders[index];
                              return OrderListItem(
                                order: order,
                                onLongPress: () {
                                  controller.toggleListOrders(order);
                                },
                                onTap: () {
                                  if (controller.ordersToSendInvoice.contains(
                                    order,
                                  )) {
                                    controller.toggleListOrders(order);
                                  } else if (controller
                                      .ordersToSendInvoice
                                      .isNotEmpty) {
                                    controller.toggleListOrders(order);
                                  } else {
                                    controller.currentCase = order;
                                    Navigator.pop(sheetContext);
                                    Get.toNamed(AppRoutes.caseDetailView);
                                  }
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ========================================================================
  // Existing widgets (unchanged below)
  // ========================================================================

  Widget _buildHeaderCard({
    required int totalCases,
    required int totalTodayTasks,
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
                      'Orders Overview',
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
                label: 'Orders',
                value: totalCases.toString(),
                onTab: () {},
              ),
              const SizedBox(width: 10),
              _buildMetricChip(
                icon: Icons.map_outlined,
                label: 'My today tasks',
                value: totalTodayTasks.toString(),
                onTab: () {
                  if (totalTodayTasks == 0) return;

                  final now = DateTime.now();
                  final todayTasksList = Get.find<CaseController>().cases.where(
                    (caseItem) {
                      final date = DateTime.tryParse(caseItem.scheduleDt ?? '');
                      return date != null &&
                          date.year == now.year &&
                          date.month == now.month &&
                          date.day == now.day;
                    },
                  ).toList();

                  // NEW: حدّث الماركرز فوراً قبل الانتقال، بدل انتظار onInit
                  final customerController = Get.find<CustomerController>();
                  customerController.todayTasks = todayTasksList;
                  customerController.loadTodayTaskMarkers();

                  Get.toNamed(
                    AppRoutes.map,
                    arguments: {
                      "todayTasks": todayTasksList,
                      "showTodayTasks": true,
                    },
                  );
                },
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
    required VoidCallback onTab,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTab,
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
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                'No Orders Yet',
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
                    ? 'No results match your current filter. Clear it to see all Orders.'
                    : 'Start by adding your first order.\nEverything will appear here in a clean, organized view.',
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
                  label: const Text('Add Order'),
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
                    label: const Text('Show All Orders'),
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

  String _assigneeInitial(String assigneeName) {
    final trimmed = assigneeName.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}
