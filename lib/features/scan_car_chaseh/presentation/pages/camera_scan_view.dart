import 'dart:io';
import 'package:camera/camera.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/controllers/scan_chaseh_controller.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/pages/car_info_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CameraScanView extends StatefulWidget {
  const CameraScanView({super.key});

  @override
  State<CameraScanView> createState() => _CameraScanViewState();
}

class _CameraScanViewState extends State<CameraScanView>
    with WidgetsBindingObserver {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final MobileScannerController _barcodeController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: false,
  );
  late final ScanChasehController _scanController;
  final SpeechToText _speech = SpeechToText();
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _isBarcodeMode = false;
  bool _isProcessing = false;
  bool _isListening = false;
  bool _hasFinalResult = false;
  bool _isInitializingCamera = false;
  String? _cameraErrorMessage;
  String _text = 'اضغط وابدأ التحدث';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanController = Get.find<ScanChasehController>();
    // Initialize camera on startup (start in camera capture mode)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isBarcodeMode) {
        _initCamera();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted || _isBarcodeMode) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCameraController();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint("Status: $status");
        // Use 'done' as fallback only if no final result was received yet
        if (status == 'done' && _isListening && !_hasFinalResult) {
          _processFinalSpeech();
        }
      },
      onError: (error) {
        debugPrint("Error: $error");
        if (_isListening) {
          _processFinalSpeech();
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _hasFinalResult = false;
        _text = '';
      });

      _speech.listen(
        localeId: "en-US",
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
            debugPrint("Recognized (final=${result.finalResult}): $_text");
          });
          // Process immediately when final result arrives
          if (result.finalResult && _isListening) {
            _hasFinalResult = true;
            _processFinalSpeech();
          }
        },
      );
    }
  }

  void _processFinalSpeech() {
    if (!mounted) return;
    setState(() {
      _isListening = false;
      final converted = convertSpeechToCode(_text);
      _text = converted;
    });
    _showResultDialog(_text, "From Speech");
  }

  String convertSpeechToCode(String input) {
    final map = <String, String>{
      "zero": "0",
      "one": "1",
      "won": "1",
      "two": "2",
      "three": "3",
      "four": "4",
      "five": "5",
      "six": "6",
      "seven": "7",
      "eight": "8",
      "nine": "9",

      "a": "a",
      "b": "b",
      "c": "c",
      "d": "d",
      "e": "e",
      "f": "f",
      "g": "g",
      "h": "h",
      "i": "i",
      "j": "j",
      "k": "k",
      "l": "l",
      "m": "m",
      "n": "n",
      "o": "o",
      "p": "p",
      "q": "q",
      "r": "r",
      "s": "s",
      "t": "t",
      "u": "u",
      "v": "v",
      "w": "w",
      "x": "x",
      "y": "y",
      "z": "z",
    };

    final cleaned = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty);

    final buffer = StringBuffer();

    for (final word in cleaned) {
      buffer.write(map[word] ?? word);
    }

    return buffer.toString();
  }

  void _stopListening() {
    _speech.stop();
    // onStatus callback will handle processing when speech engine is done
  }

  Future<void> _initCamera() async {
    if (_cameraController != null || _isInitializingCamera) return;

    setState(() {
      _isInitializingCamera = true;
      _cameraErrorMessage = null;
    });

    try {
      var permission = await Permission.camera.status;
      if (permission.isDenied) {
        permission = await Permission.camera.request();
      }

      if (!permission.isGranted) {
        debugPrint('Camera permission denied or blocked: $permission');
        if (mounted) {
          setState(() {
            _cameraErrorMessage =
                permission.isPermanentlyDenied || permission.isRestricted
                ? 'Camera access is blocked. Please enable it from iPhone Settings.'
                : 'Camera permission is required to capture image.';
          });
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        if (mounted) {
          setState(() {
            _cameraErrorMessage = 'No camera found on this device.';
          });
        }
        return;
      }

      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        back,
        ResolutionPreset.high, // Use medium — high is too heavy
        enableAudio: false,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _cameraController = controller;
        _isCameraReady = true;
        _cameraErrorMessage = null;
      });
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _cameraErrorMessage = 'Failed to initialize camera.';
        });
        Get.snackbar(
          'Camera Error',
          'Failed to initialize camera: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializingCamera = false;
        });
      }
    }
  }

  Future<void> _disposeCameraController() async {
    final ctrl = _cameraController;
    _cameraController = null;
    _isCameraReady = false;
    await ctrl?.dispose();
  }

  // ================= Camera Capture =================
  Future<void> _captureImage() async {
    if (_cameraController == null || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final file = await _cameraController!.takePicture();

      await _extractTextFromImage(file.path);
    } catch (e) {
      debugPrint("Capture Error: $e");

      Get.snackbar(
        'Capture Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _extractTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _textRecognizer.processImage(inputImage);
    final extractedText = recognized.text.trim();
    _showCapturedImageDialog(imagePath, extractedText);
  }

  void _showCapturedImageDialog(String imagePath, String extractedText) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 280,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _resume();
                      },
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('إعادة التقاط'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showTextInputDialog(extractedText);
                      },
                      icon: const Icon(Icons.text_fields_rounded),
                      label: const Text('استخراج نص'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

  void _showTextInputDialog([String initialText = '']) {
    final TextEditingController textCtrl =
        TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('النص المستخرج'),
        content: TextField(
          controller: textCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'أدخل النص هنا...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resume();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = textCtrl.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context);
              await _requestDetails(text);
            },
            child: const Text('Get Details'),
          ),
        ],
      ),
    );
  }

  // ================= Barcode =================
  void _onDetect(BarcodeCapture capture) {
    if (!_isBarcodeMode) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    _barcodeController.stop();
    _showResultDialog(code, "From Barcode");
  }

  // ================= UI =================
  void _showResultDialog(String text, String type) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Detected: $type"),
        content: SingleChildScrollView(
          child: TextField(controller: TextEditingController(text: text)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resume();
            },
            child: const Text("Retry"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _requestDetails(text);
            },
            child: const Text("Get Details"),
          ),
        ],
      ),
    );
  }

  Future<void> _requestDetails(String scannedValue) async {
    _showApiLoadingDialog();

    final success = await _scanController.requestDetailsFromScan(
      scannedValue: scannedValue,
    );

    _hideApiLoadingDialog();

    if (!mounted) return;

    if (success) {
      Get.to(() => const CarInfoView(), arguments: _scanController.carData);
    } else {
      Get.snackbar(
        'Error',
        _scanController.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      _resume();
    }
  }

  void _showApiLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              SizedBox(width: 14),
              Expanded(child: Text('Please wait, loading data...')),
            ],
          ),
        ),
      ),
    );
  }

  void _hideApiLoadingDialog() {
    if (!mounted) return;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _resume() {
    if (_isBarcodeMode) {
      _barcodeController.start();
    }
  }

  Future<void> _switchMode(bool barcode) async {
    if (_isBarcodeMode == barcode) return; // No change

    try {
      setState(() {
        _isBarcodeMode = barcode;
        _isCameraReady = false;
        _cameraErrorMessage = null;
      });

      if (barcode) {
        // Switching to barcode: release camera, start barcode scanner
        await _disposeCameraController();
        if (mounted) {
          await _barcodeController.start();
        }
      } else {
        // Switching to camera capture: stop barcode scanner, init camera
        await _barcodeController.stop();
        if (mounted) {
          await _initCamera();
        }
      }
    } catch (e) {
      debugPrint('Mode switch error: $e');
      if (mounted) {
        Get.snackbar(
          'Mode Switch Error',
          'Failed to switch mode: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.7),
        );
        setState(() {
          _isBarcodeMode = !barcode; // Revert on error
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeController.dispose();
    _textRecognizer.close();
    _speech.stop();
    super.dispose();
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera / Scanner Feed ──────────────────────────
          Positioned.fill(
            child: _isBarcodeMode
                ? MobileScanner(
                    controller: _barcodeController,
                    onDetect: _onDetect,
                  )
                : _isCameraReady
                ? CameraPreview(_cameraController!)
                : _cameraErrorMessage != null
                ? _CameraErrorView(
                    message: _cameraErrorMessage!,
                    onRetry: _initCamera,
                  )
                : const ColoredBox(
                    color: Colors.black,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
          ),

          // ── Dark gradient top ──────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Dark gradient bottom ───────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Top bar: Back + Title ──────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _isBarcodeMode ? 'Barcode' : 'Camera Capture',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40), // balance back button
                  ],
                ),
              ),
            ),
          ),

          // ── Scan frame overlay ─────────────────────────────
          Center(
            child: SizedBox(
              width: 260,
              height: _isBarcodeMode ? 260 : 200,
              child: Stack(
                children: [
                  // Corner decorations
                  _Corner(Alignment.topLeft),
                  _Corner(Alignment.topRight),
                  _Corner(Alignment.bottomLeft),
                  _Corner(Alignment.bottomRight),
                ],
              ),
            ),
          ),
          // ── Bottom controls ────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode toggle pill
                    Container(
                      height: 52,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          _ModeTab(
                            label: 'Barcode',
                            icon: Icons.qr_code_scanner_rounded,
                            selected: _isBarcodeMode,
                            activeColor: const Color(0xFF00C6AE),
                            onTap: () => _switchMode(true),
                          ),
                          _ModeTab(
                            label: 'Camera',
                            icon: Icons.text_fields_rounded,
                            selected: !_isBarcodeMode,
                            activeColor: const Color(0xFF6C63FF),
                            onTap: () => _switchMode(false),
                          ),
                          _ModeTab(
                            label: _isListening ? 'Listening...' : 'Speech',
                            icon: Icons.mic_rounded,
                            selected: _isListening,
                            activeColor: const Color(0xFF00A86B),
                            onTap: () => _isListening
                                ? _stopListening()
                                : _startListening(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),

                    // OCR capture button
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: !_isBarcodeMode
                          ? GestureDetector(
                              key: const ValueKey('captureBtn'),
                              onTap: (_isProcessing || !_isCameraReady)
                                  ? null
                                  : _captureImage,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isProcessing
                                      ? Colors.white38
                                      : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF6C63FF,
                                      ).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: _isProcessing
                                    ? const Padding(
                                        padding: EdgeInsets.all(18),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Color(0xFF6C63FF),
                                        ),
                                      )
                                    : Icon(
                                        Icons.camera_alt_rounded,
                                        color: !_isCameraReady
                                            ? Colors.grey
                                            : const Color(0xFF6C63FF),
                                        size: 32,
                                      ),
                              ),
                            )
                          : const SizedBox(key: ValueKey('empty'), height: 70),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Corner decoration widget ───────────────────────────────────────────────
class _Corner extends StatelessWidget {
  final Alignment alignment;
  const _Corner(this.alignment);

  @override
  Widget build(BuildContext context) {
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 36,
        height: 36,
        child: CustomPaint(
          painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  const _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double x = isLeft ? 0 : size.width;
    final double y = isTop ? 0 : size.height;
    final double dx = isLeft ? size.width : -size.width;
    final double dy = isTop ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Mode tab widget ────────────────────────────────────────────────────────
class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : Colors.white54,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white54,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CameraErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white70,
                size: 46,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: onRetry,
                    child: const Text('Retry'),
                  ),
                  ElevatedButton(
                    onPressed: openAppSettings,
                    child: const Text('Open Settings'),
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
