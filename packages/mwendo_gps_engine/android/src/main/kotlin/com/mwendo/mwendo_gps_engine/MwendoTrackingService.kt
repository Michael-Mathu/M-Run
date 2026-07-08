package com.mwendo.mwendo_gps_engine

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.location.Location
import android.os.Binder
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.ServiceCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import java.util.UUID

/**
 * Foreground service that owns the GPS subscription so a run keeps recording
 * after the app is backgrounded or the screen is locked. The plugin binds to
 * this service and forwards location updates to Flutter via the EventChannel.
 */
class MwendoTrackingService : Service() {

    interface LocationListener {
        fun onLocation(point: Map<String, Any?>)
    }

    private val binder = LocalBinder()
    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private var locationCallback: LocationCallback? = null
    private var listener: LocationListener? = null

    var activityId = ""
    private var distanceM = 0.0
    private var movingTimeMs = 0L
    private var startTime = 0L
    private var lastLat = 0.0
    private var lastLng = 0.0
    private var lastTime = 0L

    inner class LocalBinder : Binder() {
        fun getService(): MwendoTrackingService = this@MwendoTrackingService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startInForeground()
        return START_STICKY
    }

    fun start(profile: String) {
        activityId = UUID.randomUUID().toString()
        distanceM = 0.0
        movingTimeMs = 0
        startTime = System.currentTimeMillis()
        lastTime = startTime

        val interval = when (profile) {
            "powerSaver" -> 20000L
            "ultraSaver" -> 30000L
            else -> 5000L
        }
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                for (loc in result.locations) processLocation(loc)
            }
        }
        val request = LocationRequest.Builder(interval).apply {
            setPriority(Priority.PRIORITY_HIGH_ACCURACY)
            setWaitForAccurateLocation(false)
        }.build()
        fusedLocationClient.requestLocationUpdates(
            request,
            ContextCompat.getMainExecutor(this),
            locationCallback!!,
        )
    }

    fun resume() {
        val request = LocationRequest.Builder(5000L)
            .setPriority(Priority.PRIORITY_HIGH_ACCURACY)
            .build()
        locationCallback?.let {
            fusedLocationClient.requestLocationUpdates(
                request,
                ContextCompat.getMainExecutor(this),
                it,
            )
        }
    }

    fun pause() {
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
    }

    fun stop(): Map<String, Any?> {
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
        val duration = (System.currentTimeMillis() - startTime).toInt()
        return mapOf(
            "activity_id" to activityId,
            "distance_m" to distanceM,
            "duration_ms" to duration,
            "moving_time_ms" to movingTimeMs,
        )
    }

    fun setListener(l: LocationListener?) {
        listener = l
    }

    private fun processLocation(location: Location) {
        val speedMps = location.speed.toDouble()
        val state = classifyState(speedMps)
        if (lastLat != 0.0 && lastLng != 0.0) {
            val d = FloatArray(1)
            Location.distanceBetween(lastLat, lastLng, location.latitude, location.longitude, d)
            distanceM += d[0]
            if (state == "run" || state == "walk") {
                movingTimeMs += (location.time - lastTime)
            }
        }
        lastLat = location.latitude
        lastLng = location.longitude
        lastTime = location.time
        listener?.onLocation(
            mapOf(
                "lat" to location.latitude,
                "lng" to location.longitude,
                "elevation" to location.altitude,
                "timestamp" to location.time,
                "speed_mps" to speedMps,
                "accuracy" to location.accuracy,
                "state" to state,
            ),
        )
    }

    private fun classifyState(speed: Double): String = when {
        speed < 0.8 -> "idle"
        speed < 5.0 -> "walk"
        else -> "run"
    }

    private fun startInForeground() {
        val channelId = "mwendo_tracking"
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Run tracking",
                NotificationManager.IMPORTANCE_LOW,
            )
            channel.setShowBadge(false)
            manager.createNotificationChannel(channel)
        }
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val contentIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Mwendo is tracking your run")
            .setContentText("Your location is recorded in the background.")
            .setSmallIcon(R.drawable.ic_run_notification)
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                ServiceCompat.startForeground(
                    this,
                    1,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION,
                )
            } else {
                startForeground(1, notification)
            }
        } catch (e: SecurityException) {
            // Notification permission denied or background location policy restriction
            e.printStackTrace()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        locationCallback?.let { fusedLocationClient.removeLocationUpdates(it) }
        super.onDestroy()
    }
}
