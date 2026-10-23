@tool
extends EditorPlugin

func _enable_plugin() -> void:
	ProjectSettings.set_setting("addons/debug_drawer/max_shape_instances", 1024)
