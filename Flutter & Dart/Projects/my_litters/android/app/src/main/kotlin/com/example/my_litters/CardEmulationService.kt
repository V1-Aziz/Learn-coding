package com.example.my_litters

import android.content.Context
import android.nfc.cardemulation.HostApduService
import android.os.Bundle

/**
 * Turns the phone into the fuel card. When a reader selects our AID
 * (see res/xml/apduservice.xml), we reply with the linked card UID as
 * ASCII bytes followed by the 9000 success status word.
 *
 * The UID is written by the Flutter side through a MethodChannel into
 * SharedPreferences, so it survives this service being (re)started by the
 * OS on tap — independently of whether the Flutter UI is in the foreground.
 */
class CardEmulationService : HostApduService() {

    companion object {
        const val PREFS = "hce_prefs"
        const val KEY_UID = "card_uid"
        const val KEY_ENABLED = "enabled"

        // ISO 7816-4 SELECT (by name) header: CLA=00 INS=A4 P1=04 P2=00
        private val SELECT_HEADER = byteArrayOf(0x00, 0xA4.toByte(), 0x04, 0x00)
        private val SW_OK = byteArrayOf(0x90.toByte(), 0x00)
        private val SW_NOT_FOUND = byteArrayOf(0x6A.toByte(), 0x82.toByte())
        private val SW_COND_NOT_SATISFIED = byteArrayOf(0x69.toByte(), 0x85.toByte())
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        if (commandApdu == null || !isSelectApdu(commandApdu)) return SW_NOT_FOUND

        val prefs = getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val enabled = prefs.getBoolean(KEY_ENABLED, false)
        val uid = prefs.getString(KEY_UID, null)
        if (!enabled || uid.isNullOrEmpty()) return SW_COND_NOT_SATISFIED

        return uid.toByteArray(Charsets.US_ASCII) + SW_OK
    }

    override fun onDeactivated(reason: Int) { /* nothing to clean up */ }

    private fun isSelectApdu(apdu: ByteArray): Boolean =
        apdu.size >= 4 &&
            apdu[0] == SELECT_HEADER[0] &&
            apdu[1] == SELECT_HEADER[1] &&
            apdu[2] == SELECT_HEADER[2] &&
            apdu[3] == SELECT_HEADER[3]
}
