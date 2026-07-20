import 'package:apx_cars_repair/features/cases/data/models/OrderModel.dart';
import 'package:apx_cars_repair/features/customers/data/models/CustomerModel.dart';
import 'package:flutter/material.dart';

class CarInfoCard extends StatelessWidget {
  const CarInfoCard({
    super.key,
    required this.carInfo,
    this.customer,
    this.scheduleDate,
  });

  final CarInfoModel carInfo;
  final CustomerModel? customer;
  // مرر currentCase.scheduleDt من الطلب اذا تحب تعرض شارة التاريخ
  final String? scheduleDate;

  @override
  Widget build(BuildContext context) {
    final brand = carInfo.carBrand?.carBrandName ?? '';
    final model = carInfo.carModel?.carModelName ?? '';
    final title = '$brand $model'.trim();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0E7490).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E7490).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Color(0xFF0E7490),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? 'بدون معلومات سيارة' : title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (carInfo.carYear?.carYearNumber != null)
                      Text(
                        carInfo.carYear!.carYearNumber,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    // اسم الزبون - صار متاح لأننا نستقبله كباراميتر مستقل الآن
                    if (customer?.customerName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 13,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customer!.customerName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (scheduleDate != null && scheduleDate!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E7490).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    scheduleDate!.split('T').first,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF0E7490),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.fingerprint_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                'VIN: ',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Expanded(
                child: Text(
                  carInfo.vinNumber ?? 'غير محدد',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}