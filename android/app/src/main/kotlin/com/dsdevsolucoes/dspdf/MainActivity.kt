package com.dsdevsolucoes.dspdf

import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.dsdevsolucoes.dspdf/content_resolver"

    // Lê bytes de URIs "content://" (ex.: páginas devolvidas pelo scanner de
    // documentos no Android) via ContentResolver nativo. O pacote Dart que
    // fazia isso antes (uri_to_file) travava indefinidamente em alguns
    // aparelhos reais — ver ScannerController/ContentUriReader.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "readBytes") {
                    val uriString = call.argument<String>("uri")
                    if (uriString == null) {
                        result.error("ARGUMENT_ERROR", "URI não informada", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val bytes = contentResolver.openInputStream(Uri.parse(uriString))
                            ?.use { it.readBytes() }
                        if (bytes != null) {
                            result.success(bytes)
                        } else {
                            result.error("EMPTY_STREAM", "Não foi possível abrir o conteúdo da URI", null)
                        }
                    } catch (e: Exception) {
                        result.error("READ_ERROR", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
