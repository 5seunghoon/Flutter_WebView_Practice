package deque.tistory.com.flutter_web_view_practice.flutter_webview_plugin

import android.annotation.TargetApi
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Picture
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.util.Log
import android.view.KeyEvent
import android.view.View
import android.view.ViewGroup
import android.webkit.CookieManager
import android.webkit.GeolocationPermissions
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.widget.FrameLayout

import androidx.core.content.FileProvider

import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.ArrayList
import java.util.Date
import java.util.HashMap

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

import android.app.Activity.RESULT_OK

/**
 * Created by lejard_h on 20/12/2017.
 */

internal class WebviewManager(var activity: Activity, var context: Context) {

    private var mUploadMessage: ValueCallback<Uri>? = null
    private var mUploadMessageArray: ValueCallback<Array<Uri>>? = null
    private var fileUri: Uri? = null
    private var videoUri: Uri? = null

    var closed = false
    var webView: WebView? = null
    var webViewClient: BrowserClient
    var resultHandler: ResultHandler

    private fun getFileSize(fileUri: Uri): Long {
        val returnCursor = context.contentResolver.query(fileUri, null, null, null, null)
        returnCursor!!.moveToFirst()
        val sizeIndex = returnCursor.getColumnIndex(OpenableColumns.SIZE)
        return returnCursor.getLong(sizeIndex)
    }

    @TargetApi(7)
    internal inner class ResultHandler {
        fun handleResult(requestCode: Int, resultCode: Int, intent: Intent?): Boolean {
            fileUri?.let {
                var handled = false
                if (Build.VERSION.SDK_INT >= 21) {
                    if (requestCode == FILECHOOSER_RESULTCODE) {
                        var results: Array<Uri>? = null
                        if (resultCode == RESULT_OK) {
                            results = when {
                                getFileSize(it) > 0 -> arrayOf(it)
                                getFileSize(it) > 0 -> arrayOf(videoUri ?: return@let)
                                else -> intent?.let { _intent -> getSelectedFiles(_intent) }
                            }
                        }
                        mUploadMessageArray?.onReceiveValue(results)
                        mUploadMessageArray = null
                        handled = true
                    }
                } else {
                    if (requestCode == FILECHOOSER_RESULTCODE) {
                        var result: Uri? = null
                        if (resultCode == RESULT_OK) {
                            result = intent?.data ?: return@let
                        }
                        val results = arrayOf(result ?: return@let)
                        mUploadMessageArray?.onReceiveValue(results)
                        mUploadMessageArray = null
                        handled = true
                    }
                }
                return handled
            }
            return false
        }
    }

    private fun getSelectedFiles(data: Intent): Array<Uri>? {
        // we have one files selected
        if (data.data != null) {
            val dataString = data.dataString ?: return null
            return arrayOf(Uri.parse(dataString))
        }
        // we have multiple files selected
        data.clipData?.let {
            val numSelectedFiles = it.itemCount
            val result = mutableListOf<Uri>()
            for(i in 0..numSelectedFiles) {
                result.add(it.getItemAt(i)?.uri ?: return null)
            }
            return result.toTypedArray()
        }
        return null
    }

