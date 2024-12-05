package dev.harshjoshi.flutter_live_notification

import android.Manifest
import android.app.Activity
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.os.Build
import android.provider.Settings
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat


class NotificationHelper {
    private var notificationManager: NotificationManager? = null

    fun initialize(context: Context, channelId: String, channelName: String): Boolean {
        if (notificationManager == null) {
            notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val isChannelCreated = createNotificationChannel(channelId, channelName)
            return isChannelCreated
        }
        return false
    }

    fun dispose() {
        if (notificationManager == null) {
            return
        }

        notificationManager!!.cancelAll()
        notificationManager = null
    }

    private fun createNotificationChannel(channelId: String, channelName: String): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mainChannel = buildChannelWithData(channelId, channelName)
            notificationManager!!.createNotificationChannel(mainChannel)

            // Create a channel with sound
            val soundChannel = buildChannelWithData(channelId, channelName, withSound = true)
            notificationManager!!.createNotificationChannel(soundChannel)

            return true
        } else {
            return false
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun buildChannelWithData(
        channelId: String,
        channelName: String,
        withSound: Boolean = false,
//        withVibrate: Boolean = false
    ): NotificationChannel {

        val id = getChannelIdForConfig(withSound, channelId)
        val channel = NotificationChannel(
            id,
            channelName,
            NotificationManager.IMPORTANCE_DEFAULT
        )
        channel.description = "$channelName live notifications channel"
        if (!withSound) {
            channel.setSound(null, null)
//            channel.enableVibration(false)
            channel.description = "$channelName live notifications silent channel"
        } else {
//            if (withSound) {
            val soundUri = Settings.System.DEFAULT_NOTIFICATION_URI
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()
            channel.setSound(soundUri, audioAttributes)
//            }
//            if (withVibrate) {
//                channel.enableVibration(true)
//                channel.setVibrationPattern(longArrayOf(0, 500, 250, 500))
//            }
        }

        return channel
    }

    private fun getChannelIdForConfig(
        withSound: Boolean,
        channelId: String
    ): String {
        val id = if (!withSound) "$channelId-silent" else channelId
        return id
    }

    private fun buildNotification(
        context: Context,
        channelId: String,
        iconResId: Int,
        title: String,
        content: String,
        withSound: Boolean = false,
    ): Notification? {
        val id = getChannelIdForConfig(withSound, channelId)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val builder = Notification.Builder(context, id)
                .setContentTitle(title)
                .setContentText(content)
                .setSmallIcon(iconResId)

            return builder.build()
        } else {
            // DO NOTHING
            null
        }
    }


    fun createNotification(
        context: Context,
        channelId: String,
        notificationId: Int,
        iconResId: Int,
        title: String,
        content: String
    ): Int? {
        val notification: Notification =
            buildNotification(context, channelId, iconResId, title, content, withSound = true)
                ?: return null;

        notificationManager!!.notify(notificationId, notification)
        return notificationId
    }

    fun updateNotification(
        context: Context,
        channelId: String,
        notificationId: Int,
        iconResId: Int,
        title: String,
        content: String
    ): Int? {
        val notification: Notification =
            buildNotification(context, channelId, iconResId, title, content)
                ?: return null;
        notificationManager!!.notify(notificationId, notification)
        return notificationId
    }

    fun dismiss(notificationId: Int) {
        if (notificationManager != null) {
            notificationManager!!.cancel(notificationId)
        }
    }

    fun ensureNotificationPermission(activity: Activity, requestCode: Int): Unit? {
        val hasPermissionError = checkNotificationPermission(activity.applicationContext)
        return if (hasPermissionError == null) {
            null
        } else {
            requestNotificationPermission(activity, requestCode)
        }

    }

    private fun checkNotificationPermission(context: Context): Array<String>? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS)
                == PackageManager.PERMISSION_GRANTED
            ) {
                null
            } else {
                arrayOf(
                    "PERMISSION_DENIED",
                    "Notification permission must be requested from the app."
                )
            }
        } else {
            null
        }
    }

    private fun requestNotificationPermission(activity: Activity, requestCode: Int): Unit? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                requestCode,
            )
        } else {
            null
        }
    }

}