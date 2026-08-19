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
  final VoidCallback? onLongPress;
  const OrderListItem({
    super.key,
    required this.order,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final CarInfoModel? carInfo = order.carInfo;
    final bool hasCar = carInfo != null;
    final String? brandImgUrl = carInfo?.carBrand?.carBrandImgUrl;

    return GetBuilder<CaseController>(
      builder: (controller) {
        final isSelected = controller.ordersToSendInvoice.any(
          (o) => o.globalOrderId == order.globalOrderId,
        );
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
          child: Material(
            color: isSelected
                ? Colors.red.withOpacity(0.35)
                : colors.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              onLongPress: onLongPress,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colors.outlineVariant.withOpacity(0.4),
                  ),
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
                      clipBehavior: Clip.antiAlias,
                      child: GetBuilder<CaseController>(
                        builder: (controller) => InkWell(
                          onLongPress: () {
                            Get.defaultDialog(
                              title: '',
                              titlePadding: EdgeInsets.zero,
                              contentPadding: const EdgeInsets.fromLTRB(
                                20,
                                0,
                                20,
                                20,
                              ),
                              backgroundColor: Colors.white,
                              radius: 20,
                              barrierDismissible: true,
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: Get.height * 0.75,
                                  ),
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Header
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.only(
                                            bottom: 18,
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 55,
                                                height: 55,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(.10),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.more_horiz_rounded,
                                                  color: Colors.blue,
                                                  size: 30,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              const Text(
                                                'خيارات الطلب',
                                                style: TextStyle(
                                                  fontSize: 21,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                'اختر العملية التي تريد تنفيذها',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const Divider(height: 1),

                                        const SizedBox(height: 15),

                                        // Edit
                                        _buildOrderAction(
                                          icon: Icons.edit_rounded,
                                          title: 'تعديل الطلب',
                                          subtitle:
                                              'تعديل بيانات الطلب والعميل',
                                          iconColor: Colors.blue,
                                          backgroundColor: Colors.blue
                                              .withOpacity(.10),
                                          onTap: () {
                                            controller.isUpdate = true;

                                            controller.currentOrderId =
                                                order.globalOrderId;

                                            controller.selectedCustomer =
                                                controller.customers.firstWhere(
                                                  (c) =>
                                                      c.globalCustomerId ==
                                                      order
                                                          .customer!
                                                          .globalCustomerId,
                                                );

                                            controller.notesController.text =
                                                order.notes ?? '';

                                            controller.visitDate =
                                                order.scheduleDt.isNotEmpty
                                                ? DateTime.parse(
                                                    order.scheduleDt,
                                                  )
                                                : null;

                                            controller.visitTime = order.scheduleTime.isNotEmpty ? TimeOfDay(
                                              hour: int.parse(
                                                order.scheduleTime.split(
                                                  ':',
                                                )[0],
                                              ),
                                              minute: int.parse(
                                                order.scheduleTime.split(
                                                  ':',
                                                )[1],
                                              ),
                                            ) : null;

                                            controller.selectedStatus =
                                                controller
                                                    .OrderStatus.firstWhere(
                                                  (c) =>
                                                      c.orderStatusId ==
                                                      order
                                                          .status!
                                                          .orderStatusId,
                                                );

                                            controller.selectedService =
                                                order.service != null
                                                ? controller
                                                      .Services.firstWhere(
                                                    (c) =>
                                                        c.serviceId ==
                                                        order
                                                            .service
                                                            ?.serviceId,
                                                  )
                                                : null;

                                            Get.back();
                                            Get.toNamed(AppRoutes.addEditCase);
                                          },
                                        ),

                                        const SizedBox(height: 10),

                                        // Delete
                                        _buildOrderAction(
                                          icon: Icons.delete_outline_rounded,
                                          title: 'حذف الطلب',
                                          subtitle: 'حذف الطلب نهائياً',
                                          iconColor: Colors.red,
                                          backgroundColor: Colors.red
                                              .withOpacity(.10),
                                          onTap: () {
                                            Get.back();

                                            Get.defaultDialog(
                                              title: '',
                                              titlePadding: EdgeInsets.zero,
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                    24,
                                                    0,
                                                    24,
                                                    20,
                                                  ),
                                              radius: 20,
                                              backgroundColor: Colors.white,
                                              content: Column(
                                                children: [
                                                  Container(
                                                    width: 65,
                                                    height: 65,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(.10),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .delete_forever_rounded,
                                                      color: Colors.red,
                                                      size: 34,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 15),

                                                  const Text(
                                                    'تأكيد الحذف',
                                                    style: TextStyle(
                                                      fontSize: 21,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 8),

                                                  Text(
                                                    'هل أنت متأكد من حذف هذا الطلب؟\nلا يمكن التراجع عن هذه العملية.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      height: 1.5,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 22),

                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: OutlinedButton(
                                                          onPressed: () =>
                                                              Get.back(),
                                                          style: OutlinedButton.styleFrom(
                                                            minimumSize:
                                                                const Size(
                                                                  0,
                                                                  48,
                                                                ),
                                                            side: BorderSide(
                                                              color: Colors
                                                                  .grey
                                                                  .shade300,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'إلغاء',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(width: 10),

                                                      GetBuilder<CaseController>(
                                                        builder: (controller) => 
                                                         Expanded(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              // delete logic هنا
                                                              controller.deleteOrder(order.globalOrderId!);
                                                        
                                                              
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              elevation: 0,
                                                              minimumSize:
                                                                  const Size(
                                                                    0,
                                                                    48,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                            ),
                                                            child:  Text(
                                                              controller.isDeletingOrder ? "جار الحذف" : "حذف",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 10),

                                        // Send Invoice
                                        _buildOrderAction(
                                          icon: Icons.email_outlined,
                                          title: 'إرسال إيصال',
                                          subtitle:
                                              'إرسال الإيصال إلى بريد العميل',
                                          iconColor: const Color.fromARGB(
                                            255,
                                            205,
                                            202,
                                            48,
                                          ),
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            162,
                                            156,
                                            31,
                                          ).withOpacity(.10),
                                          onTap: () async {
                                            Get.back();

                                            Get.snackbar(
                                              'جاري الإرسال',
                                              'يتم الآن إرسال الإيصال إلى بريد العميل...',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              margin: const EdgeInsets.all(16),
                                              borderRadius: 12,
                                              backgroundColor: Colors.blue,
                                              colorText: Colors.white,
                                              icon: const Icon(
                                                Icons.email_outlined,
                                                color: Colors.white,
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            );

                                            final success = await controller
                                                .sendReceiptEmail(
                                                  toEmail:
                                                      order
                                                          .customer
                                                          ?.customerEmail ??
                                                      '',
                                                  customerName:
                                                      order
                                                          .customer
                                                          ?.customerName ??
                                                      '',
                                                  orderId: order.globalOrderId
                                                      .toString(),
                                                  order: order,
                                                );

                                            Get.closeAllSnackbars();

                                            Get.snackbar(
                                              success
                                                  ? 'تم الإرسال بنجاح ✓'
                                                  : 'فشل الإرسال',
                                              success
                                                  ? 'تم إرسال الإيصال إلى بريد العميل بنجاح'
                                                  : 'حدث خطأ أثناء إرسال الإيصال',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              margin: const EdgeInsets.all(16),
                                              borderRadius: 12,
                                              backgroundColor: success
                                                  ? Colors.green
                                                  : Colors.red,
                                              colorText: Colors.white,
                                              icon: Icon(
                                                success
                                                    ? Icons.check_circle_outline
                                                    : Icons.error_outline,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              duration: const Duration(
                                                seconds: 4,
                                              ),
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 10),

                                        _buildOrderAction(
                                          icon: Icons.email_outlined,
                                          title: 'إرسال الفاتورة',
                                          subtitle:
                                              'إرسال الفاتورة إلى بريد العميل',
                                          iconColor: Colors.green,
                                          backgroundColor: Colors.green
                                              .withOpacity(.10),
                                          onTap: () async {
                                            Get.back();

                                            Get.snackbar(
                                              'جاري الإرسال',
                                              'يتم الآن إرسال الفاتورة إلى بريد العميل...',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              margin: const EdgeInsets.all(16),
                                              borderRadius: 12,
                                              backgroundColor: Colors.blue,
                                              colorText: Colors.white,
                                              icon: const Icon(
                                                Icons.email_outlined,
                                                color: Colors.white,
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            );

                                            final success = await controller
                                                .sendInvoiceEmail(
                                                  toEmail:
                                                      order
                                                          .customer
                                                          ?.customerEmail ??
                                                      '',
                                                  customerName:
                                                      order
                                                          .customer
                                                          ?.customerName ??
                                                      '',
                                                  orderId: order.globalOrderId
                                                      .toString(),
                                                  order: order,
                                                );

                                            Get.closeAllSnackbars();

                                            Get.snackbar(
                                              success
                                                  ? 'تم الإرسال بنجاح ✓'
                                                  : 'فشل الإرسال',
                                              success
                                                  ? 'تم إرسال الفاتورة إلى بريد العميل بنجاح'
                                                  : 'حدث خطأ أثناء إرسال الفاتورة',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              margin: const EdgeInsets.all(16),
                                              borderRadius: 12,
                                              backgroundColor: success
                                                  ? Colors.green
                                                  : Colors.red,
                                              colorText: Colors.white,
                                              icon: Icon(
                                                success
                                                    ? Icons.check_circle_outline
                                                    : Icons.error_outline,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                              duration: const Duration(
                                                seconds: 4,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: (hasCar && brandImgUrl != null && brandImgUrl.isNotEmpty)
                              ? Image.network(
                                  brandImgUrl,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.build_circle_outlined,
                                      color: colors.onPrimaryContainer,
                                      size: 26,
                                    );
                                  },
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onPrimaryContainer,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.build_circle_outlined,
                                  color: colors.onPrimaryContainer,
                                  size: 26,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // بيانات السيارة (سنة/براند/موديل + الفن) في حال وجود سيارة
                    // وإلا اسم الزبون، وتحته التاريخ والوقت
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hasCar
                                      ? [
                                          carInfo.carYear?.carYearNumber,
                                          carInfo.carBrand?.carBrandName,
                                          carInfo.carModel?.carModelName,
                                        ]
                                            .whereType<String>()
                                            .where((e) => e.isNotEmpty)
                                            .join(' ')
                                      : (order.customer?.customerName ?? "بدون اسم"),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (hasCar &&
                              carInfo.vinNumber != null &&
                              carInfo.vinNumber!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              carInfo.vinNumber!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
      },
    );
  }

  Widget _buildOrderAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}