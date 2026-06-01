package com.example.safeseiz

import android.content.Intent
import android.util.Log
import com.google.android.gms.wearable.DataEvent
import com.google.android.gms.wearable.DataEventBuffer
import com.google.android.gms.wearable.DataMapItem
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService

class WearableService : WearableListenerService() {

    companion object {
        private const val TAG = "SafeSeiz_WearService"
        const val ACTION_SENSOR_DATA = "com.example.safeseiz.SENSOR_DATA"
        const val ACTION_SOS = "com.example.safeseiz.SOS"
    }

    // Called when sensor data arrives from watch (every 5 seconds)
    override fun onDataChanged(dataEvents: DataEventBuffer) {
        Log.d(TAG, "onDataChanged fired — ${dataEvents.count} events")
        for (event in dataEvents) {
            if (event.type == DataEvent.TYPE_CHANGED &&
                event.dataItem.uri.path == "/safeseiz/sensor_data"
            ) {
                val dataMap = DataMapItem.fromDataItem(event.dataItem).dataMap

                val hr = dataMap.getString("hr", "")
                val spo2 = dataMap.getString("spo2", "")
                val accelX = dataMap.getString("accel_x", "")
                val accelY = dataMap.getString("accel_y", "")
                val accelZ = dataMap.getString("accel_z", "")
                val gyroX = dataMap.getString("gyro_x", "")
                val gyroY = dataMap.getString("gyro_y", "")
                val gyroZ = dataMap.getString("gyro_z", "")
                val timestamp = dataMap.getLong("timestamp", 0L)

                Log.d(TAG, "Sensor data received — HR:$hr SpO2:$spo2 Accel:[$accelX,$accelY,$accelZ] Gyro:[$gyroX,$gyroY,$gyroZ]")

                // Broadcast to Flutter via local broadcast
                val intent = Intent(ACTION_SENSOR_DATA).apply {
                    putExtra("hr", hr)
                    putExtra("spo2", spo2)
                    putExtra("accel_x", accelX)
                    putExtra("accel_y", accelY)
                    putExtra("accel_z", accelZ)
                    putExtra("gyro_x", gyroX)
                    putExtra("gyro_y", gyroY)
                    putExtra("gyro_z", gyroZ)
                    putExtra("timestamp", timestamp)
                }
                sendBroadcast(intent)
            }
        }
    }

    // Called when SOS signal arrives from watch
    override fun onMessageReceived(messageEvent: MessageEvent) {
        if (messageEvent.path == "/safeseiz/sos") {
            Log.d(TAG, "SOS signal received from watch")
            val intent = Intent(ACTION_SOS)
            sendBroadcast(intent)
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "WearableService created")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "WearableService destroyed")
    }
}