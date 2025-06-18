package com.minh.momo_vn

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import vn.momo.momo_partner.AppMoMoLib

@Suppress("DEPRECATION")
class MomoVnPluginDelegate(private val activity: Activity) : ActivityResultListener {

    private var pendingResult: Result? = null

    fun openCheckout(momoRequestPaymentData: Any, result: Result) {
        this.pendingResult = result

        AppMoMoLib.getInstance().setAction(AppMoMoLib.ACTION.PAYMENT)
        AppMoMoLib.getInstance().setActionType(AppMoMoLib.ACTION_TYPE.GET_TOKEN)

        val paymentInfo: HashMap<String, Any> = momoRequestPaymentData as HashMap<String, Any>
        val isTestMode: Boolean? = paymentInfo["isTestMode"] as Boolean?

        AppMoMoLib.getInstance().setEnvironment(
            if (isTestMode == true) AppMoMoLib.ENVIRONMENT.DEVELOPMENT
            else AppMoMoLib.ENVIRONMENT.PRODUCTION
        )

        AppMoMoLib.getInstance().requestMoMoCallBack(activity, paymentInfo)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (resultCode == Activity.RESULT_OK &&
            requestCode == AppMoMoLib.getInstance().REQUEST_CODE_MOMO
        ) {
            handleResult(data)
        }
        return true
    }

    private fun handleResult(data: Intent?) {
        val resultData: MutableMap<String, Any> = HashMap()

        if (data != null) {
            val status = data.getIntExtra("status", -1)
            resultData["isSuccess"] = (status == MomoVnConfig.CODE_PAYMENT_SUCCESS)
            resultData["status"] = status
            resultData["phoneNumber"] = data.getStringExtra("phonenumber").orEmpty()
            resultData["token"] = data.getStringExtra("data").orEmpty()
            resultData["message"] = data.getStringExtra("message").orEmpty()
            resultData["extra"] = data.getStringExtra("extra").orEmpty()
        } else {
            resultData["isSuccess"] = false
            resultData["status"] = 7
            resultData["phoneNumber"] = ""
            resultData["token"] = ""
            resultData["message"] = ""
            resultData["extra"] = ""
        }

        pendingResult?.success(resultData)
        pendingResult = null
    }
}