    init {
        this.webView = ObservableWebView(activity)
        this.resultHandler = ResultHandler()
        webViewClient = BrowserClient()
        webView!!.setOnKeyListener(View.OnKeyListener { v, keyCode, event ->
            if (event.action == KeyEvent.ACTION_DOWN) {
                when (keyCode) {
                    KeyEvent.KEYCODE_BACK -> {
                        if (webView!!.canGoBack()) {
                            webView!!.goBack()
                        } else {
                            FlutterWebviewPlugin.channel?.invokeMethod("onBack", null)
                        }
                        return@OnKeyListener true
                    }
                }
            }

            false
        })

        (webView as ObservableWebView).onScrollChangedCallback = object : ObservableWebView.OnScrollChangedCallback {
            override fun onScroll(l: Int, t: Int, oldl: Int, oldt: Int) {
                val yDirection = HashMap<String, Any>()
                yDirection["yDirection"] = t.toDouble()
                FlutterWebviewPlugin.channel?.invokeMethod("onScrollYChanged", yDirection)
                val xDirection = HashMap<String, Any>()
                xDirection["xDirection"] = l.toDouble()
                FlutterWebviewPlugin.channel?.invokeMethod("onScrollXChanged", xDirection)
            }
        }

        webView!!.webViewClient = webViewClient
        webView!!.webChromeClient = object : WebChromeClient() {
            //The undocumented magic method override
            //Eclipse will swear at you if you try to put @Override here
            // For Android 3.0+
            fun openFileChooser(uploadMsg: ValueCallback<Uri>) {
                mUploadMessage = uploadMsg
                val i = Intent(Intent.ACTION_GET_CONTENT)
                i.addCategory(Intent.CATEGORY_OPENABLE)
                i.type = "image/*"
                activity.startActivityForResult(Intent.createChooser(i, "File Chooser"), FILECHOOSER_RESULTCODE)

            }

            // For Android 3.0+
            fun openFileChooser(uploadMsg: ValueCallback<Uri>, acceptType: String) {
                mUploadMessage = uploadMsg
                val i = Intent(Intent.ACTION_GET_CONTENT)
                i.addCategory(Intent.CATEGORY_OPENABLE)
                i.type = "*/*"
                activity.startActivityForResult(
                        Intent.createChooser(i, "File Browser"),
                        FILECHOOSER_RESULTCODE)
            }

            //For Android 4.1
            fun openFileChooser(uploadMsg: ValueCallback<Uri>, acceptType: String, capture: String) {
                mUploadMessage = uploadMsg
                val i = Intent(Intent.ACTION_GET_CONTENT)
                i.addCategory(Intent.CATEGORY_OPENABLE)
                i.type = "image/*"
                activity.startActivityForResult(Intent.createChooser(i, "File Chooser"), FILECHOOSER_RESULTCODE)

            }

            //For Android 5.0+
            override fun onShowFileChooser(
                    webView: WebView, filePathCallback: ValueCallback<Array<Uri>>,
                    fileChooserParams: WebChromeClient.FileChooserParams): Boolean {
                if (mUploadMessageArray != null) {
                    mUploadMessageArray!!.onReceiveValue(null)
                }
                mUploadMessageArray = filePathCallback

                val acceptTypes = getSafeAcceptedTypes(fileChooserParams)
                val intentList = ArrayList<Intent>()
                fileUri = null
                videoUri = null
                if (acceptsImages(acceptTypes)) {
                    val takePhotoIntent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                    fileUri = getOutputFilename(MediaStore.ACTION_IMAGE_CAPTURE)
                    takePhotoIntent.putExtra(MediaStore.EXTRA_OUTPUT, fileUri)
                    intentList.add(takePhotoIntent)
                }
                if (acceptsVideo(acceptTypes)) {
                    val takeVideoIntent = Intent(MediaStore.ACTION_VIDEO_CAPTURE)
                    videoUri = getOutputFilename(MediaStore.ACTION_VIDEO_CAPTURE)
                    takeVideoIntent.putExtra(MediaStore.EXTRA_OUTPUT, videoUri)
                    intentList.add(takeVideoIntent)
                }
                val contentSelectionIntent: Intent
                if (Build.VERSION.SDK_INT >= 21) {
                    val allowMultiple = fileChooserParams.mode == WebChromeClient.FileChooserParams.MODE_OPEN_MULTIPLE
                    contentSelectionIntent = fileChooserParams.createIntent()
                    contentSelectionIntent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, allowMultiple)
                } else {
                    contentSelectionIntent = Intent(Intent.ACTION_GET_CONTENT)
                    contentSelectionIntent.addCategory(Intent.CATEGORY_OPENABLE)
                    contentSelectionIntent.type = "*/*"
                }
                val intentArray = intentList.toTypedArray()

                val chooserIntent = Intent(Intent.ACTION_CHOOSER)
                chooserIntent.putExtra(Intent.EXTRA_INTENT, contentSelectionIntent)
                chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, intentArray)
                activity.startActivityForResult(chooserIntent, FILECHOOSER_RESULTCODE)
                return true
            }

