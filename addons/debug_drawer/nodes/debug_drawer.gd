@tool
class_name DebugDrawer extends Node3D

#region references
var _cube_drawer: DebugCubeDrawer = null
var _line_drawer: DebugLineDrawer = null
var _sphere_drawer: DebugSphereDrawer = null
var _cylinder_drawer: DebugCylinderDrawer = null

#region node_events
func _enter_tree() -> void:
	add_child(LateProcesser.new(), false, Node.INTERNAL_MODE_FRONT)
	
	if _cube_drawer == null:
		_cube_drawer = DebugCubeDrawer.new()
		add_child(_cube_drawer, false, Node.INTERNAL_MODE_FRONT)
	
	if _line_drawer == null:
		_line_drawer = DebugLineDrawer.new()
		add_child(_line_drawer, false, Node.INTERNAL_MODE_FRONT)
	
	if _sphere_drawer == null:
		_sphere_drawer = DebugSphereDrawer.new()
		add_child(_sphere_drawer, false, Node.INTERNAL_MODE_FRONT)
	
	if _cylinder_drawer == null:
		_cylinder_drawer = DebugCylinderDrawer.new()
		add_child(_cylinder_drawer, false, Node.INTERNAL_MODE_FRONT)
	
	process_priority = -1000

func _process(_delta: float) -> void:
	_cube_drawer.reset()
	_line_drawer.reset()
	_sphere_drawer.reset()
	_cylinder_drawer.reset()

func _late_process(_delta: float) -> void:
	_cube_drawer.finalize()
	_line_drawer.finalize()
	_sphere_drawer.finalize()
	_cylinder_drawer.finalize()

#region public_functions
func draw_cube(min_point: Vector3, size: Vector3, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cube_drawer.draw(min_point, size, Quaternion.IDENTITY, line_color, fill_color)

func draw_cube_rotated(min_point: Vector3, size: Vector3, rotation: Quaternion, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cube_drawer.draw(min_point, size, rotation, line_color, fill_color)

func draw_line(start: Vector3, end: Vector3, line_color: Color) -> void:
	_line_drawer.draw(start, end, line_color)

func draw_vector(origin: Vector3, vector: Vector3, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0), draw_arrow: bool = true) -> void:
	#_line_drawer.draw()
	pass

func draw_sphere(center: Vector3, radius: float, resolution: int, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_sphere_drawer.draw(center, radius, resolution, line_color, fill_color)

func draw_cylinder(center: Vector3, height: float, top_radius: float, bottom_radius: float, resolution: int, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cylinder_drawer.draw(center, height, top_radius, bottom_radius, Quaternion.IDENTITY, resolution, line_color, fill_color)

func draw_cylinder_rotated(center: Vector3, height: float, top_radius: float, bottom_radius: float, rotation: Quaternion, resolution: int, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cylinder_drawer.draw(center, height, top_radius, bottom_radius, rotation, resolution, line_color, fill_color)
