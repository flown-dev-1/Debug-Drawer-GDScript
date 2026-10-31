@tool
extends Node

#region constants
const NO_GLOBAL_DRAWER_ERROR: String = "[Debug Drawer] Attempting to perform a global debug drawer operation with no global debug drawer"
const RE_REGISTER_DRAWER_ERROR: String = "[Debug Drawer] Multiple global debug drawers defined. Undefined behaviour."

#region references
var _target_debug_drawer: DebugDrawer = null

#region public_functions
func draw_cube(center: Vector3, size: Vector3, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_cube(center, size, line_color, fill_color)

func draw_cube_rotated(center: Vector3, size: Vector3, rotation: Quaternion, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_cube_rotated(center, size, rotation, line_color, fill_color)

func draw_line(start: Vector3, end: Vector3, line_color: Color) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_line(start, end, line_color)

func draw_path(path: PackedVector3Array, line_color: Color) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_path(path, line_color)

func draw_vector(origin: Vector3, vector: Vector3, line_color: Color, draw_arrow: bool = true) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_vector(origin, vector, line_color, draw_arrow)

func draw_sphere(center: Vector3, radius: float, resolution: DebugSphereDrawer.SphereResolution, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_sphere(center, radius, resolution, line_color, fill_color)

func draw_cylinder(center: Vector3, height: float, top_radius: float, bottom_radius: float, resolution: int, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_cylinder(center, height, top_radius, bottom_radius, resolution, line_color, fill_color)

func draw_cylinder_rotated(center: Vector3, height: float, top_radius: float, bottom_radius: float, rotation: Quaternion, resolution: int, line_color: Color, fill_color: Color = Color(0.0, 0.0, 0.0, 0.0)) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_cylinder_rotated(center, height, top_radius, bottom_radius, rotation, resolution, line_color, fill_color)

func draw_text(string: String, position: Vector3, text_color: Color = Color.WHITE, outline_color: Color = Color.BLACK, font_size: int = 32, horizontal_alignment: HorizontalAlignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER, vertical_alignment: VerticalAlignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER) -> void:
	if _target_debug_drawer == null:
		push_error(NO_GLOBAL_DRAWER_ERROR)
		return
	
	_target_debug_drawer.draw_text(string, position, text_color, outline_color, font_size, horizontal_alignment, vertical_alignment)

#region internal_functions
func _register_debug_drawer(debug_drawer: DebugDrawer) -> void:
	if _target_debug_drawer != null:
		push_warning(RE_REGISTER_DRAWER_ERROR)
		return
	
	_target_debug_drawer = debug_drawer

func _unregister_scene_manager(debug_drawer: DebugDrawer) -> void:
	if _target_debug_drawer != debug_drawer:
		return
	
	_target_debug_drawer = null
