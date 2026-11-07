package com.fasttodo.app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

data class Todo(
    val id: Long,
    val title: String,
)

class TodoStore(context: Context) {
    private val prefs = context.getSharedPreferences("todos", Context.MODE_PRIVATE)

    fun load(): List<Todo> {
        val raw = prefs.getString("items", "[]") ?: "[]"
        val array = JSONArray(raw)
        return buildList {
            for (index in 0 until array.length()) {
                val item = array.getJSONObject(index)
                add(Todo(id = item.getLong("id"), title = item.getString("title")))
            }
        }
    }

    fun save(items: List<Todo>) {
        val array = JSONArray()
        items.forEach { todo ->
            array.put(
                JSONObject()
                    .put("id", todo.id)
                    .put("title", todo.title),
            )
        }
        prefs.edit().putString("items", array.toString()).apply()
    }
}
