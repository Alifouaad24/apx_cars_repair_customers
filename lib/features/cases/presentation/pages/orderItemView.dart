import 'package:apx_cars_repair/app/routes/app_routes.dart';
import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/cases/presentation/controller/CaseController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

/// عنصر قائمة عصري لعرض طلب واحد (Order/Case).
/// استبدل النوع `dynamic order` بنوع الموديل الحقيقي عندك (مثلاً OrderModel).
class OrderListItem extends StatelessWidget {
  final GlobalOrderModel order;
  final VoidCallback? onTap;

  const OrderListItem({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outlineVariant.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: GetBuilder<CaseController>(
                    builder: (controller) => InkWell(
                      onLongPress: () {
                        Get.defaultDialog(
                          title: 'خيارات',
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  controller.isUpdate = true;
                                  controller.currentOrderId =  order.globalOrderId;
                                  controller.selectedCustomer = controller
                                      .customers
                                      .firstWhere(
                                        (c) =>
                                            c.globalCustomerId ==
                                            order.customer!.globalCustomerId,
                                      );
                                  controller.notesController.text = order.notes ?? '';
                                  controller.visitDate =
                                      order.scheduleDt != null
                                      ? DateTime.parse(order.scheduleDt!)
                                      : DateTime.now();
                                  controller.visitTime = TimeOfDay(
                                    hour: int.parse(
                                      order.scheduleTime.split(':')[0],
                                    ),
                                    minute: int.parse(
                                      order.scheduleTime.split(':')[1],
                                    ),
                                  );
                                  controller.selectedStatus = controller.OrderStatus.firstWhere(
                                        (c) =>
                                            c.orderStatusId ==
                                            order.status!.orderStatusId,
                                      );
                                  controller.selectedService = order.service != null ? controller.Services.firstWhere(
                                        (c) =>
                                            c.serviceId ==
                                            order.service?.serviceId,
                                      ) : null;
                                  Get.back();
                                  Get.toNamed(AppRoutes.addEditCase);
                                },
                                child: const Text('Edit'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Get.back();

                                  Get.defaultDialog(
                                    title: 'Delete confirmation',
                                    middleText: 'Are you sure to delete ?',
                                    textConfirm: 'Delete',
                                    textCancel: 'Cancel',
                                    onConfirm: () {

                            
                                    },
                                  );
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Icon(
                        Icons.build_circle_outlined,
                        color: colors.onPrimaryContainer,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // اسم الزبون + التاريخ والوقت
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.customer?.customerName ?? "بدون اسم",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${order.scheduleDt}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time_outlined,
                            size: 14,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${order.scheduleTime}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: colors.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
