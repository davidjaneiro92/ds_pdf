package com.dsdevsolucoes.dspdf

import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "com.dsdevsolucoes.dspdf/content_resolver"
    private var channel: MethodChannel? = null

    /** URI de um PDF que outro app mandou abrir ("Abrir com") e que o lado
     *  Dart ainda não consumiu. */
    private var pdfPendente: Uri? = null

    // Lê bytes de URIs "content://" (ex.: páginas devolvidas pelo scanner de
    // documentos no Android) via ContentResolver nativo. O pacote Dart que
    // fazia isso antes (uri_to_file) travava indefinidamente em alguns
    // aparelhos reais — ver ScannerController/ContentUriReader.
    //
    // O mesmo canal serve o leitor de PDF: quando o app é aberto por outro
    // app com um PDF ("Abrir com"), `consumirPdfRecebido` copia o conteúdo
    // para o cache e devolve um caminho de arquivo real, porque o
    // visualizador precisa de um `File` — e a cópia é feita em stream, para
    // não carregar um PDF grande inteiro na memória.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pdfPendente = extrairPdfDoIntent(intent)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "readBytes" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString == null) {
                            result.error("ARGUMENT_ERROR", "URI não informada", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val bytes = contentResolver.openInputStream(Uri.parse(uriString))
                                ?.use { stream -> stream.readBytes() }
                            if (bytes != null) {
                                result.success(bytes)
                            } else {
                                result.error("EMPTY_STREAM", "Não foi possível abrir o conteúdo da URI", null)
                            }
                        } catch (e: Exception) {
                            result.error("READ_ERROR", e.message, null)
                        }
                    }

                    "consumirPdfRecebido" -> {
                        val uri = pdfPendente
                        pdfPendente = null
                        if (uri == null) {
                            result.success(null)
                            return@setMethodCallHandler
                        }
                        try {
                            result.success(copiarParaCache(uri))
                        } catch (e: Exception) {
                            result.error("COPY_ERROR", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
        }
    }

    // A activity é `singleTop`: com o app já aberto, um novo "Abrir com"
    // chega por aqui em vez de recriar a activity.
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val uri = extrairPdfDoIntent(intent) ?: return
        pdfPendente = uri
        channel?.invokeMethod("pdfRecebido", null)
    }

    @Suppress("DEPRECATION")
    private fun extrairPdfDoIntent(intent: Intent?): Uri? {
        if (intent == null) return null
        return when (intent.action) {
            Intent.ACTION_VIEW -> intent.data
            Intent.ACTION_SEND -> intent.getParcelableExtra(Intent.EXTRA_STREAM) as? Uri
            else -> null
        }
    }

    /** Copia o conteúdo da URI para um arquivo no cache do app e devolve o
     *  caminho. O nome original é preservado quando o provedor informa um. */
    private fun copiarParaCache(uri: Uri): String {
        val nome = nomeDoArquivo(uri) ?: "documento.pdf"
        val destino = File(cacheDir, "aberto_${System.currentTimeMillis()}_$nome")
        contentResolver.openInputStream(uri).use { entrada ->
            requireNotNull(entrada) { "Não foi possível abrir o PDF recebido" }
            destino.outputStream().use { saida -> entrada.copyTo(saida) }
        }
        return destino.absolutePath
    }

    private fun nomeDoArquivo(uri: Uri): String? {
        if (uri.scheme == "file") return uri.lastPathSegment
        return contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            val indice = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (indice >= 0 && cursor.moveToFirst()) cursor.getString(indice) else null
        }
    }
}
