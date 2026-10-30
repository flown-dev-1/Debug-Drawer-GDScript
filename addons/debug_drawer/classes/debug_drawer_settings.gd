@tool
class_name DebugDrawerSettings

#region constants
const MAX_SHAPE_INSTANCES_PATH: String = "debug_drawer/max_shape_instances"
const MAX_SHAPE_INSTANCES_DEFAULT: int = 1024

#region public_functions
static func register_settings() -> void:
	if !ProjectSettings.has_setting(MAX_SHAPE_INSTANCES_PATH):
		ProjectSettings.set_setting(MAX_SHAPE_INSTANCES_PATH, MAX_SHAPE_INSTANCES_DEFAULT)
	
	ProjectSettings.set_initial_value(MAX_SHAPE_INSTANCES_PATH, MAX_SHAPE_INSTANCES_DEFAULT)
	ProjectSettings.add_property_info({
		"name": MAX_SHAPE_INSTANCES_PATH,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "128,65536,1"
	})

static func get_max_shape_instances() -> int:
	return ProjectSettings.get_setting(MAX_SHAPE_INSTANCES_PATH, MAX_SHAPE_INSTANCES_DEFAULT)