            override fun onProgressChanged(view: WebView, progress: Int) {
                val args = HashMap<String, Any>()
                args["progress"] = progress / 100.0
                FlutterWebviewPlugin.channel?.invokeMethod("onProgressChanged", args)
            }
        }
    }

    private fun getOutputFilename(intentType: String): Uri {
        var prefix = ""
        var suffix = ""

        if (intentType === MediaStore.ACTION_IMAGE_CAPTURE) {
            prefix = "image-"
            suffix = ".jpg"
        } else if (intentType === MediaStore.ACTION_VIDEO_CAPTURE) {
            prefix = "video-"
            suffix = ".mp4"
        }

        val packageName = context.packageName
        var capturedFile: File? = null
        try {
            capturedFile = createCapturedFile(prefix, suffix)
        } catch (e: IOException) {
            e.printStackTrace()
        }

        return FileProvider.getUriForFile(context, "$packageName.fileprovider", capturedFile!!)
    }

    @Throws(IOException::class)
    private fun createCapturedFile(prefix: String, suffix: String): File {
        val timeStamp = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
        val imageFileName = prefix + "_" + timeStamp
        val storageDir = context.getExternalFilesDir(null)
        return File.createTempFile(imageFileName, suffix, storageDir)
    }

    private fun acceptsImages(types: Array<String>): Boolean {
        return isArrayEmpty(types) || arrayContainsString(types, "image")
    }

    private fun acceptsVideo(types: Array<String>): Boolean {
        return isArrayEmpty(types) || arrayContainsString(types, "video")
    }

    private fun arrayContainsString(array: Array<String>, pattern: String): Boolean {
        for (content in array) {
            if (content.contains(pattern)) {
                return true
            }
        }
        return false
    }

    private fun isArrayEmpty(arr: Array<String>): Boolean {
        // when our array returned from getAcceptTypes() has no values set from the
        // webview
        // i.e. <input type="file" />, without any "accept" attr
        // will be an array with one empty string element, afaik
        return arr.size == 0 || arr.size == 1 && arr[0].length == 0
    }

    private fun getSafeAcceptedTypes(params: WebChromeClient.FileChooserParams): Array<String> {

        // the getAcceptTypes() is available only in api 21+
        // for lower level, we ignore it
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            params.acceptTypes
        } else arrayOf()

    }

    private fun clearCookies() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().removeAllCookies { }
        } else {
            CookieManager.getInstance().removeAllCookie()
        }
    }

    private fun clearCache() {
        webView!!.clearCache(true)
        webView!!.clearFormData()
    }

    fun capture(
            tabId: Int
    ) {
        val scrollY = webView!!.scrollY


        Log.d("LOGGER_TAG", "sy : " + scrollY + ", width : " + webView!!.width + ", height :  " + webView!!.height)

        var captureBitmap = Bitmap.createBitmap(webView!!.width,
                webView!!.height + scrollY, Bitmap.Config.ARGB_8888)
        val captureCanvas = Canvas(captureBitmap)
        webView!!.draw(captureCanvas)

        val tabIdStr: String = when {
            tabId < 10 -> "00$tabId"
            tabId < 100 -> "0$tabId"
            else -> "" + tabId
        }

        val screenShotPath = context.applicationInfo.dataDir + "/app_flutter/screenshot" + tabIdStr + ".jpg"
        Log.d("LOGGER_TAG", "screenshot path : $screenShotPath")
        try {
            val fos = FileOutputStream(screenShotPath)
            if (scrollY != 0)
                captureBitmap = Bitmap.createBitmap(captureBitmap, 0, scrollY, webView!!.width, webView!!.height)
            captureBitmap.compress(Bitmap.CompressFormat.JPEG, 50, fos)
            fos.close()
        } catch (e: IOException) {
            e.printStackTrace()
        }

    }

    fun openUrl(
            withJavascript: Boolean,
            clearCache: Boolean,
            hidden: Boolean,
            clearCookies: Boolean,
            userAgent: String?,
            url: String,
            headers: Map<String, String>?,
            withZoom: Boolean,
            withLocalStorage: Boolean,
            scrollBar: Boolean,
            supportMultipleWindows: Boolean,
            appCacheEnabled: Boolean,
            allowFileURLs: Boolean,
            useWideViewPort: Boolean,
            invalidUrlRegex: String,
            geolocationEnabled: Boolean
    ) {
        webView!!.settings.javaScriptEnabled = withJavascript
        webView!!.settings.builtInZoomControls = withZoom
        webView!!.settings.setSupportZoom(withZoom)
        webView!!.settings.domStorageEnabled = withLocalStorage
        webView!!.settings.javaScriptCanOpenWindowsAutomatically = supportMultipleWindows

        webView!!.settings.setSupportMultipleWindows(supportMultipleWindows)

        webView!!.settings.setAppCacheEnabled(appCacheEnabled)

        webView!!.settings.allowFileAccessFromFileURLs = allowFileURLs
        webView!!.settings.allowUniversalAccessFromFileURLs = allowFileURLs

        webView!!.settings.useWideViewPort = useWideViewPort

        webViewClient.updateInvalidUrlRegex(invalidUrlRegex)

        if (geolocationEnabled) {
            webView!!.settings.setGeolocationEnabled(true)
            webView!!.webChromeClient = object : WebChromeClient() {
                override fun onGeolocationPermissionsShowPrompt(origin: String, callback: GeolocationPermissions.Callback) {
                    callback.invoke(origin, true, false)
                }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            webView!!.settings.mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
        }

        if (clearCache) {
            clearCache()
        }

        if (hidden) {
            webView!!.visibility = View.GONE
        }

        if (clearCookies) {
            clearCookies()
        }

        if (userAgent != null) {
            webView!!.settings.userAgentString = userAgent
        }

        if (!scrollBar) {
            webView!!.isVerticalScrollBarEnabled = false
        }

        if (headers != null) {
            webView!!.loadUrl(url, headers)
        } else {
            webView!!.loadUrl(url)
        }
    }

    fun reloadUrl(url: String) {
        webView!!.loadUrl(url)
    }

    @JvmOverloads
    fun close(call: MethodCall? = null, result: MethodChannel.Result? = null) {
        if (webView != null) {
            val vg = webView!!.parent as ViewGroup
            vg.removeView(webView)
        }
        webView = null
        result?.success(null)

        closed = true
        FlutterWebviewPlugin.channel?.invokeMethod("onDestroy", null)
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    fun eval(call: MethodCall, result: MethodChannel.Result) {
        val code = call.argument<String>("code")

        webView!!.evaluateJavascript(code) { value -> result.success(value) }
    }

    /**
     * Reloads the Webview.
     */
    fun reload(call: MethodCall, result: MethodChannel.Result) {
        if (webView != null) {
            webView!!.reload()
        }
    }

    /**
     * Navigates back on the Webview.
     */
    fun back(call: MethodCall, result: MethodChannel.Result) {
        if (webView != null && webView!!.canGoBack()) {
            webView!!.goBack()
        }
    }

    /**
     * Navigates forward on the Webview.
     */
    fun forward(call: MethodCall, result: MethodChannel.Result) {
        if (webView != null && webView!!.canGoForward()) {
            webView!!.goForward()
        }
    }

    fun resize(params: FrameLayout.LayoutParams) {
        webView!!.layoutParams = params
    }

    /**
     * Checks if going back on the Webview is possible.
     */
    fun canGoBack(): Boolean {
        return webView!!.canGoBack()
    }

    /**
     * Checks if going forward on the Webview is possible.
     */
    fun canGoForward(): Boolean {
        return webView!!.canGoForward()
    }

    fun hide(call: MethodCall, result: MethodChannel.Result) {
        if (webView != null) {
            webView!!.visibility = View.GONE
        }
    }

    fun show(call: MethodCall, result: MethodChannel.Result) {
        if (webView != null) {
            webView!!.visibility = View.VISIBLE
        }
    }

    fun stopLoading(call: MethodCall, result: MethodChannel.Result) {
        if (webView != null) {
            webView!!.stopLoading()
        }
    }

    companion object {
        private val FILECHOOSER_RESULTCODE = 1
    }
}
