package com.example.safeseiz

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.pytorch.IValue
import org.pytorch.LiteModuleLoader
import org.pytorch.Module
import org.pytorch.Tensor
import java.io.File
import java.io.FileOutputStream

class InferencePlugin(private val context: Context) :
    MethodChannel.MethodCallHandler {

    private var model: Module? = null

    companion object {
        const val CHANNEL = "com.example.safeseiz/inference"
        const val TAG     = "InferencePlugin"
    }

    fun loadModel() {
        try {
            Log.d(TAG, "Starting model load...")

            // List what's in flutter_assets/assets
            val assetsList = context.assets.list("flutter_assets/assets") ?: emptyArray()
            Log.d(TAG, "flutter_assets/assets contents: ${assetsList.toList()}")

            val modelFile = assetFilePath("safeseiz_model.ptl")
            model = LiteModuleLoader.load(modelFile)
            Log.d(TAG, "Model loaded successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load model: ${e.message}")
            e.printStackTrace()
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "runInference" -> {
                try {
                    val sequence = call.argument<List<List<List<Double>>>>("sequence")
                        ?: return result.error("INVALID_ARGS", "sequence is null", null)
                    val prediction = runInference(sequence)
                    result.success(prediction)
                } catch (e: Exception) {
                    Log.e(TAG, "Inference error: ${e.message}")
                    result.error("INFERENCE_ERROR", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun runInference(sequence: List<List<List<Double>>>): Int {
        val seqLen        = sequence.size
        val channels      = sequence[0].size
        val windowSamples = sequence[0][0].size

        val floatArray = FloatArray(1 * seqLen * channels * windowSamples)
        var idx = 0
        for (w in 0 until seqLen) {
            for (c in 0 until channels) {
                for (s in 0 until windowSamples) {
                    floatArray[idx++] = sequence[w][c][s].toFloat()
                }
            }
        }

        val inputTensor = Tensor.fromBlob(
            floatArray,
            longArrayOf(1, seqLen.toLong(), channels.toLong(), windowSamples.toLong())
        )

        val output = model!!.forward(IValue.from(inputTensor)).toTensor()
        val scores = output.dataAsFloatArray

        return scores.indices.maxByOrNull { scores[it] } ?: 0
    }

    private fun assetFilePath(assetName: String): String {
        val file = File(context.filesDir, assetName)

        // Force delete old file to ensure fresh copy
        if (file.exists()) {
            file.delete()
            Log.d(TAG, "Deleted old cached file: $assetName")
        }

        try {
            context.assets.open("flutter_assets/assets/$assetName").use { input ->
                FileOutputStream(file).use { output ->
                    input.copyTo(output)
                }
            }
            Log.d(TAG, "Asset copied successfully: $assetName")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to copy asset $assetName: ${e.message}")
            throw e
        }

        return file.absolutePath
    }
}