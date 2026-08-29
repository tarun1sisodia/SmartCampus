// =============================================================
// qr_scanner_screen.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/views/qr_scanner_screen.dart)
// =============================================================

// class QrScannerScreen :
//   MobileScanner controller + _isProcessing flag

// _onDetect(BarcodeCapture) :
//   if _isProcessing -> ignore (one scan at a time)
//   take first barcode rawValue; expected format 'sessionId:token'
//   split by ':' -> exactly 2 parts -> set _isProcessing, dispatch QrCodeScanned(sessionId, token)
//   wrong format -> ignore silently

// _showResultDialog(success, message) :
//   non-dismissible dialog with check/error icon
//   OK -> success : pop twice (dialog + scanner back to dashboard)
//         failure : pop dialog, _isProcessing = false, controller.start() -> allow re-scan

// build :
//   BlocProvider QrScannerBloc (factory)
//   BlocListener -> on Success/Failure show the result dialog
//   UI: full screen camera preview + scan overlay + torch toggle
