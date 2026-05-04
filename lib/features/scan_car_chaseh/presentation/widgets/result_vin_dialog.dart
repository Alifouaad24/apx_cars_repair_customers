import 'package:apx_cars_repair/core/network/dio_client.dart';
import 'package:apx_cars_repair/core/services/TokenService.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/controllers/scan_chaseh_controller.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/pages/car_info_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultVinDialog extends StatefulWidget {
  const ResultVinDialog({super.key});

  @override
  State<ResultVinDialog> createState() => _ResultVinDialogState();
}

class _ResultVinDialogState extends State<ResultVinDialog> {
  final TextEditingController textCtrl = TextEditingController();
  bool _isLoading = false;

  ScanChasehController _resolveScanController() {
    if (!Get.isRegistered<TokenService>()) {
      if (!Get.isRegistered<SharedPreferences>()) {
        throw StateError('SharedPreferences is not registered');
      }
      Get.lazyPut<TokenService>(
        () => TokenService(Get.find<SharedPreferences>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<DioClient>()) {
      Get.lazyPut<DioClient>(
        () => DioClient(Get.find<TokenService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScanChasehController>()) {
      Get.lazyPut<ScanChasehController>(
        () => ScanChasehController(Get.find<DioClient>()),
        fenix: true,
      );
    }

    return Get.find<ScanChasehController>();
  }

  Future<void> _onGetDetailsPressed() async {
    final text = textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final controller = _resolveScanController();
      final success = await controller.requestDetailsFromScan(
        scannedValue: text,
      );

      if (!mounted) return;

      if (!success) {
        final message = controller.errorMessage.isEmpty
            ? 'Failed to fetch car details'
            : controller.errorMessage;
        Get.snackbar(
          'Request Failed',
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Get.back();
      Get.to(() => const CarInfoView(), arguments: controller.carData);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Initialization Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter VIN'),
      content: TextField(
        controller: textCtrl,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Enter text here...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _onGetDetailsPressed,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Get Details'),
        ),
      ],
    );
  }
}
