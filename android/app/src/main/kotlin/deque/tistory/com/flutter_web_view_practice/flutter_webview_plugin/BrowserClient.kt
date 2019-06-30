package deque.tistory.com.flutter_web_view_practice.flutter_webview_plugin

import android.annotation.TargetApi
import android.graphics.Bitmap
import android.os.Build
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient

import java.util.HashMap
import java.util.regex.Matcher
import java.util.regex.Pattern

/**
 * Created by lejard_h on 20/12/2017.
 */

class BrowserClient @JvmOverloads constructor(invalidUrlRegex: String? = null) : WebViewClient() {
    private var invalidUrlPattern: Pattern? = null

    init {
        if (invalidUrlRegex != null) {
            invalidUrlPattern = Pattern.compile(invalidUrlRegex)
        }
    }

    fun updateInvalidUrlRegex(invalidUrlRegex: String?) {
        if (invalidUrlRegex != null) {
            invalidUrlPattern = Pattern.compile(invalidUrlRegex)
        } else {
            invalidUrlPattern = null
        }
    }

    override fun onPageStarted(view: WebView, url: String, favicon: Bitmap) {
        super.onPageStarted(view, url, favicon)
        val data = HashMap<String, Any>()
        data["url"] = url
        data["type"] = "startLoad"
        FlutterWebviewPlugin.channel?.invokeMethod("onState", data)
    }

    override fun onPageFinished(view: WebView, url: String) {
        super.onPageFinished(view, url)
        val data = HashMap<String, Any>()
        data["url"] = url

        FlutterWebviewPlugin.channel?.invokeMethod("onUrlChanged", data)

        data["type"] = "finishLoad"
        FlutterWebviewPlugin.channel?.invokeMethod("onState", data)

    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        // returning true causes the current WebView to abort loading the URL,
        // while returning false causes the WebView to continue loading the URL as usual.
        val url = request.url.toString()
        val isInvalid = checkInvalidUrl(url)
        val data = HashMap<String, Any>()
        data["url"] = url
        data["type"] = if (isInvalid) "abortLoad" else "shouldStart"

        FlutterWebviewPlugin.channel?.invokeMethod("onState", data)
        return isInvalid
    }

    override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
        // returning true causes the current WebView to abort loading the URL,
        // while returning false causes the WebView to continue loading the URL as usual.
        val isInvalid = checkInvalidUrl(url)
        val data = HashMap<String, Any>()
        data["url"] = url
        data["type"] = if (isInvalid) "abortLoad" else "shouldStart"

        FlutterWebviewPlugin.channel?.invokeMethod("onState", data)
        return isInvalid
    }

    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onReceivedHttpError(view: WebView, request: WebResourceRequest, errorResponse: WebResourceResponse) {
        super.onReceivedHttpError(view, request, errorResponse)
        val data = HashMap<String, Any>()
        data["url"] = request.url.toString()
        data["code"] = Integer.toString(errorResponse.statusCode)
        FlutterWebviewPlugin.channel?.invokeMethod("onHttpError", data)
    }

    override fun onReceivedError(view: WebView, errorCode: Int, description: String, failingUrl: String) {
        super.onReceivedError(view, errorCode, description, failingUrl)
        val data = HashMap<String, Any>()
        data["url"] = failingUrl
        data["code"] = errorCode
        FlutterWebviewPlugin.channel?.invokeMethod("onHttpError", data)
    }

    private fun checkInvalidUrl(url: String): Boolean {
        return if (invalidUrlPattern == null) {
            false
        } else {
            val matcher = invalidUrlPattern!!.matcher(url)
            matcher.lookingAt()
        }
    }
}