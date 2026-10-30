@tool
extends EditorPlugin

func _enable_plugin() -> void:
	DebugDrawerSettings.register_settings()
	
	add_autoload_singleton("GlobalDebugDrawer", "res://addons/debug_drawer/autoloads/global_debug_drawer.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("GlobalDebugDrawer")
