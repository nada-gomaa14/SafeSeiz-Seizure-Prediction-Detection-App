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
        const val ACTION_SENSOR_DATA = "com.example.safeseiz.SENSOR_DATA"
        const val ACTION_SOS         = "com.example.safeseiz.SOS"
        const val ACTION_BUFFERED_DATA = "com.example.safeseiz.BUFFERED_DATA"
    }

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        for (event in dataEvents) {
            if (event.type != DataEvent.TYPE_CHANGED) continue

            when (event.dataItem.uri.path) {

                "/safeseiz/sensor_data" -> {
                    val dataMap = DataMapItem.fromDataItem(event.dataItem).dataMap
                    Log.d("WearableService", "Sensor data received from watch")

                    val intent = Intent(ACTION_SENSOR_DATA).apply {
                        putExtra("hr",        dataMap.getString("hr",      ""))
                        putExtra("spo2",      dataMap.getString("spo2",    ""))
                        putExtra("accel_x",   dataMap.getString("accel_x", ""))
                        putExtra("accel_y",   dataMap.getString("accel_y", ""))
                        putExtra("accel_z",   dataMap.getString("accel_z", ""))
                        putExtra("gyro_x",    dataMap.getString("gyro_x",  ""))
                        putExtra("gyro_y",    dataMap.getString("gyro_y",  ""))
                        putExtra("gyro_z",    dataMap.getString("gyro_z",  ""))
                        putExtra("ppg",       dataMap.getString("ppg",     ""))
                        putExtra("rri",       dataMap.getString("rri",     ""))
                        putExtra("timestamp", dataMap.getString("timestamp", ""))
                    }
                    sendBroadcast(intent)
                }

                "/safeseiz/buffered_data" -> {
                    val dataMap = DataMapItem.fromDataItem(event.dataItem).dataMap
                    val readings = dataMap.getStringArrayList("readings") ?: return
                    Log.d("WearableService", "Buffered data received: ${readings.size} readings")

                    val intent = Intent(ACTION_BUFFERED_DATA).apply {
                        putStringArrayListExtra("readings", readings)
                    }
                    sendBroadcast(intent)
                }
            }
        }
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        if (messageEvent.path == "/safeseiz/sos") {
            Log.d("WearableService", "SOS received from watch!")
            sendBroadcast(Intent(ACTION_SOS))
        }
    }
}