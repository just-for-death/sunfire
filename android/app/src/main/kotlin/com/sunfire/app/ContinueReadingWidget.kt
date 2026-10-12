package com.sunfire.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.widget.RemoteViews

/**
 * A7.4: Continue Reading home-screen widget.
 *
 * Reads the last reading session from Flutter SharedPreferences
 * (keys written by WidgetSyncService) and deep-links into the reader.
 * Tapping the widget opens the library; tapping with a known chapter
 * opens that chapter in the reader.
 */
class ContinueReadingWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            val title = prefs.getString("flutter.widget_title", null)
            val subtitle = prefs.getString("flutter.widget_subtitle", null)
            val chapterId = prefs.getInt("flutter.widget_chapter_id", 0)

            val views = RemoteViews(context.packageName, R.layout.widget_continue_reading)
            views.setTextViewText(
                R.id.widget_title,
                title ?: context.getString(R.string.widget_empty_title))
            views.setTextViewText(
                R.id.widget_subtitle,
                subtitle ?: context.getString(R.string.widget_empty_subtitle))

            // Deep-link: reader when a chapter is known, else library.
            val uri = if (chapterId != 0) {
                Uri.parse("sunfire://reader/$chapterId")
            } else {
                Uri.parse("sunfire://library")
            }
            val intent = Intent(Intent.ACTION_VIEW, uri, context, MainActivity::class.java)
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pending = PendingIntent.getActivity(context, appWidgetId, intent, flags)
            views.setOnClickPendingIntent(R.id.widget_title, pending)
            views.setOnClickPendingIntent(R.id.widget_subtitle, pending)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        /** Refresh all widget instances (called after prefs change). */
        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                android.content.ComponentName(context, ContinueReadingWidget::class.java))
            for (id in ids) updateWidget(context, manager, id)
        }
    }
}
