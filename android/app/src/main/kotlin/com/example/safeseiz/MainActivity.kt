package com.example.safeseiz
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.telephony.SmsManager
import android.telephony.SubscriptionManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SMS_CHANNEL = "com.example.safeseiz/sms"
    private val WATCH_EVENT_CHANNEL = "com.example.safeseiz/watch_events"

    private var watchEventSink: EventChannel.EventSink? = null
    private var watchBroadcastReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ─── SMS Channel ───────────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "sendSMS") {
                    val phones = call.argument<List<String>>("phones")
                    val message = call.argument<String>("message")
                    val locationMessage = call.argument<String?>("locationMessage")

                    android.util.Log.d("SMS_DEBUG", "Received ${phones?.size} phones: $phones")
                    android.util.Log.d("SMS_DEBUG", "Message length: ${message?.length}, content: $message")

                    if (phones == null || message == null) {
                        result.error("INVALID_ARGS", "phones or message is null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        // FIX 1: Proper SmsManager instantiation for all Android versions
                        // Android 10 = SDK 29, so we handle subscription ID carefully
                        val smsManager: SmsManager = if (android.os.Build.VERSION.SDK_INT >= 31) {
                            applicationContext.getSystemService(SmsManager::class.java)
                        } else {
                            val subscriptionId = SubscriptionManager.getDefaultSmsSubscriptionId()
                            if (subscriptionId != SubscriptionManager.INVALID_SUBSCRIPTION_ID) {
                                android.util.Log.d("SMS_DEBUG", "Using subscription ID: $subscriptionId")
                                @Suppress("DEPRECATION")
                                SmsManager.getSmsManagerForSubscriptionId(subscriptionId)
                            } else {
                                android.util.Log.w("SMS_DEBUG", "Invalid subscription ID, falling back to default")
                                @Suppress("DEPRECATION")
                                SmsManager.getDefault()
                            }
                        }

                        val failures = mutableListOf<String>()

                        for (phone in phones) {
                            try {
                                // FIX 2: Clean the phone number — strip whitespace/newlines
                                val cleanPhone = phone.trim()
                                android.util.Log.d("SMS_DEBUG", "Sending to: '$cleanPhone'")

                                val sentIntent = PendingIntent.getBroadcast(
                                    applicationContext,
                                    cleanPhone.hashCode(),
                                    Intent("SMS_SENT_$cleanPhone"),
                                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                                )
                                val deliveryIntent = PendingIntent.getBroadcast(
                                    applicationContext,
                                    cleanPhone.hashCode() + 1,
                                    Intent("SMS_DELIVERED_$cleanPhone"),
                                    PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
                                )

                                registerReceiver(
                                    object : BroadcastReceiver() {
                                        override fun onReceive(ctx: Context?, intent: Intent?) {
                                            when (resultCode) {
                                                Activity.RESULT_OK ->
                                                    android.util.Log.d("SMS_DEBUG", "SENT OK to $cleanPhone")
                                                SmsManager.RESULT_ERROR_GENERIC_FAILURE ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - Generic error to $cleanPhone")
                                                SmsManager.RESULT_ERROR_NO_SERVICE ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - No service to $cleanPhone")
                                                SmsManager.RESULT_ERROR_NULL_PDU ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - Null PDU to $cleanPhone")
                                                SmsManager.RESULT_ERROR_RADIO_OFF ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - Radio off to $cleanPhone")
                                                else ->
                                                    android.util.Log.e("SMS_DEBUG", "SENT FAILED - Unknown error $resultCode to $cleanPhone")
                                            }
                                            try { ctx?.unregisterReceiver(this) } catch (_: Exception) {}
                                        }
                                    },
                                    IntentFilter("SMS_SENT_$cleanPhone"),
                                    Context.RECEIVER_NOT_EXPORTED
                                )

                                registerReceiver(
                                    object : BroadcastReceiver() {
                                        override fun onReceive(ctx: Context?, intent: Intent?) {
                                            when (resultCode) {
                                                Activity.RESULT_OK ->
                                                    android.util.Log.d("SMS_DEBUG", "DELIVERED OK to $cleanPhone")
                                                else ->
                                                    android.util.Log.e("SMS_DEBUG", "DELIVERY FAILED to $cleanPhone, code: $resultCode")
                                            }
                                            try { ctx?.unregisterReceiver(this) } catch (_: Exception) {}
                                        }
                                    },
                                    IntentFilter("SMS_DELIVERED_$cleanPhone"),
                                    Context.RECEIVER_NOT_EXPORTED
                                )

                                // FIX 3: Clean the message — strip trailing newlines/whitespace
                                val cleanMessage = message.trim()
                                android.util.Log.d("SMS_DEBUG", "Calling sendTextMessage to $cleanPhone")

                                // FIX 4: Proper multipart handling with intents for ALL parts
                                val parts = smsManager.divideMessage(cleanMessage)
                                android.util.Log.d("SMS_DEBUG", "Message split into ${parts.size} part(s)")

                                if (parts.size == 1) {
                                    smsManager.sendTextMessage(cleanPhone, null, cleanMessage, sentIntent, deliveryIntent)
                                } else {
                                    // Pass proper PendingIntent lists so multipart messages
                                    // are tracked and don't silently fail
                                    val sentIntents = ArrayList<PendingIntent>(parts.size)
                                    val deliveryIntents = ArrayList<PendingIntent>(parts.size)
                                    repeat(parts.size) {
                                        sentIntents.add(sentIntent)
                                        deliveryIntents.add(deliveryIntent)
                                    }
                                    smsManager.sendMultipartTextMessage(
                                        cleanPhone, null, parts, sentIntents, deliveryIntents
                                    )
                                }
                                android.util.Log.d("SMS_DEBUG", "sendTextMessage called for $cleanPhone")

                                if (phones.indexOf(phone) < phones.size - 1) {
                                    Thread.sleep(1500) // wait 1.5s before sending to next recipient
                                }

                            } catch (e: Exception) {
                                android.util.Log.e("SMS_DEBUG", "Exception sending to $phone: ${e.message}")
                                failures.add(phone)
                            }
                        }

                        if (failures.isEmpty()) result.success(true)
                        else result.error("PARTIAL_FAILURE", "Failed for: $failures", null)

                    } catch (e: Exception) {
                        android.util.Log.e("SMS_DEBUG", "Top-level SMS error: ${e.message}")
                        result.error("SMS_ERROR", e.message, null)
                    }
                }
            }

        // ─── Watch Event Channel ────────────────────────────────────────
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, WATCH_EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    watchEventSink = events
                    registerWatchReceiver()
                }
                override fun onCancel(arguments: Any?) {
                    watchEventSink = null
                    unregisterWatchReceiver()
                }
            })
    }

    private fun registerWatchReceiver() {
        watchBroadcastReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    WearableService.ACTION_SENSOR_DATA -> {
                        val data = mapOf(
                            "type" to "sensor_data",
                            "hr" to (intent.getStringExtra("hr") ?: ""),
                            "spo2" to (intent.getStringExtra("spo2") ?: ""),
                            "accel_x" to (intent.getStringExtra("accel_x") ?: ""),
                            "accel_y" to (intent.getStringExtra("accel_y") ?: ""),
                            "accel_z" to (intent.getStringExtra("accel_z") ?: ""),
                            "gyro_x" to (intent.getStringExtra("gyro_x") ?: ""),
                            "gyro_y" to (intent.getStringExtra("gyro_y") ?: ""),
                            "gyro_z" to (intent.getStringExtra("gyro_z") ?: ""),
                            "timestamp" to intent.getLongExtra("timestamp", 0L).toString()
                        )
                        watchEventSink?.success(data)
                    }
                    WearableService.ACTION_SOS -> {
                        watchEventSink?.success(mapOf("type" to "sos"))
                    }
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(WearableService.ACTION_SENSOR_DATA)
            addAction(WearableService.ACTION_SOS)
        }
        registerReceiver(watchBroadcastReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
    }

    private fun unregisterWatchReceiver() {
        watchBroadcastReceiver?.let {
            try { unregisterReceiver(it) } catch (_: Exception) {}
        }
        watchBroadcastReceiver = null
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterWatchReceiver()
    }
}