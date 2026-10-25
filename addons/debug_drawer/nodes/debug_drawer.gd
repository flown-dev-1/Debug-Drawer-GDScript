@tool
class_name DebugDrawer extends Node3D

#region references
var _cube_drawer: DebugCubeDrawer = null
var _line_drawer: DebugLineDrawer = null
var _sphere_drawer: DebugSphereDrawer = null

#region node_events
func _enter_tree() -> void:
	if _cube_drawer == null:
		_cube_drawer = DebugCubeDrawer.new()
		add_child(_cube_drawer, false, Node.INTERNAL_MODE_FRONT)
	
	if _line_drawer == null:
		_line_drawer = DebugLineDrawer.new()
		add_child(_line_drawer, false, Node.INTERNAL_MODE_FRONT)
	
	if _sphere_drawer == null:
		_sphere_drawer = DebugSphereDrawer.new()
		add_child(_sphere_drawer, false, Node.INTERNAL_MODE_FRONT)
	
	process_priority = -1000

func _process(_delta: float) -> void:
	_cube_drawer.reset()
	_line_drawer.reset()
	_sphere_drawer.reset()

#region public_functions
func draw_cube(min_point: Vector3, size: Vector3, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cube_drawer.draw(min_point, size, line_color, fill_color)

func draw_line(start: Vector3, end: Vector3, line_color: Color) -> void:
	_line_drawer.draw(start, end, line_color)

func draw_sphere(center: Vector3, radius: float, resolution: int, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_sphere_drawer.draw(center, radius, resolution, line_color, fill_color)
