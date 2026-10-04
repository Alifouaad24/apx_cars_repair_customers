import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/controllers/scan_chaseh_controller.dart';
import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/pages/car_info_view.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
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

  double _frameHeight = 110;
  static const double _minFrameHeight = 60;
  static const double _maxFrameHeight = 220;

  bool get _returnResultToCaller {
    final args = Get.arguments;
    if (args is! Map) return false;
    return args['returnResult'] == true;
  }

  Size _rotatedPreviewSize() {
    final ps = _cameraController!.value.previewSize!;
    return Size(ps.height, ps.width);
  }

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

  // ================= Speech =================
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

  // ================= Camera Init =================
  Future<void> _initCamera() async {
    if (_cameraController != null || _isInitializingCamera) return;

    setState(() {
      _isInitializingCamera = true;
      _cameraErrorMessage = null;
    });

    try {
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
        ResolutionPreset.high,
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
    } on CameraException catch (e) {
      debugPrint('Camera exception (${e.code}): ${e.description}');
      if (mounted) {
        final msg = switch (e.code) {
          'CameraAccessDenied' =>
            'Camera permission was denied. Please allow access and retry.',
          'CameraAccessDeniedWithoutPrompt' =>
            'Camera access is denied and cannot be requested again. Open iPhone Settings and allow camera access.',
          'CameraAccessRestricted' =>
            'Camera access is restricted on this device.',
          _ => 'Failed to initialize camera.',
        };

        setState(() {
          _cameraErrorMessage = msg;
        });
      }
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

    if (mounted) setState(() => _isProcessing = false);
  }

  /// موقع المستطيل الداخلي بإحداثيات طبيعية (0..1) نسبةً إلى الـ preview
  Rect _frameRectNormalizedInPreview(Size screen) {
    final preview = _rotatedPreviewSize();

    // نفس منطق FittedBox(fit: BoxFit.cover) المستخدم في العرض
    final scale = math.max(
      screen.width / preview.width,
      screen.height / preview.height,
    );
    final dispW = preview.width * scale;
    final dispH = preview.height * scale;
    final offX = (dispW - screen.width) / 2;
    final offY = (dispH - screen.height) / 2;

    // المستطيل بعرض الشاشة وفي منتصفها
    final frameTop = (screen.height - _frameHeight) / 2;
    final frameBottom = frameTop + _frameHeight;

    return Rect.fromLTRB(
      (0 + offX) / dispW,
      (frameTop + offY) / dispH,
      (screen.width + offX) / dispW,
      (frameBottom + offY) / dispH,
    );
  }

  Future<void> _extractTextFromImage(String imagePath) async {
    if (_cameraController == null) return;

    // نقرأ القيم قبل أي await
    final screenSize = MediaQuery.of(context).size;
    final norm = _frameRectNormalizedInPreview(screenSize);
    final preview = _rotatedPreviewSize();

    // 1) قص الصورة على حدود المستطيل فقط (في isolate منفصل)
    final croppedPath = await compute(
      _cropImageToFrame,
      _CropParams(
        path: imagePath,
        left: norm.left,
        top: norm.top,
        right: norm.right,
        bottom: norm.bottom,
        previewAspect: preview.width / preview.height,
      ),
    );

    // 2) OCR على الجزء المقصوص فقط
    final recognized = await _textRecognizer.processImage(
      InputImage.fromFilePath(croppedPath),
    );

    // 3) استخراج VIN
    final vin = extractVin(recognized);

    if (!mounted) return;

    if (vin == null) {
      Get.rawSnackbar(
        message: 'لم يتم العثور على VIN، حاول تقريب الكاميرا أو تعديل المستطيل',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    // نعرض الصورة المقصوصة حتى يرى المستخدم ما قرأه الـ OCR فعلاً
    _showCapturedImageDialog(
      croppedPath,
      vin ?? recognized.text.replaceAll('\n', ' ').trim(),
    );
  }

  Future<void> _focusOnFrame() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    // المستطيل دائماً في منتصف الشاشة، والـ preview متمركز أيضاً
    const point = Offset(0.5, 0.5);
    try {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setFocusPoint(point);
      await controller.setExposureMode(ExposureMode.auto);
      await controller.setExposurePoint(point);
    } catch (e) {
      debugPrint('Focus set error: $e');
    }
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                color: Colors.black,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 140,
                ),
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
    final TextEditingController textCtrl = TextEditingController(
      text: initialText,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Extracted text'),
        content: TextField(
          controller: textCtrl,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: '',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resume();
            },
            child: const Text('Cancel'),
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

    final trimmed = code.trim();

    // تحقق من طول الباركود: يجب أن يكون 17 محرفاً بالضبط
    if (trimmed.length != 17) {
      _showInvalidBarcodeToast();
      return; // لا نوقف المسح، نستمر بالانتظار لباركود صحيح
    }

    _barcodeController.stop();
    _showResultDialog(trimmed, "From Barcode");
  }

  DateTime? _lastInvalidToastTime;

  void _showInvalidBarcodeToast() {
    final now = DateTime.now();
    // نمنع تكرار التوستر أكثر من مرة كل ثانيتين لتفادي الإزعاج
    if (_lastInvalidToastTime != null &&
        now.difference(_lastInvalidToastTime!) < const Duration(seconds: 2)) {
      return;
    }
    _lastInvalidToastTime = now;

    Get.rawSnackbar(
      message: 'Not valid barcode.',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const ui.Color.fromARGB(221, 241, 7, 7),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      borderRadius: 10,
    );
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
      if (_returnResultToCaller) {
        _scanController.carData.addAll({'scannedValue': scannedValue});
        Get.back(result: _scanController.carData);
        return;
      }

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

  Rect _barcodeScanWindow(Size screenSize) {
    return Rect.fromCenter(
      center: screenSize.center(Offset.zero),
      width: screenSize.width,
      height: _frameHeight,
    );
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
          // ── Camera / Scanner Feed (full screen) ────────────
          Positioned.fill(
            child: _isBarcodeMode
                ? MobileScanner(
                    controller: _barcodeController,
                    fit: BoxFit.cover,
                    scanWindow: _barcodeScanWindow(MediaQuery.of(context).size),
                    onDetect: _onDetect,
                  )
                : _isCameraReady
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _rotatedPreviewSize().width,
                      height: _rotatedPreviewSize().height,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: _cameraErrorMessage != null
                        ? _CameraErrorView(
                            message: _cameraErrorMessage!,
                            onRetry: _initCamera,
                          )
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                  ),
          ),

          // ── Overlay بدرجة سواد 50% مع فتحة بحجم المستطيل ────
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ScannerOverlayPainter(
                  frameWidth: MediaQuery.of(context).size.width,
                  frameHeight: _frameHeight,
                ),
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

          // ── Scan frame overlay (resizable) ─────────────────
          Center(
            child: Builder(
              builder: (context) {
                final screenWidth = MediaQuery.of(context).size.width;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: screenWidth,
                      height: _frameHeight,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),

                    // زوايا الديكور
                    const Positioned(
                      top: 0,
                      left: 0,
                      child: _Corner(Alignment.topLeft),
                    ),
                    const Positioned(
                      top: 0,
                      right: 0,
                      child: _Corner(Alignment.topRight),
                    ),
                    const Positioned(
                      bottom: 0,
                      left: 0,
                      child: _Corner(Alignment.bottomLeft),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: _Corner(Alignment.bottomRight),
                    ),

                    // مقبض تغيير الارتفاع فقط (في المنتصف أسفل الشريط)
                    Positioned(
                      bottom: -14,
                      left: screenWidth / 2 - 15,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _frameHeight = (_frameHeight + details.delta.dy)
                                .clamp(_minFrameHeight, _maxFrameHeight);
                          });
                        },
                        onPanEnd: (_) => _focusOnFrame(),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.height_rounded,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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

// ═══════════════════════════════════════════════════════════════════════════
// قص الصورة على حدود المستطيل (يعمل في isolate منفصل عبر compute)
// ═══════════════════════════════════════════════════════════════════════════
class _CropParams {
  final String path;
  final double left, top, right, bottom;
  final double previewAspect;

  const _CropParams({
    required this.path,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.previewAspect,
  });
}

String _cropImageToFrame(_CropParams p) {
  final bytes = File(p.path).readAsBytesSync();
  var image = img.decodeImage(bytes);
  if (image == null) return p.path;

  // تطبيق دوران EXIF حتى تتطابق الصورة مع ما يظهر على الشاشة
  image = img.bakeOrientation(image);

  final imgW = image.width.toDouble();
  final imgH = image.height.toDouble();

  // الصورة الملتقطة قد تكون بنسبة مختلفة عن الـ preview (مثلاً 4:3 مقابل 16:9)
  // الجزء الظاهر في الـ preview هو المنطقة المتمركزة بنسبة الـ preview
  double visW = imgW, visH = imgH;
  if (imgW / imgH > p.previewAspect) {
    visW = imgH * p.previewAspect;
  } else {
    visH = imgW / p.previewAspect;
  }
  final visX = (imgW - visW) / 2;
  final visY = (imgH - visH) / 2;

  // هامش صغير عمودي حتى لا تُقص أطراف الحروف
  final margin = (p.bottom - p.top) * 0.08;
  final l = p.left.clamp(0.0, 1.0).toDouble();
  final r = p.right.clamp(0.0, 1.0).toDouble();
  final t = (p.top - margin).clamp(0.0, 1.0).toDouble();
  final b = (p.bottom + margin).clamp(0.0, 1.0).toDouble();

  final x = (visX + l * visW).round().clamp(0, image.width - 1).toInt();
  final y = (visY + t * visH).round().clamp(0, image.height - 1).toInt();
  final w = ((r - l) * visW).round().clamp(1, image.width - x).toInt();
  final h = ((b - t) * visH).round().clamp(1, image.height - y).toInt();

  var cropped = img.copyCrop(image, x: x, y: y, width: w, height: h);

  // تحسينات بسيطة للـ OCR
  if (cropped.width < 1600) {
    cropped = img.copyResize(
      cropped,
      width: 1600,
      interpolation: img.Interpolation.cubic,
    );
  }
  cropped = img.grayscale(cropped);
  cropped = img.adjustColor(cropped, contrast: 1.3);

  final outPath =
      '${Directory.systemTemp.path}/vin_crop_${DateTime.now().millisecondsSinceEpoch}.jpg';
  File(outPath).writeAsBytesSync(img.encodeJpg(cropped, quality: 95));
  return outPath;
}

// ═══════════════════════════════════════════════════════════════════════════
// استخراج VIN من نص الـ OCR
// ═══════════════════════════════════════════════════════════════════════════
final RegExp _vinRegex = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');

String _normalizeForVin(String s) {
  return s
      .toUpperCase()
      // إزالة الكلمات المساعدة مثل "VIN" و "NO" و "CHASSIS"
      .replaceAll(RegExp(r'\b(VIN|NO|CHASSIS)\b'), ' ')
      .replaceAll(RegExp(r'[^A-Z0-9 ]'), ' ')
      // أخطاء OCR الشائعة: هذه الحروف غير مسموحة في VIN
      .replaceAll('O', '0')
      .replaceAll('Q', '0')
      .replaceAll('I', '1');
}

String? extractVin(RecognizedText recognized) {
  final sources = <String>[
    for (final block in recognized.blocks)
      for (final line in block.lines) line.text,
    for (final block in recognized.blocks) block.text,
    recognized.text,
  ];

  final scores = <String, int>{};

  for (final src in sources) {
    final normalized = _normalizeForVin(src);

    // أ) كلمة مستقلة طولها 17 بالضبط (الأقوى)
    for (final token in normalized.split(RegExp(r'\s+'))) {
      if (_vinRegex.hasMatch(token)) {
        scores[token] = (scores[token] ?? 0) + 2;
      }
    }

    // ب) الـ OCR أحياناً يضع مسافات داخل الـ VIN: نزيلها ونجرب كل نافذة بطول 17
    final joined = normalized.replaceAll(' ', '');
    for (var i = 0; i + 17 <= joined.length; i++) {
      final cand = joined.substring(i, i + 17);
      if (_vinRegex.hasMatch(cand)) {
        scores[cand] = scores[cand] ?? 0;
      }
    }
  }

  if (scores.isEmpty) return null;

  // رقم التحقق يرفع الأولوية (إلزامي في أمريكا الشمالية فقط، لذلك ليس شرطاً)
  for (final key in scores.keys.toList()) {
    if (isValidVinChecksum(key)) scores[key] = scores[key]! + 3;
  }

  final sorted = scores.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.first.key;
}

bool isValidVinChecksum(String vin) {
  if (vin.length != 17) return false;
  const translit = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
    'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9,
  };
  const weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];

  var sum = 0;
  for (var i = 0; i < 17; i++) {
    final c = vin[i];
    final v = int.tryParse(c) ?? translit[c];
    if (v == null) return false;
    sum += v * weights[i];
  }
  final r = sum % 11;
  final check = r == 10 ? 'X' : '$r';
  return vin[8] == check;
}

// ═══════════════════════════════════════════════════════════════════════════
// Widgets
// ═══════════════════════════════════════════════════════════════════════════
class _ScannerOverlayPainter extends CustomPainter {
  final double frameWidth;
  final double frameHeight;

  _ScannerOverlayPainter({required this.frameWidth, required this.frameHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.5) // درجة الشفافية 50%
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final holeRect = Rect.fromCenter(
      center: center,
      width: frameWidth,
      height: frameHeight,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(holeRect)
      ..fillType = PathFillType.evenOdd; // يفرّغ منطقة المستطيل

    canvas.drawPath(path, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.frameWidth != frameWidth ||
        oldDelegate.frameHeight != frameHeight;
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
//////////////////////////////// Scanbot /////////////////////////////////////

// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui' as ui;

// import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/controllers/scan_chaseh_controller.dart';
// import 'package:apx_cars_repair/features/scan_car_chaseh/presentation/pages/car_info_view.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:scanbot_sdk/scanbot_sdk.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// class CameraScanView extends StatefulWidget {
//   const CameraScanView({super.key});

//   @override
//   State<CameraScanView> createState() => _CameraScanViewState();
// }

// class _CameraScanViewState extends State<CameraScanView>
//     with WidgetsBindingObserver {
//   late final ScanChasehController _scanController;

//   final SpeechToText _speech = SpeechToText();

//   DocumentScannerCameraController? _documentCameraController;
//   BarcodeScannerCameraController? _barcodeCameraController;

//   bool _isBarcodeMode = false;
//   bool _isProcessing = false;
//   bool _isListening = false;
//   bool _hasFinalResult = false;

//   bool _cameraPermissionGranted = false;

//   String _text = 'اضغط وابدأ التحدث';

//   double _frameHeight = 110;

//   static const double _minFrameHeight = 60;
//   static const double _maxFrameHeight = 220;

//   DateTime? _lastInvalidToastTime;

//   bool get _returnResultToCaller {
//     final args = Get.arguments;

//     if (args is! Map) {
//       return false;
//     }

//     return args['returnResult'] == true;
//   }

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);

//     _scanController = Get.find<ScanChasehController>();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _requestCameraPermission();
//     });
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!mounted) {
//       return;
//     }

//     if (state == AppLifecycleState.resumed) {
//       _requestCameraPermission();
//     }
//   }

//   // ============================================================
//   // Permission
//   // ============================================================

//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _cameraPermissionGranted = status.isGranted;
//     });

//     if (!status.isGranted) {
//       Get.snackbar(
//         'Camera Permission',
//         'Camera permission is required for scanning.',
//         snackPosition: SnackPosition.BOTTOM,
//         duration: const Duration(seconds: 3),
//       );
//     }
//   }

//   // ============================================================
//   // Speech
//   // ============================================================

//   Future<void> _startListening() async {
//     if (_isListening) {
//       return;
//     }

//     final available = await _speech.initialize(
//       onStatus: (status) {
//         debugPrint('Speech status: $status');

//         if (status == 'done' &&
//             _isListening &&
//             !_hasFinalResult &&
//             _text.trim().isNotEmpty) {
//           _processFinalSpeech();
//         }
//       },
//       onError: (error) {
//         debugPrint('Speech error: $error');

//         if (_isListening && _text.trim().isNotEmpty) {
//           _processFinalSpeech();
//         }
//       },
//     );

//     if (!available) {
//       Get.snackbar(
//         'Speech',
//         'Speech recognition is not available.',
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       return;
//     }

//     setState(() {
//       _isListening = true;
//       _hasFinalResult = false;
//       _text = '';
//     });

//     await _speech.listen(
//       localeId: 'en-US',
//       listenFor: const Duration(seconds: 60),
//       pauseFor: const Duration(seconds: 3),
//       partialResults: true,
//       onResult: (result) {
//         if (!mounted) {
//           return;
//         }

//         setState(() {
//           _text = result.recognizedWords;
//         });

//         debugPrint(
//           'Recognized '
//           '(final=${result.finalResult}): $_text',
//         );

//         if (result.finalResult && _isListening) {
//           _hasFinalResult = true;
//           _processFinalSpeech();
//         }
//       },
//     );
//   }

//   void _processFinalSpeech() {
//     if (!mounted) {
//       return;
//     }

//     final converted = convertSpeechToCode(_text);

//     setState(() {
//       _isListening = false;
//       _text = converted;
//     });

//     _showResultDialog(converted, 'From Speech');
//   }

//   String convertSpeechToCode(String input) {
//     final map = <String, String>{
//       'zero': '0',
//       'one': '1',
//       'won': '1',
//       'two': '2',
//       'three': '3',
//       'four': '4',
//       'five': '5',
//       'six': '6',
//       'seven': '7',
//       'eight': '8',
//       'nine': '9',

//       'a': 'a',
//       'b': 'b',
//       'c': 'c',
//       'd': 'd',
//       'e': 'e',
//       'f': 'f',
//       'g': 'g',
//       'h': 'h',
//       'i': 'i',
//       'j': 'j',
//       'k': 'k',
//       'l': 'l',
//       'm': 'm',
//       'n': 'n',
//       'o': 'o',
//       'p': 'p',
//       'q': 'q',
//       'r': 'r',
//       's': 's',
//       't': 't',
//       'u': 'u',
//       'v': 'v',
//       'w': 'w',
//       'x': 'x',
//       'y': 'y',
//       'z': 'z',
//     };

//     final cleaned = input
//         .toLowerCase()
//         .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
//         .split(RegExp(r'\s+'))
//         .where((e) => e.isNotEmpty);

//     final buffer = StringBuffer();

//     for (final word in cleaned) {
//       buffer.write(map[word] ?? word);
//     }

//     return buffer.toString();
//   }

//   void _stopListening() {
//     _speech.stop();

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _isListening = false;
//     });
//   }

//   // ============================================================
//   // Scanbot Barcode
//   // ============================================================

//   Widget _buildBarcodeCamera() {
//     return BarcodeScannerCamera(
//       controller: _barcodeCameraController,
//       configuration: BarcodeCameraConfiguration(
//         scannerConfiguration: BarcodeClassicScannerConfiguration(
//           barcodeFormatConfigurations: [
//             BarcodeFormatConfigurationBase.barcodeFormatCommonConfiguration(),
//           ],
//           engineMode: BarcodeScannerEngineMode.NEXT_GEN,
//           returnBarcodeImage: true,
//           onlyAcceptDocuments: false,
//         ),
//         flashEnabled: true,
//         hardwareButtonsEnabled: true,
//         minFocusDistanceLock: true,
//         cameraModule: CameraModule.BACK,
//         finder: FinderConfiguration(
//           decoration: const BoxDecoration(color: Colors.transparent),
//         ),
//       ),
//       barcodeListener: (results) {
//         if (!_isBarcodeMode) {
//           return;
//         }

//         if (results.isEmpty) {
//           return;
//         }

//         for (final item in results) {
//           final value = item.text?.trim();

//           if (value == null || value.isEmpty) {
//             continue;
//           }

//           _handleBarcode(value);

//           break;
//         }
//       },
//       onError: (error) {
//         debugPrint('Scanbot barcode error: $error');
//       },
//       onCameraPreviewStarted: (flashAvailable) {
//         debugPrint(
//           'Scanbot barcode camera started. '
//           'Flash available: $flashAvailable',
//         );
//       },
//       onPictureTaken: (image) async {
//         debugPrint('Scanbot barcode picture captured.');
//       },
//     );
//   }

//   void _handleBarcode(String value) {
//     if (_isProcessing) {
//       return;
//     }

//     final trimmed = value.trim();

//     if (trimmed.length != 17) {
//       _showInvalidBarcodeToast();
//       return;
//     }

//     _showResultDialog(trimmed, 'From Barcode');
//   }

//   void _showInvalidBarcodeToast() {
//     final now = DateTime.now();

//     if (_lastInvalidToastTime != null &&
//         now.difference(_lastInvalidToastTime!) < const Duration(seconds: 2)) {
//       return;
//     }

//     _lastInvalidToastTime = now;

//     Get.rawSnackbar(
//       message: 'Not valid barcode.',
//       duration: const Duration(seconds: 2),
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: const Color.fromARGB(221, 241, 7, 7),
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//       borderRadius: 10,
//     );
//   }

//   // ============================================================
//   // Scanbot OCR Camera
//   // ============================================================

//   Widget _buildOcrCamera() {
//     _documentCameraController ??= DocumentScannerCameraController();

//     return DocumentScannerCamera(
//       controller: _documentCameraController,

//       configuration: DocumentCameraConfiguration(
//         scannerConfiguration: DocumentClassicScannerConfiguration(
//           autoSnapEnabled: false,
//           detectDocumentAfterSnap: true,
//         ),
//         touchToFocusEnabled: true,
//       ),

//       onSnappedDocumentResult:
//           (originalImage, documentImage, detectionResult) async {
//             if (!mounted) {
//               return;
//             }

//             debugPrint('========== SCANBOT SNAP RESULT ==========');
//             debugPrint('Original image: $originalImage');
//             debugPrint('Document image: $documentImage');
//             debugPrint('Detection result: $detectionResult');

//             try {
//               final image = documentImage ?? originalImage;

//               await _processOcrImage(image);
//             } catch (e, stackTrace) {
//               debugPrint('Scanbot OCR error: $e');
//               debugPrintStack(stackTrace: stackTrace);

//               if (mounted) {
//                 Get.snackbar(
//                   'OCR Error',
//                   'Failed to extract text.',
//                   snackPosition: SnackPosition.BOTTOM,
//                 );
//               }
//             } finally {
//               if (mounted) {
//                 setState(() {
//                   _isProcessing = false;
//                 });
//               }
//             }
//           },

//       onError: (error) {
//         debugPrint('Scanbot document camera error: $error');

//         if (mounted) {
//           setState(() {
//             _isProcessing = false;
//           });
//         }
//       },
//     );
//   }

//   Future<void> _processOcrImage(ImageRef image) async {
//     final result = await ScanbotSdk.ocrEngine.recognizeOnImageRefs([
//       image,
//     ], configuration: OcrConfiguration(languages: ['en']));

//     if (result is! Ok<PerformOcrResult>) {
//       Get.snackbar(
//         'OCR',
//         'Could not recognize text.',
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       return;
//     }

//     final ocrResult = result.value;

//     final text = _extractOcrText(ocrResult);

//     final vin = _extractVin(text);

//     if (vin == null) {
//       _showCapturedTextDialog(text);

//       return;
//     }

//     _showResultDialog(vin, 'From OCR');
//   }

//   String _extractOcrText(PerformOcrResult result) {
//     final buffer = StringBuffer();

//     for (final page in result.pages) {
//       for (final block in page.blocks) {
//         for (final line in block.lines) {
//           final value = line.text.trim();

//           if (value.isEmpty) {
//             continue;
//           }

//           buffer.writeln(value);
//         }
//       }
//     }

//     return buffer.toString().trim();
//   }

//   String? _extractVin(String rawText) {
//     final normalized = rawText.toUpperCase().replaceAll(
//       RegExp(r'[^A-Z0-9]'),
//       '',
//     );

//     if (normalized.length == 17 && _isValidVin(normalized)) {
//       return normalized;
//     }

//     final candidates = rawText
//         .toUpperCase()
//         .split(RegExp(r'\s+'))
//         .map((e) => e.replaceAll(RegExp(r'[^A-Z0-9]'), ''))
//         .where((e) => e.length == 17);

//     for (final candidate in candidates) {
//       if (_isValidVin(candidate)) {
//         return candidate;
//       }
//     }

//     return null;
//   }

//   bool _isValidVin(String value) {
//     if (value.length != 17) {
//       return false;
//     }

//     if (RegExp(r'[IOQ]').hasMatch(value)) {
//       return false;
//     }

//     return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(value);
//   }

//   // ============================================================
//   // Result Dialog
//   // ============================================================

//   void _showCapturedTextDialog(String text) {
//     final controller = TextEditingController(text: text);

//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: const Text('Extracted text'),
//           content: TextField(
//             controller: controller,
//             maxLines: 6,
//             decoration: const InputDecoration(border: OutlineInputBorder()),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final value = controller.text.trim();

//                 if (value.isEmpty) {
//                   return;
//                 }

//                 Navigator.pop(context);

//                 await _requestDetails(value);
//               },
//               child: const Text('Get Details'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showResultDialog(String text, String type) {
//     final controller = TextEditingController(text: text);

//     showDialog(
//       context: context,
//       builder: (_) {
//         return AlertDialog(
//           title: Text('Detected: $type'),
//           content: SingleChildScrollView(
//             child: TextField(controller: controller),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);

//                 _resumeScanner();
//               },
//               child: const Text('Retry'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 Navigator.pop(context);

//                 final value = controller.text.trim();

//                 if (value.isEmpty) {
//                   _resumeScanner();

//                   return;
//                 }

//                 await _requestDetails(value);
//               },
//               child: const Text('Get Details'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ============================================================
//   // API
//   // ============================================================

//   Future<void> _requestDetails(String scannedValue) async {
//     _showApiLoadingDialog();

//     final success = await _scanController.requestDetailsFromScan(
//       scannedValue: scannedValue,
//     );

//     _hideApiLoadingDialog();

//     if (!mounted) {
//       return;
//     }

//     if (success) {
//       if (_returnResultToCaller) {
//         _scanController.carData.addAll({'scannedValue': scannedValue});

//         Get.back(result: _scanController.carData);

//         return;
//       }

//       Get.to(() => const CarInfoView(), arguments: _scanController.carData);
//     } else {
//       Get.snackbar(
//         'Error',
//         _scanController.errorMessage,
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       _resumeScanner();
//     }
//   }

//   void _showApiLoadingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) {
//         return const PopScope(
//           canPop: false,
//           child: AlertDialog(
//             content: Row(
//               children: [
//                 SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(strokeWidth: 2.6),
//                 ),
//                 SizedBox(width: 14),
//                 Expanded(child: Text('Please wait, loading data...')),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _hideApiLoadingDialog() {
//     if (!mounted) {
//       return;
//     }

//     if (Navigator.of(context, rootNavigator: true).canPop()) {
//       Navigator.of(context, rootNavigator: true).pop();
//     }
//   }

//   void _resumeScanner() {
//     if (!mounted) return;

//     setState(() {
//       _isProcessing = false;
//     });
//   }

//   // ============================================================
//   // Mode
//   // ============================================================

//   Future<void> _switchMode(bool barcode) async {
//     if (_isBarcodeMode == barcode) {
//       return;
//     }

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _isBarcodeMode = barcode;
//       _isProcessing = false;
//     });

//     if (barcode) {
//       _documentCameraController = null;
//     } else {
//       _barcodeCameraController = null;
//     }
//   }

//   // ============================================================
//   // Build
//   // ============================================================

//   @override
//   Widget build(BuildContext context) {
//     if (!_cameraPermissionGranted) {
//       return Scaffold(
//         backgroundColor: Colors.black,
//         body: _buildPermissionView(),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           // ======================================================
//           // Scanbot camera
//           // ======================================================
//           Positioned.fill(
//             child: _isBarcodeMode ? _buildBarcodeCamera() : _buildOcrCamera(),
//           ),

//           // ======================================================
//           // Dark overlay
//           // ======================================================
//           Positioned.fill(
//             child: IgnorePointer(
//               child: CustomPaint(
//                 painter: _ScannerOverlayPainter(
//                   frameWidth: MediaQuery.of(context).size.width,
//                   frameHeight: _frameHeight,
//                 ),
//               ),
//             ),
//           ),

//           // ======================================================
//           // Top gradient
//           // ======================================================
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             height: 160,
//             child: DecoratedBox(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Colors.black87, Colors.transparent],
//                 ),
//               ),
//             ),
//           ),

//           // ======================================================
//           // Bottom gradient
//           // ======================================================
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             height: 200,
//             child: DecoratedBox(
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [Colors.black87, Colors.transparent],
//                 ),
//               ),
//             ),
//           ),

//           // ======================================================
//           // Top bar
//           // ======================================================
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       icon: const Icon(
//                         Icons.arrow_back_ios_new_rounded,
//                         color: Colors.white,
//                       ),
//                     ),

//                     const Spacer(),

//                     Text(
//                       _isBarcodeMode ? 'Barcode' : 'Camera Capture',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.5,
//                       ),
//                     ),

//                     const Spacer(),

//                     const SizedBox(width: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // ======================================================
//           // Scanner frame
//           // ======================================================
//           Center(
//             child: Builder(
//               builder: (context) {
//                 final screenWidth = MediaQuery.of(context).size.width;

//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     Container(
//                       width: screenWidth,
//                       height: _frameHeight,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.white, width: 1.5),
//                       ),
//                     ),

//                     Positioned(
//                       top: 0,
//                       left: 0,
//                       child: _Corner(Alignment.topLeft),
//                     ),

//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       child: _Corner(Alignment.topRight),
//                     ),

//                     Positioned(
//                       bottom: 0,
//                       left: 0,
//                       child: _Corner(Alignment.bottomLeft),
//                     ),

//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: _Corner(Alignment.bottomRight),
//                     ),

//                     Positioned(
//                       bottom: -14,
//                       left: screenWidth / 2 - 15,
//                       child: GestureDetector(
//                         onPanUpdate: (details) {
//                           setState(() {
//                             _frameHeight = (_frameHeight + details.delta.dy)
//                                 .clamp(_minFrameHeight, _maxFrameHeight);
//                           });
//                         },
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.height_rounded,
//                             size: 16,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),

//           // ======================================================
//           // Bottom controls
//           // ======================================================
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                   vertical: 16,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Container(
//                       height: 52,
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: Colors.white12,
//                         borderRadius: BorderRadius.circular(30),
//                         border: Border.all(color: Colors.white24),
//                       ),
//                       child: Row(
//                         children: [
//                           _ModeTab(
//                             label: 'Barcode',
//                             icon: Icons.qr_code_scanner_rounded,
//                             selected: _isBarcodeMode,
//                             activeColor: const Color(0xFF00C6AE),
//                             onTap: () {
//                               _switchMode(true);
//                             },
//                           ),

//                           _ModeTab(
//                             label: 'Camera',
//                             icon: Icons.text_fields_rounded,
//                             selected: !_isBarcodeMode,
//                             activeColor: const Color(0xFF6C63FF),
//                             onTap: () {
//                               _switchMode(false);
//                             },
//                           ),

//                           _ModeTab(
//                             label: _isListening ? 'Listening...' : 'Speech',
//                             icon: Icons.mic_rounded,
//                             selected: _isListening,
//                             activeColor: const Color(0xFF00A86B),
//                             onTap: () {
//                               if (_isListening) {
//                                 _stopListening();
//                               } else {
//                                 _startListening();
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 2),

//                     // Camera capture button.
//                     if (!_isBarcodeMode)
//                       GestureDetector(
//                         onTap: _isProcessing
//                             ? null
//                             : () async {
//                                 await _captureWithScanbot();
//                               },
//                         child: Container(
//                           width: 70,
//                           height: 70,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _isProcessing
//                                 ? Colors.white38
//                                 : Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF6C63FF).withOpacity(0.5),
//                                 blurRadius: 20,
//                                 spreadRadius: 2,
//                               ),
//                             ],
//                           ),
//                           child: _isProcessing
//                               ? const Padding(
//                                   padding: EdgeInsets.all(18),
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2.5,
//                                     color: Color(0xFF6C63FF),
//                                   ),
//                                 )
//                               : const Icon(
//                                   Icons.camera_alt_rounded,
//                                   color: Color(0xFF6C63FF),
//                                   size: 32,
//                                 ),
//                         ),
//                       )
//                     else
//                       const SizedBox(height: 70),

//                     const SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _captureWithScanbot() async {
//     final controller = _documentCameraController;

//     if (controller == null || _isProcessing) {
//       return;
//     }

//     if (!mounted) {
//       return;
//     }

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       controller.snapDocument(acquireFocus: true);
//     } catch (e, stackTrace) {
//       debugPrint('Scanbot capture error: $e');
//       debugPrintStack(stackTrace: stackTrace);

//       if (!mounted) return;

//       setState(() {
//         _isProcessing = false;
//       });

//       Get.snackbar(
//         'Capture Error',
//         e.toString(),
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   Widget _buildPermissionView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.camera_alt_outlined,
//               color: Colors.white70,
//               size: 46,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Camera permission is required.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white, fontSize: 15),
//             ),
//             const SizedBox(height: 14),
//             ElevatedButton(
//               onPressed: _requestCameraPermission,
//               child: const Text('Allow Camera'),
//             ),
//             const SizedBox(height: 8),
//             OutlinedButton(
//               onPressed: openAppSettings,
//               child: const Text('Open Settings'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);

//     _speech.stop();

//     super.dispose();
//   }
// }

// // ============================================================================
// // Overlay Painter
// // ============================================================================

// class _ScannerOverlayPainter extends CustomPainter {
//   final double frameWidth;
//   final double frameHeight;

//   _ScannerOverlayPainter({required this.frameWidth, required this.frameHeight});

//   @override
//   void paint(Canvas canvas, ui.Size size) {
//     final overlayPaint = Paint()
//       ..color = Colors.black.withOpacity(0.5)
//       ..style = PaintingStyle.fill;

//     final center = Offset(size.width / 2, size.height / 2);

//     final holeRect = ui.Rect.fromCenter(
//       center: center,
//       width: frameWidth,
//       height: frameHeight,
//     );

//     final path = Path()
//       ..addRect(ui.Rect.fromLTWH(0, 0, size.width, size.height))
//       ..addRect(holeRect)
//       ..fillType = PathFillType.evenOdd;

//     canvas.drawPath(path, overlayPaint);
//   }

//   @override
//   bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
//     return oldDelegate.frameWidth != frameWidth ||
//         oldDelegate.frameHeight != frameHeight;
//   }
// }

// // ============================================================================
// // Corner
// // ============================================================================

// class _Corner extends StatelessWidget {
//   final Alignment alignment;

//   const _Corner(this.alignment);

//   @override
//   Widget build(BuildContext context) {
//     final isTop =
//         alignment == Alignment.topLeft || alignment == Alignment.topRight;

//     final isLeft =
//         alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

//     return Align(
//       alignment: alignment,
//       child: SizedBox(
//         width: 36,
//         height: 36,
//         child: CustomPaint(
//           painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
//         ),
//       ),
//     );
//   }
// }

// // ============================================================================
// // Corner Painter
// // ============================================================================

// class _CornerPainter extends CustomPainter {
//   final bool isTop;
//   final bool isLeft;

//   const _CornerPainter({required this.isTop, required this.isLeft});

//   @override
//   void paint(Canvas canvas, ui.Size size) {
//     final paint = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 3.5
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;

//     final double x = isLeft ? 0 : size.width;
//     final double y = isTop ? 0 : size.height;

//     final double dx = isLeft ? size.width : -size.width;

//     final double dy = isTop ? size.height : -size.height;

//     canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);

//     canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
//   }

//   @override
//   bool shouldRepaint(covariant _CornerPainter oldDelegate) {
//     return false;
//   }
// }

// // ============================================================================
// // Mode Tab
// // ============================================================================

// class _ModeTab extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool selected;
//   final Color activeColor;
//   final VoidCallback onTap;

//   const _ModeTab({
//     required this.label,
//     required this.icon,
//     required this.selected,
//     required this.activeColor,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeInOut,
//           decoration: BoxDecoration(
//             color: selected ? activeColor : Colors.transparent,
//             borderRadius: BorderRadius.circular(26),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 icon,
//                 size: 18,
//                 color: selected ? Colors.white : Colors.white54,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: selected ? Colors.white : Colors.white54,
//                   fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
//                   fontSize: 14,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
