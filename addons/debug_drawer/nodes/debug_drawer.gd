@tool
class_name DebugDrawer extends Node3D

#region exports
@export var global: bool = true

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

func _ready() -> void:
	if global:
		GlobalDebugDrawer._register_debug_drawer(self)

func _exit_tree() -> void:
	GlobalDebugDrawer._unregister_scene_manager(self)

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
func draw_cube(center: Vector3, size: Vector3, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cube_drawer.draw(center, size, Quaternion.IDENTITY, line_color, fill_color)

func draw_cube_rotated(center: Vector3, size: Vector3, rotation: Quaternion, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cube_drawer.draw(center, size, rotation, line_color, fill_color)

func draw_line(start: Vector3, end: Vector3, line_color: Color) -> void:
	_line_drawer.draw(start, end, line_color)

func draw_path(path: PackedVector3Array, line_color: Color) -> void:
	for i in range(path.size() - 1):
		var current_point := path[i]
		var next_point := path[i + 1]
		
		_line_drawer.draw(current_point, next_point, line_color)

func draw_vector(origin: Vector3, vector: Vector3, line_color: Color, draw_arrow: bool = true) -> void:
	_line_drawer.draw(origin, origin + vector, line_color)
	
	var vector_length := vector.length()
	var arrow_scale = vector_length / 20.0
	var normalized_vector := vector.normalized()
	_cylinder_drawer.draw(origin + vector - (normalized_vector * arrow_scale) / 2.0, arrow_scale * 2.0, 0.0, arrow_scale / 1.5, Quaternion(Vector3.UP, normalized_vector), 16, Color.TRANSPARENT, line_color)

func draw_sphere(center: Vector3, radius: float, resolution: DebugSphereDrawer.SphereResolution, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_sphere_drawer.draw(center, radius, resolution, line_color, fill_color)

func draw_cylinder(center: Vector3, height: float, top_radius: float, bottom_radius: float, resolution: int, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cylinder_drawer.draw(center, height, top_radius, bottom_radius, Quaternion.IDENTITY, resolution, line_color, fill_color)

func draw_cylinder_rotated(center: Vector3, height: float, top_radius: float, bottom_radius: float, rotation: Quaternion, resolution: int, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	_cylinder_drawer.draw(center, height, top_radius, bottom_radius, rotation, resolution, line_color, fill_color)
