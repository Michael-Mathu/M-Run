package com.mwendo.mwendo_gps_engine

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class MwendoGpsEnginePlugin : FlutterPlugin, MethodChannel.MethodCallHandler,
    MwendoTrackingService.LocationListener {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var context: Context
    private var service: MwendoTrackingService? = null
    private var bound = false
    private var pendingStartResult: Result? = null
    private var pendingProfile: String = "standard"

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
            val svc = (binder as MwendoTrackingService.LocalBinder).getService()
            service = svc
            bound = true
            svc.setListener(this@MwendoGpsEnginePlugin)
            svc.start(pendingProfile)
            pendingStartResult?.success(mapOf("activity_id" to svc.activityId))
            pendingStartResult = null
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            service = null
            bound = false
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "mwendo_gps_engine")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "mwendo_gps_engine/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startRecording" -> {
                pendingProfile = call.argument<String>("profile") ?: "standard"
                startService(result)
            }
            "pause" -> {
                service?.pause()
                result.success(null)
            }
            "resume" -> {
                service?.resume()
                result.success(null)
            }
            "stop" -> {
                val summary = service?.stop() ?: mapOf(
                    "activity_id" to "",
                    "distance_m" to 0.0,
                    "duration_ms" to 0,
                    "moving_time_ms" to 0,
                )
                stopService()
                result.success(summary)
            }
            else -> result.notImplemented()
        }
    }

    private fun startService(result: Result) {
        pendingStartResult = result
        val intent = Intent(context, MwendoTrackingService::class.java)
        ContextCompat.startForegroundService(context, intent)
        // ponytail: binding is async; the activity_id is emitted from
        // onServiceConnected once the location subscription has started.
        if (!bound) {
            context.bindService(intent, connection, Context.BIND_AUTO_CREATE)
        } else {
            service?.let {
                it.start(pendingProfile)
                pendingStartResult?.success(mapOf("activity_id" to it.activityId))
                pendingStartResult = null
            }
        }
    }

    private fun stopService() {
        service?.setListener(null)
        if (bound) {
            try {
                context.unbindService(connection)
            } catch (_: Exception) {
                // already unbound
            }
            bound = false
        }
        context.stopService(Intent(context, MwendoTrackingService::class.java))
        service = null
    }

    override fun onLocation(point: Map<String, Any?>) {
        eventSink?.success(point)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Do not stop the foreground service here: it must survive a transient
        // Flutter engine detach so a background run keeps recording. It is torn
        // down only by an explicit `stop()` from Dart.
        eventSink = null
    }
}
