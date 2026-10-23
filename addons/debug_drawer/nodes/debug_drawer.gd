class_name DebugDrawer extends Node3D

#region references
var _cube_drawer: DebugCubeDrawer = null

#region node_events
func _enter_tree() -> void:
	_cube_drawer = DebugCubeDrawer.new()
	add_child(_cube_drawer, false, Node.INTERNAL_MODE_FRONT)
	
	process_priority = -1000

func _process(_delta: float) -> void:
	_cube_drawer.reset()

#region public_functions
func draw_cube(min_point: Vector3, max_point: Vector3, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cube_drawer.draw(min_point, max_point, line_color, fill_color)
