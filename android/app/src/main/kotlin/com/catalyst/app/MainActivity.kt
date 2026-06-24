package com.catalyst.app

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.core.view.WindowCompat
import dev.darttools.flutter_android_volume_keydown.FlutterAndroidVolumeKeydownActivity

class MainActivity : FlutterAndroidVolumeKeydownActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
