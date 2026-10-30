@tool
class_name LateProcesser extends Node

#region node_events
func _enter_tree() -> void:
	process_priority = 1000

func _process(delta: float) -> void:
	get_parent()._late_process(delta)
