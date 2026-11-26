import 'package:apx_cars_repair/features/customers/presentation/controller/CustomerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Opens the voice popup: listen for a business name, search the business
/// table, then open the map on its location.
Future<void> showVoiceBusinessSearchDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const VoiceBusinessSearchDialog(),
  );
}

enum _VoiceState { listening, searching, notClear, notFound, noLocation, error }

class VoiceBusinessSearchDialog extends StatefulWidget {
  const VoiceBusinessSearchDialog({super.key});

  @override
  State<VoiceBusinessSearchDialog> createState() =>
      _VoiceBusinessSearchDialogState();
}

class _VoiceBusinessSearchDialogState extends State<VoiceBusinessSearchDialog>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF0E7490);

  final SpeechToText _speech = SpeechToText();
  late final AnimationController _pulse;

  _VoiceState _state = _VoiceState.listening;
  String _words = '';
  List<String> _alternates = [];
  String _message = '';
  bool _handled = false;
  bool _engineStarted = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _startListening();
  }

  @override
  void dispose() {
    _speech.cancel();
    _pulse.dispose();
    super.dispose();
  }

  /// Tagged log for the voice search flow. Filter the console/logcat by
  /// "[VoiceSearch]" to see only these lines.
  void _log(String message) {
    debugPrint('[VoiceSearch] $message');
  }

  Future<void> _startListening() async {
    _log('---------- start listening ----------');
    setState(() {
      _state = _VoiceState.listening;
      _words = '';
      _alternates = [];
      _message = '';
      _handled = false;
      _engineStarted = false;
    });

    bool available;
    try {
      _log('initialize() called');
      available = await _speech.initialize(
        debugLogging: true, // native speech_to_text logs in logcat
        onStatus: (status) {
          _log(
            'onStatus: "$status" (state=$_state, '
            'engineStarted=$_engineStarted, handled=$_handled)',
          );
          if (status == 'listening') _engineStarted = true;
          // Engine finished without a final result → treat what we have.
          // (_engineStarted ignores a late 'done' from the previous attempt.)
          if (status == 'done' &&
              _engineStarted &&
              _state == _VoiceState.listening) {
            _log('engine done without final result → handling "$_words"');
            _handleFinal();
          }
        },
        onError: (SpeechRecognitionError error) {
          _log(
            'onError: msg="${error.errorMsg}", '
            'permanent=${error.permanent}, state=$_state',
          );
          if (_state == _VoiceState.listening) _handleFinal();
        },
      );
      _log('initialize() result: available=$available');
    } catch (e, st) {
      _log('initialize() threw: $e\n$st');
      available = false;
    }

    if (!mounted) {
      _log('dialog closed during initialize → abort');
      return;
    }

    if (!available) {
      _log('speech NOT available → showing unavailable message');
      _showUnavailable();
      return;
    }

    try {
      final hasPermission = await _speech.hasPermission;
      final systemLocale = await _speech.systemLocale();
      final locales = await _speech.locales();
      final hasEnUs = locales.any(
        (l) => l.localeId.toLowerCase().replaceAll('_', '-') == 'en-us',
      );
      _log(
        'engine info: hasPermission=$hasPermission, '
        'systemLocale=${systemLocale?.localeId}, '
        'locales=${locales.length}, en-US supported=$hasEnUs',
      );
    } catch (e) {
      _log('could not read engine info: $e');
    }

    try {
      _log('listen() called (locale=en-US, listenFor=15s, pauseFor=3s)');
      await _speech.listen(
        localeId: 'en-US',
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        listenOptions: SpeechListenOptions(partialResults: true),
        onResult: (result) {
          _log(
            'onResult: "${result.recognizedWords}" '
            'final=${result.finalResult}, '
            'confidence=${result.confidence.toStringAsFixed(2)}, '
            'alternates=${result.alternates.map((a) => a.recognizedWords).toList()}',
          );
          if (!mounted) return;
          _alternates = result.alternates
              .map((a) => a.recognizedWords)
              .where((w) => w.trim().isNotEmpty)
              .toList();
          setState(() => _words = result.recognizedWords);
          if (result.finalResult) _handleFinal();
        },
      );
      _log('listen() started, isListening=${_speech.isListening}');
    } catch (e, st) {
      _log('listen() threw: $e\n$st');
      if (mounted) _showUnavailable();
    }
  }

  void _showUnavailable() {
    _handled = true;
    setState(() {
      _state = _VoiceState.error;
      _message =
          'Speech recognition is not available on this device. '
          'Make sure the Google app (speech services) is installed and '
          'microphone permission is allowed, then try again.';
    });
  }

  Future<void> _handleFinal() async {
    if (_handled || !mounted) {
      _log('_handleFinal skipped (handled=$_handled, mounted=$mounted)');
      return;
    }
    _handled = true;
    await _speech.stop();
    _log('stopped listening');

    final spoken = _words.trim();
    if (spoken.isEmpty) {
      _log('no words recognized → "Didn\'t catch that"');
      setState(() => _state = _VoiceState.notClear);
      return;
    }

    _log('searching business for "$spoken"');
    setState(() => _state = _VoiceState.searching);

    final controller = Get.find<CustomerController>();
    BusinessSearchResult result;
    try {
      result = await controller.searchBusinessByVoice(
        spoken,
        alternatives: _alternates,
      );
    } catch (e, st) {
      _log('search threw: $e\n$st');
      if (!mounted) return;
      setState(() {
        _state = _VoiceState.error;
        _message = 'Something went wrong while searching. Please try again.';
      });
      return;
    }

    _log(
      'search result: status=${result.status}, '
      'business=${result.business?.businessName} '
      '(id=${result.business?.businessId}), location=${result.location}',
    );

    if (!mounted) {
      _log('dialog closed during search → abort');
      return;
    }

    switch (result.status) {
      case BusinessSearchStatus.found:
        _log('opening map on ${result.location}');
        Navigator.of(context).pop();
        await controller.openBusinessOnMap(result.business!, result.location!);
        break;
      case BusinessSearchStatus.notFound:
        setState(() => _state = _VoiceState.notFound);
        break;
      case BusinessSearchStatus.noLocation:
        setState(() {
          _state = _VoiceState.noLocation;
          _message = result.business!.businessName;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 18),
            Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
            if (_words.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F7F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '"$_words"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _primary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final (IconData icon, Color color) = switch (_state) {
      _VoiceState.listening => (Icons.mic_rounded, _primary),
      _VoiceState.searching => (Icons.search_rounded, _primary),
      _VoiceState.notClear => (Icons.hearing_disabled_rounded, Colors.orange),
      _VoiceState.notFound => (Icons.store_mall_directory_outlined, Colors.redAccent),
      _VoiceState.noLocation => (Icons.location_off_outlined, Colors.redAccent),
      _VoiceState.error => (Icons.error_outline_rounded, Colors.redAccent),
    };

    final circle = Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: _state == _VoiceState.searching
          ? Padding(
              padding: const EdgeInsets.all(26),
              child: CircularProgressIndicator(color: color, strokeWidth: 3),
            )
          : Icon(icon, size: 42, color: color),
    );

    if (_state != _VoiceState.listening) return circle;
    return ScaleTransition(scale: _pulse, child: circle);
  }

  String get _title => switch (_state) {
        _VoiceState.listening => 'Listening...',
        _VoiceState.searching => 'Searching...',
        _VoiceState.notClear => "Didn't catch that",
        _VoiceState.notFound => 'Business not found',
        _VoiceState.noLocation => 'No location saved',
        _VoiceState.error => 'Something went wrong',
      };

  String get _subtitle => switch (_state) {
        _VoiceState.listening => 'Say the business name',
        _VoiceState.searching => 'Looking up the business and its location',
        _VoiceState.notClear =>
          'Your voice was not clear. Please try again and speak clearly.',
        _VoiceState.notFound =>
          'No business matches what you said. Try saying the name again.',
        _VoiceState.noLocation =>
          '"$_message" has no address, so it can\'t be shown on the map.',
        _VoiceState.error => _message,
      };

  Widget _buildActions() {
    if (_state == _VoiceState.searching) return const SizedBox.shrink();

    if (_state == _VoiceState.listening) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: _outlinedStyle,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleFinal,
              style: _filledStyle,
              child: const Text('Done'),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: _outlinedStyle,
            child: const Text('Close'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _startListening,
            style: _filledStyle,
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: const Text('Try again'),
          ),
        ),
      ],
    );
  }

  ButtonStyle get _filledStyle => ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );

  ButtonStyle get _outlinedStyle => OutlinedButton.styleFrom(
        foregroundColor: _primary,
        side: const BorderSide(color: _primary),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      );
}
