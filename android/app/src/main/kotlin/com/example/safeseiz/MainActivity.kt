package com.example.safeseiz

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.safeseiz/sms"
    private val CHANNEL = "com.example.safeseiz/smartwatch"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "sendSMS") {
                    val phones = call.argument<List<String>>("phones")
                    val message = call.argument<String>("message")

                    android.util.Log.d("SMS_DEBUG", "Received ${phones?.size} phones: $phones")

                    if (phones == null || message == null) {
                        result.error("INVALID_ARGS", "phones or message is null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val smsManager = if (android.os.Build.VERSION.SDK_INT >= 31)
                            applicationContext.getSystemService(SmsManager::class.java)
                        else {
                            val subscriptionId = android.telephony.SubscriptionManager.getDefaultSmsSubscriptionId()
                            @Suppress("DEPRECATION")
                            SmsManager.getSmsManagerForSubscriptionId(subscriptionId)
                        }

                        val failures = mutableListOf<String>()

                        for (phone in phones) {
                            try {
                                val sentIntent = PendingIntent.getBroadcast(
                                    applicationContext,
                                    phone.hashCode(),
                                    Intent("SMS_SENT_$phone"),
                                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                                )

                                val deliveryIntent = PendingIntent.getBroadcast(
                                    applicationContext,
                                    phone.hashCode() + 1,
                                    Intent("SMS_DELIVERED_$phone"),
                                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                                )

                                // Register sent receiver
                                registerReceiver(
                                    object : BroadcastReceiver() {
                                        override fun onReceive(ctx: Context?, intent: Intent?) {
                                            when (resultCode) {
                                                android.app.Activity.RESULT_OK ->
                                                    android.util.Log.d("SMS_DEBUG", "SENT OK to $phone")
                                                android.telephony.SmsManager.RESULT_ERROR_GENERIC_FAILURE ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - Generic error to $phone")
                                                android.telephony.SmsManager.RESULT_ERROR_NO_SERVICE ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - No service to $phone")
                                                android.telephony.SmsManager.RESULT_ERROR_NULL_PDU ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - Null PDU to $phone")
                                                android.telephony.SmsManager.RESULT_ERROR_RADIO_OFF ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - Radio off to $phone")
                                                else ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - Unknown error $resultCode to $phone")
                                            }
                                            ctx?.unregisterReceiver(this)
                                        }
                                    },
                                    IntentFilter("SMS_SENT_$phone"),
                                    Context.RECEIVER_NOT_EXPORTED  // ← inside the call
                                )

                                // Register delivery receiver
                                registerReceiver(
                                    object : BroadcastReceiver() {
                                        override fun onReceive(ctx: Context?, intent: Intent?) {
                                            when (resultCode) {
                                                android.app.Activity.RESULT_OK ->
                                                    android.util.Log.d("SMS_DEBUG", "DELIVERED OK to $phone")
                                                else ->
                                                    android.util.Log.e("SMS_DEBUG", "DELIVERY FAILED to $phone, code: $resultCode")
                                            }
                                            ctx?.unregisterReceiver(this)
                                        }
                                    },
                                    IntentFilter("SMS_DELIVERED_$phone"),
                                    Context.RECEIVER_NOT_EXPORTED  // ← inside the call
                                )

                                android.util.Log.d("SMS_DEBUG", "Calling sendTextMessage to $phone")
                                val parts = smsManager.divideMessage(message)
                                if (parts.size == 1) {
                                    smsManager.sendTextMessage(phone, null, message, sentIntent, deliveryIntent)
                                } else {
                                    smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
                                }
                                android.util.Log.d("SMS_DEBUG", "sendTextMessage called for $phone")

                            } catch (e: Exception) {
                                android.util.Log.e("SMS_DEBUG", "Exception sending to $phone: ${e.message}")
                                failures.add(phone)
                            }
                        }

                        if (failures.isEmpty()) result.success(true)
                        else result.error("PARTIAL_FAILURE", "Failed for: $failures", null)

                    } catch (e: Exception) {
                        result.error("SMS_ERROR", e.message, null)
                    }
                }
            }
    }
}