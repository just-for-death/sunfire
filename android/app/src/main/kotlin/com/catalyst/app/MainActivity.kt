package com.catalyst.app

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import dev.darttools.flutter_android_volume_keydown.FlutterAndroidVolumeKeydownActivity

class MainActivity : FlutterAndroidVolumeKeydownActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Handle the splash screen transition.
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }
}
