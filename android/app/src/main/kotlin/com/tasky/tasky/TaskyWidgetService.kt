package com.tasky.tasky

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject

class TaskyWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TaskyRemoteViewsFactory(applicationContext)
    }
}

class TaskyRemoteViewsFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {

    private val tasksList = mutableListOf<JSONObject>()

    override fun onCreate() {
        loadData()
    }

    override fun onDataSetChanged() {
        loadData()
    }

    private fun loadData() {
        tasksList.clear()
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val jsonString = widgetData.getString("tasks_json", "[]") ?: "[]"
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                tasksList.add(jsonArray.getJSONObject(i))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        tasksList.clear()
    }

    override fun getCount(): Int = tasksList.size

    override fun getViewAt(position: Int): RemoteViews? {
        if (position < 0 || position >= tasksList.size) return null

        val task = tasksList[position]
        val id = task.optString("id", "")
        val title = task.optString("title", "مهمة بدون عنوان")
        val priority = task.optString("priority", "medium")
        val projectName = task.optString("projectName", "")
        val dueDate = task.optString("dueDate", "")

        val views = RemoteViews(context.packageName, R.layout.tasky_widget_item)
        views.setTextViewText(R.id.item_task_title, title)

        // إعداد السطر الفرعي (المشروع / التاريخ)
        val subText = buildString {
            if (projectName.isNotEmpty()) {
                append("📁 $projectName")
            }
            if (dueDate.isNotEmpty()) {
                if (isNotEmpty()) append(" • ")
                val dateShort = if (dueDate.length >= 10) dueDate.substring(0, 10) else dueDate
                append("📅 $dateShort")
            }
        }
        views.setTextViewText(R.id.item_task_sub, if (subText.isNotEmpty()) subText else "بدون تاريخ")

        // لون مؤشر الأولوية
        val priorityColor = when (priority.lowercase()) {
            "urgent" -> Color.parseColor("#EF4444")
            "high" -> Color.parseColor("#F97316")
            "low" -> Color.parseColor("#94A3B8")
            else -> Color.parseColor("#3B82F6")
        }
        views.setInt(R.id.item_priority_indicator, "setBackgroundColor", priorityColor)

        // FillInIntent للنقر على المهمة وفتحها
        val fillInIntent = Intent().apply {
            data = Uri.parse("tasky://task?id=$id")
        }
        views.setOnClickFillInIntent(R.id.widget_item_container, fillInIntent)

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
}
