import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/CaseModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderDetailModel.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:apx_cars_repair/features/cases/presentation/pages/orderItemView.dart';
import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:apx_cars_repair/features/customers/presentation/widgets/voice_business_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Get.toNamed(AppRoutes.simpleOrdersView);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    controller.isUpdate = false;
                    controller.currentOrderId = null;
                    controller.selectedCustomer = null;
                    controller.notesController.clear();
                    controller.serviceNoteController.clear();
                    controller.ordersToSendInvoice.clear();
                    controller.selectedConsumer = null;
                    controller.selectedCustomerType = null;

                    Get.toNamed(AppRoutes.addEditCase);
                  },
                ),
              ],
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
            final groupedByAssignee = _groupCasesByAssignee(
              controller.unCompletedCases,
            );
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
                              totalCases: controller.unCompletedCases.length,
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
                          if (controller.ordersToSendInvoice.isNotEmpty)
                            controller.isSendingRecipt
                                ? Container(
                                    margin: const EdgeInsets.all(2),
                                    child: const CircularProgressIndicator(
                                      color: Color.fromARGB(255, 22, 21, 21),
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return Container(
                                            padding: const EdgeInsets.fromLTRB(
                                              20,
                                              12,
                                              20,
                                              30,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                    top: Radius.circular(28),
                                                  ),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Handle
                                                Container(
                                                  width: 45,
                                                  height: 5,
                                                  margin: const EdgeInsets.only(
                                                    bottom: 22,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),

                                                const Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Send Document',
                                                    style: TextStyle(
                                                      fontSize: 21,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Choose the document you want to send',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 20),

                                                // Invoice
                                                _documentOption(
                                                  context: context,
                                                  icon: Icons
                                                      .receipt_long_rounded,
                                                  title: 'Invoice',
                                                  subtitle:
                                                      'Send the invoice to the customer',
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    controller
                                                        .sendMultiOrderInvoiceEmail(
                                                          ccEmail:
                                                              'saifaldinsami@gmail.com',
                                                        );
                                                  },
                                                ),

                                                const SizedBox(height: 12),

                                                // Receipt
                                                _documentOption(
                                                  context: context,
                                                  icon:
                                                      Icons.description_rounded,
                                                  title: 'Receipt',
                                                  subtitle:
                                                      'Send the payment receipt',
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    controller
                                                        .sendMultiOrderReceiptEmail(
                                                          ccEmail:
                                                              'saifaldinsami@gmail.com',
                                                        );
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),

                          // if (controller.ordersToSendInvoice.length > 0)
                          //   controller.isSendingRecipt
                          //       ? Container(
                          //           margin: EdgeInsetsGeometry.all(2),
                          //           child: CircularProgressIndicator(
                          //             color: const Color.fromARGB(255, 22, 21, 21),
                          //           ),
                          //         )
                          //       :
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

  Widget _documentOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.blue, size: 27),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard({
    required int totalCases,
    required int totalTodayTasks,
    required bool isFiltered,
    required VoidCallback onAddPressed,
    required VoidCallback onResetPressed,
  }) {
    return Column(
      children: [
        // ---------------- Summary card ----------------
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, _secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.directions_car_filled_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Orders Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                    if (isFiltered) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: onResetPressed,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.close, size: 13, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Clear filter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildHeaderStat(value: totalCases, label: 'Open'),
              Container(
                width: 1,
                height: 34,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white24,
              ),
              _buildHeaderStat(value: totalTodayTasks, label: 'Today'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ---------------- Quick actions ----------------
        Row(
          children: [
            _buildActionTile(
              icon: Icons.receipt_long_rounded,
              label: 'All orders',
              color: _primary,
              onTap: () => Get.toNamed(AppRoutes.simpleOrdersView),
            ),
            const SizedBox(width: 10),
            _buildActionTile(
              icon: Icons.map_rounded,
              label: 'Today map',
              color: const Color(0xFF4F46E5),
              badge: totalTodayTasks,
              onTap: () {
                if (totalTodayTasks == 0) {
                  Get.snackbar('No tasks', 'You have no tasks for today.');
                  return;
                }

                final todayTasksList = _todayTasks();

                // حدّث الماركرز فوراً قبل الانتقال، بدل انتظار onInit
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
            const SizedBox(width: 10),
            _buildActionTile(
              icon: Icons.near_me_rounded,
              label: 'Nearest',
              color: const Color(0xFFEA580C),
              badge: totalTodayTasks,
              onTap: () {
                if (totalTodayTasks == 0) {
                  Get.snackbar('No tasks', 'You have no tasks for today.');
                  return;
                }
                _showNearestTodayTasksSheet(_todayTasks());
              },
            ),
            const SizedBox(width: 10),
            _buildActionTile(
              icon: Icons.mic_rounded,
              label: 'Voice',
              color: const Color(0xFFDB2777),
              onTap: () => showVoiceBusinessSearchDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderStat({required int value, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11.5),
        ),
      ],
    );
  }

  /// Square quick-action button: tinted icon, label, optional count badge.
  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int? badge,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 14, 6, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      if (badge != null && badge > 0)
                        Positioned(
                          top: -6,
                          right: -8,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Text(
                              '$badge',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Today's tasks (same filter used by "My today tasks").
  List<dynamic> _todayTasks() {
    final now = DateTime.now();
    return Get.find<CaseController>().cases.where((caseItem) {
      final date = DateTime.tryParse(caseItem.scheduleDt ?? '');
      return date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }

  String _formatDistance(double? meters) {
    if (meters == null) return 'Unknown distance';
    const metersPerMile = 1609.344;
    final miles = meters / metersPerMile;
    if (miles < 0.1) return '${(meters * 3.28084).round()} ft';
    return '${miles.toStringAsFixed(1)} mi';
  }

  /// Popup listing today's tasks sorted by distance from the device location.
  void _showNearestTodayTasksSheet(List<dynamic> todayTasks) {
    final customerController = Get.find<CustomerController>();
    final caseController = Get.find<CaseController>();
    final future = customerController.getTasksSortedByDistance(todayTasks);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me, color: _primary),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Today tasks — nearest first',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: _primary),
                                SizedBox(height: 12),
                                Text('Calculating distances...'),
                              ],
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                snapshot.error.toString().replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final items = snapshot.data ?? [];
                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final order = items[index]['task'];
                            final distance =
                                items[index]['distance'] as double?;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    0,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: distance == null
                                          ? Colors.grey.shade200
                                          : _primary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '#${index + 1}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: _secondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.place_outlined,
                                          size: 14,
                                          color: distance == null
                                              ? Colors.grey
                                              : _primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatDistance(distance),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: distance == null
                                                ? Colors.grey.shade700
                                                : _primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                OrderListItem(
                                  order: order,
                                  onTap: () {
                                    caseController.currentCase = order;
                                    Navigator.pop(sheetContext);
                                    Get.toNamed(AppRoutes.caseDetailView);
                                  },
                                ),
                              ],
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
        );
      },
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
