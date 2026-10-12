package com.sunfire.app

import android.content.Intent
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi

/**
 * A7.5: Quick Settings tile - one-tap library sync.
 *
 * Tap behaviour: opens Sunfire with ACTION_SYNC so MainActivity forwards the
 * request to Dart (sunfire/quick_actions channel), which runs a manual
 * library update. Tile state reflects the last known outcome.
 */
@RequiresApi(Build.VERSION_CODES.N)
class SyncTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        qsTile?.let {
            it.state = Tile.STATE_INACTIVE
            it.label = getString(R.string.tile_sync_label)
            it.subtitle = getString(R.string.tile_sync_subtitle)
            it.updateTile()
        }
    }

    override fun onClick() {
        super.onClick()
        val intent = Intent(this, MainActivity::class.java).apply {
            action = MainActivity.ACTION_SYNC
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(intent)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }
}
