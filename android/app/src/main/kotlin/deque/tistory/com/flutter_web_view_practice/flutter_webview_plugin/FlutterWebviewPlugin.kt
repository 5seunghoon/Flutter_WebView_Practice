package deque.tistory.com.flutter_web_view_practice.flutter_webview_plugin


import android.app.Activity
import android.content.Context
import android.content.Intent
import android.graphics.Point
import android.os.Build
import android.util.Log
import android.view.Display
import android.webkit.CookieManager
import android.webkit.ValueCallback
import android.widget.FrameLayout

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry
import io.flutter.view.FlutterView

/**
 * FlutterWebviewPlugin
 */
class FlutterWebviewPlugin private constructor(private val activity: Activity, private val context: Context) : MethodCallHandler, PluginRegistry.ActivityResultListener {
    private var webViewManager: WebviewManager? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "capture" -> captureWebview(call, result)
            "launch" -> openUrl(call, result)
            "close" -> close(call, result)
            "eval" -> eval(call, result)
            "resize" -> resize(call, result)
            "reload" -> reload(call, result)
            "back" -> back(call, result)
            "forward" -> forward(call, result)
            "hide" -> hide(call, result)
            "show" -> show(call, result)
            "reloadUrl" -> reloadUrl(call, result)
            "stopLoading" -> stopLoading(call, result)
            "cleanCookies" -> cleanCookies(call, result)
            else -> result.notImplemented()
        }
    }

    private fun captureWebview(call: MethodCall, result: MethodChannel.Result) {
        var tabId = 0
        try {
            tabId = call.argument<Int>("tabId") ?: 0
        } catch (e: NullPointerException) {
            e.printStackTrace()
        }

        webViewManager?.capture(tabId) ?: return
        result.success(null)
    }

    private fun openUrl(call: MethodCall, result: MethodChannel.Result) {
        val hidden = call.argument<Boolean>("hidden")!!
        val url = call.argument<String>("url")
        val userAgent = call.argument<String>("userAgent")
        val withJavascript = call.argument<Boolean>("withJavascript")!!
        val clearCache = call.argument<Boolean>("clearCache")!!
        val clearCookies = call.argument<Boolean>("clearCookies")!!
        val withZoom = call.argument<Boolean>("withZoom")!!
        val withLocalStorage = call.argument<Boolean>("withLocalStorage")!!
        val supportMultipleWindows = call.argument<Boolean>("supportMultipleWindows")!!
        val appCacheEnabled = call.argument<Boolean>("appCacheEnabled")!!
        val headers = call.argument<Map<String, String>>("headers")
        val scrollBar = call.argument<Boolean>("scrollBar")!!
        val allowFileURLs = call.argument<Boolean>("allowFileURLs")!!
        val useWideViewPort = call.argument<Boolean>("useWideViewPort")!!
        val invalidUrlRegex = call.argument<String>("invalidUrlRegex")
        val geolocationEnabled = call.argument<Boolean>("geolocationEnabled")!!

        if (webViewManager == null || webViewManager?.closed ?: return) {
            webViewManager = WebviewManager(activity, context)
        }

        val params = buildLayoutParams(call)

        activity.addContentView(webViewManager!!.webView, params)

        webViewManager?.openUrl(withJavascript,
                clearCache,
                hidden,
                clearCookies,
                userAgent,
                url ?: return,
                headers,
                withZoom,
                withLocalStorage,
                scrollBar,
                supportMultipleWindows,
                appCacheEnabled,
                allowFileURLs,
                useWideViewPort,
                invalidUrlRegex ?: return,
                geolocationEnabled
        ) ?: return
        result.success(null)
    }

    private fun buildLayoutParams(call: MethodCall): FrameLayout.LayoutParams {
        val rc = call.argument<Map<String, Number>>("rect")
        val params: FrameLayout.LayoutParams
        if (rc != null) {
            params = FrameLayout.LayoutParams(
                    dp2px(activity, rc["width"]!!.toInt().toFloat()), dp2px(activity, rc["height"]!!.toInt().toFloat()))
            params.setMargins(dp2px(activity, rc["left"]!!.toInt().toFloat()), dp2px(activity, rc["top"]!!.toInt().toFloat()),
                    0, 0)
        } else {
            val display = activity.windowManager.defaultDisplay
            val size = Point()
            display.getSize(size)
            val width = size.x
            val height = size.y
            params = FrameLayout.LayoutParams(width, height)
        }

        return params
    }

    private fun stopLoading(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            webViewManager?.stopLoading(call, result) ?: return
        }
        result.success(null)
    }

    private fun close(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            webViewManager?.close(call, result) ?: return
            webViewManager = null
        }
    }

    /**
     * Navigates back on the Webview.
     */
    private fun back(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            webViewManager?.back(call, result) ?: return
        }
        result.success(null)
    }

    /**
     * Navigates forward on the Webview.
     */
    private fun forward(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            webViewManager?.forward(call, result) ?: return
        }
        result.success(null)
    }

    /**
     * Reloads the Webview.
     */
    private fun reload(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            webViewManager?.reload(call, result) ?: return
        }
        result.success(null)
    }

    private fun reloadUrl(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            val url = call.argument<String>("url")
            webViewManager?.reloadUrl(url ?: return) ?: return
        }
        result.success(null)
    }

    private fun eval(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            webViewManager?.eval(call, result) ?: return
        }
    }

    private fun resize(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            val params = buildLayoutParams(call)
            webViewManager?.resize(params) ?: return
        }
        result.success(null)
    }

    private fun hide(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            webViewManager?.hide(call, result) ?: return
        }
        result.success(null)
    }

    private fun show(call: MethodCall, result: MethodChannel.Result) {
        if (webViewManager != null) {
            webViewManager?.show(call, result) ?: return
        }
        result.success(null)
    }

    private fun cleanCookies(call: MethodCall, result: MethodChannel.Result) {
        CookieManager.getInstance().removeAllCookies { }
        result.success(null)
    }

    private fun dp2px(context: Context, dp: Float): Int {
        val scale = context.resources.displayMetrics.density
        return (dp * scale + 0.5f).toInt()
    }

    override fun onActivityResult(i: Int, i1: Int, intent: Intent): Boolean {
        return if (webViewManager != null) {
            webViewManager!!.resultHandler.handleResult(i, i1, intent)
        } else false
    }

    companion object {
        internal var channel: MethodChannel? = null
        private val CHANNEL_NAME = "flutter_webview_plugin"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            channel = MethodChannel(registrar.messenger(), CHANNEL_NAME)
            Log.d("LOGGER_TAG", "register with webview plugin")
            val instance = FlutterWebviewPlugin(registrar.activity(), registrar.activeContext())
            registrar.addActivityResultListener(instance)
            channel?.setMethodCallHandler(instance) ?: return
        }

        fun registerNormal(flutterActivity: FlutterActivity) {
            channel = MethodChannel(flutterActivity.flutterView, CHANNEL_NAME)
            Log.d("LOGGER_TAG", "register normal webview plugin")
            val instance = FlutterWebviewPlugin(flutterActivity, flutterActivity.applicationContext)
            channel?.setMethodCallHandler(instance) ?: return
        }
    }
}
