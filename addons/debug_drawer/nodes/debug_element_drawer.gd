@tool
class_name DebugElementDrawer extends Node3D

#region constants
const TOO_MANY_SHAPES_WARNING: String = "[Debug Drawer] Attempted to draw too many shapes in one frame. The limit is set to %d, try increasing it in addons/debug_drawer/max_shape_instances"

#region identity
var _max_shape_instances: int

#region node_events
func _enter_tree() -> void:
	_max_shape_instances = DebugDrawerSettings.get_max_shape_instances()

#region private_functions
func _push_too_many_shapes_warning() -> void:
	push_warning(TOO_MANY_SHAPES_WARNING % _max_shape_instances)
