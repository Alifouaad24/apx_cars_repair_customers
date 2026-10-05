import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة بسيطة لعرض الطلبات فقط:
/// - بحث بالاسم المُسنَد إليه (assigneeName) أو اسم السيارة
/// - ضغط مطوّل على الطلب => تأكيد تحويله إلى "مكتمل"
class OrdersSimpleView extends StatefulWidget {
  const OrdersSimpleView({super.key});

  @override
  State<OrdersSimpleView> createState() => _OrdersSimpleViewState();
}

class _OrdersSimpleViewState extends State<OrdersSimpleView> {
  static const Color _primary = Color(0xFF0E7490);
  static const Color _secondary = Color(0xFF155E75);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ======================= Helpers =======================

  String _assigneeNameOf(dynamic order) {
    final name = order.assigneeName?.toString().trim();
    return (name == null || name.isEmpty) ? 'Unassigned' : name;
  }

  /// ⚠️ عدّل هذا السطر حسب اسم الحقل الفعلي في OrderModel
  /// مثال: order.carName أو order.vehicle?.name أو order.car?.model
  String _carNameOf(dynamic order) {
    try {
      final name =
          '${order.carInfo.carYear.carYearNumber?.toString().trim() ?? ''} ${order.carInfo.carBrand.carBrandName?.toString().trim() ?? ''} '
                  '${order.carInfo.carModel.carModelName?.toString().trim() ?? ''}'
              .trim();
      return (name == null || name.isEmpty) ? '' : name;
    } catch (_) {
      return '';
    }
  }

  /// ⚠️ عدّل حسب طريقة تخزين الحالة في OrderModel
  String _statusOf(dynamic order) {
    try {
      return order.status?.statusEn.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  bool _isCompleted(dynamic order) =>
      _statusOf(order).toLowerCase() == 'completed';

  String _dateOf(dynamic order) {
    final raw = order.scheduleDt?.toString() ?? '';
    final date = DateTime.tryParse(raw);
    if (date == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}  '
        '${two(date.hour)}:${two(date.minute)}';
  }

  List<dynamic> _filter(List<dynamic> orders) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return orders;
    return orders.where((order) {
      final assignee = _assigneeNameOf(order).toLowerCase();
      final car = _carNameOf(order).toLowerCase();
      return assignee.contains(q) || car.contains(q);
    }).toList();
  }

  // ======================= Complete dialog =======================

  Future<void> _confirmComplete(
    CaseController controller,
    dynamic order,
  ) async {
    if (_isCompleted(order)) {
      Get.snackbar(
        'تنبيه',
        'هذا الطلب مكتمل بالفعل',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تأكيد'),
        content: Text(
          'هل تريد تحويل طلب "${_assigneeNameOf(order)}" إلى مكتمل؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، مكتمل'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // ⚠️ أضف هذه الدالة في CaseController (انظر الشرح)
      await controller.markOrderAsCompleted(order);
    }
  }

  // ======================= UI =======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [_primary, _secondary]),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF5FBFC),
      body: GetBuilder<CaseController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          final orders = _filter(List<dynamic>.from(controller.allCases));

          return Column(
            children: [
              // ---------- Search ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم الزبون أو اسم السيارة...',
                    prefixIcon: const Icon(Icons.search, color: _primary),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: _primary),
                    ),
                  ),
                ),
              ),

              // ---------- List ----------
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Text(
                          _query.isEmpty ? 'لا توجد طلبات' : 'لا توجد نتائج',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return _orderCard(controller, order);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _orderCard(CaseController controller, dynamic order) {
    final assignee = _assigneeNameOf(order);
    final car = _carNameOf(order);
    final date = _dateOf(order);
    final status = _statusOf(order);
    final completed = _isCompleted(order);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: () => _confirmComplete(controller, order),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _primary.withOpacity(0.12),
                child: Text(
                  assignee.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignee,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (car.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              car,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: const Color.fromARGB(255, 8, 8, 8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: completed
                        ? Colors.green.withOpacity(0.12)
                        : Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      color: completed ? Colors.green : Colors.orange.shade800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
