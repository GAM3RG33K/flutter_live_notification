package dev.harshjoshi.flutter_live_notification

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry


/** FlutterLiveNotificationPlugin */
class FlutterLiveNotificationPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.ActivityResultListener {


    companion object {
        const val CHANNEL_ID_SUFFIX = "live_notification_channel"
        const val NOTIFICATION_ID = 1001
        const val NOTIFICATION_PERMISSION_REQUEST_CODE: Int = 100
    }

    private lateinit var channelIdPrefix: String
    private var defaultIcon: Int = 0
    private lateinit var notificationHelper: NotificationHelper

    private fun getChannelId(): String {
        return channelIdPrefix + CHANNEL_ID_SUFFIX
    }


    private fun getChannelName(): String {
        return channelIdPrefix.uppercase()
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext;
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_live_notification")
        channel.setMethodCallHandler(this)

        notificationHelper = NotificationHelper()
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // DO NOTHING
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // DO NOTHING
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "initialize" -> {
                val appIdPrefix: String? = call.argument("appIdPrefix")
                val androidDefaultIcon: String? = call.argument("androidDefaultIcon")

                if (appIdPrefix == null || androidDefaultIcon == null) {
                    result.error(
                        "INCORRECT PARAMETERS",
                        "Please provide appIdPrefix & androidDefaultIcon",
                        null
                    )
                    return
                }

                channelIdPrefix = appIdPrefix
                defaultIcon = getIconRes(context, androidDefaultIcon)

                if (activity != null) {
                    notificationHelper.ensureNotificationPermission(
                        activity!!,
                        NOTIFICATION_PERMISSION_REQUEST_CODE
                    )

                }
                val isChannelCreated = notificationHelper.initialize(
                    context,
                    getChannelId(),
                    getChannelName(),
                )
                result.success(isChannelCreated)
            }

            "dispose" -> {
                notificationHelper.dispose()
                result.success(true)
            }

            "createLiveNotification" -> {
                val title: String? = call.argument("title")
                val content: String? = call.argument("message")

                if (title == null || content == null) {
                    result.error("INCORRECT PARAMETERS", "Please provide title & content", null)
                    return
                }

                val id = notificationHelper.createNotification(
                    context,
                    getChannelId(),
                    NOTIFICATION_ID,
                    defaultIcon,
                    title,
                    content
                )
                result.success(id)
            }

            "updateLiveNotification" -> {
                val title: String? = call.argument("title")
                val content: String? = call.argument("message")

                if (title == null || content == null) {
                    result.error("INCORRECT PARAMETERS", "Please provide title & content", null)
                    return
                }


                val id = notificationHelper.updateNotification(
                    context,
                    getChannelId(),
                    NOTIFICATION_ID,
                    defaultIcon,
                    title,
                    content
                )
                result.success(id)
            }

            "dismiss" -> {
                notificationHelper.dismiss(NOTIFICATION_ID)
                result.success(null)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    @SuppressLint("DiscouragedApi")
    fun getIconRes(context: Context, androidDefaultIcon: String): Int {
        val drawableRes =
            context.resources.getIdentifier(androidDefaultIcon, "drawable", context.packageName)
        val mipmapRes =
            context.resources.getIdentifier(androidDefaultIcon, "mipmap", context.packageName)

        return if (mipmapRes != 0) mipmapRes else drawableRes
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
            val granted =
                resultCode == PackageManager.PERMISSION_GRANTED
            return granted
        }

        return false
    }

}
