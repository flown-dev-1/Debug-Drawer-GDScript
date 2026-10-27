@tool
class_name DebugCylinderDrawer extends DebugShapeDrawer

#region constants
const MIN_RESOLUTION: int = 3
const ROUNDING_FACTOR: int = 2048

#region references
var _lines_material: StandardMaterial3D = null
var _lines_array_meshes: Dictionary[Vector2i, ArrayMesh] = {}
var _lines_multimeshes: Dictionary[Vector2i, MultiMesh] = {}
var _lines_multi_mesh_instances: Dictionary[Vector2i, MultiMeshInstance3D] = {}

var _fill_material: StandardMaterial3D = null
var _fill_array_meshes: Dictionary[Vector2i, ArrayMesh] = {}
var _fill_multimeshes: Dictionary[Vector2i, MultiMesh] = {}
var _fill_multi_mesh_instances: Dictionary[Vector2i, MultiMeshInstance3D] = {}

#region public_functions
func draw(center: Vector3, height: float, top_radius: float, bottom_radius: float, resolution: int, line_color: Color, fill_color: Color) -> void:
	if top_radius == 0.0 && bottom_radius == 0.0:
		return
	
	var swap_vertically = top_radius > bottom_radius
	
	if swap_vertically:
		var temp = bottom_radius
		bottom_radius = top_radius
		top_radius = temp
	
	resolution = maxi(resolution, MIN_RESOLUTION)
	
	var relative_size_top := snapped(top_radius / bottom_radius, 1.0 / ROUNDING_FACTOR)
	
	var mesh_key := _get_mesh_key(resolution, relative_size_top)
	
	var vertical_scale := -height if swap_vertically else height
	var instance_transform := Transform3D(Basis.from_scale(Vector3(bottom_radius, vertical_scale, bottom_radius)), center)
	
	if line_color.a > 0.0:
		_ensure_lines_mesh(resolution, relative_size_top)
		
		var lines_multimesh := _lines_multimeshes[mesh_key]
		
		if lines_multimesh.visible_instance_count >= lines_multimesh.instance_count:
			_push_too_many_shapes_warning()
		
		lines_multimesh.set_instance_transform(lines_multimesh.visible_instance_count, instance_transform)
		lines_multimesh.set_instance_color(lines_multimesh.visible_instance_count, line_color)
		
		lines_multimesh.visible_instance_count += 1
	
	if fill_color.a > 0.0:
		_ensure_fill_mesh(resolution, relative_size_top)
		
		var fill_multimesh := _fill_multimeshes[mesh_key]
		
		if fill_multimesh.visible_instance_count >= fill_multimesh.instance_count:
			_push_too_many_shapes_warning()
		
		fill_multimesh.set_instance_transform(fill_multimesh.visible_instance_count, instance_transform)
		fill_multimesh.set_instance_color(fill_multimesh.visible_instance_count, fill_color)
		
		fill_multimesh.visible_instance_count += 1

func reset() -> void:
	for lines_multimesh in _lines_multimeshes.values():
		lines_multimesh.visible_instance_count = 0
	
	for fill_multimesh in _fill_multimeshes.values():
		fill_multimesh.visible_instance_count = 0

#region private_functions
func _ensure_lines_mesh(resolution: int, relative_size_top: float) -> void:
	var mesh_key := _get_mesh_key(resolution, relative_size_top)
	
	if !_lines_array_meshes.has(mesh_key):
		var lines_array_mesh := _create_lines_array_mesh(resolution, relative_size_top)
		var lines_multimesh := _create_multimesh(lines_array_mesh)
		var lines_mesh_instance := _create_multi_mesh_instance(lines_multimesh)
		
		_lines_array_meshes[mesh_key] = lines_array_mesh
		_lines_multimeshes[mesh_key] = lines_multimesh
		_lines_multi_mesh_instances[mesh_key] = lines_mesh_instance

func _ensure_fill_mesh(resolution: int, relative_size_top: float) -> void:
	var mesh_key := _get_mesh_key(resolution, relative_size_top)
	
	if !_fill_array_meshes.has(mesh_key):
		var fill_array_mesh := _create_fill_array_mesh(resolution, relative_size_top)
		var fill_multimesh := _create_multimesh(fill_array_mesh)
		var fill_mesh_instance := _create_multi_mesh_instance(fill_multimesh)
		
		_fill_array_meshes[mesh_key] = fill_array_mesh
		_fill_multimeshes[mesh_key] = fill_multimesh
		_fill_multi_mesh_instances[mesh_key] = fill_mesh_instance

func _create_lines_array_mesh(resolution: int, relative_size_top: float) -> ArrayMesh:
	var mesh_data: MeshData
	if relative_size_top == 0.0:
		mesh_data = _create_lines_cone(resolution)
	else:
		mesh_data = _create_lines_cylinder(resolution, relative_size_top)
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	if _lines_material == null:
		_lines_material = _create_lines_material()
	
	array_mesh.surface_set_material(0, _lines_material)
	
	return array_mesh

func _create_fill_array_mesh(resolution: int, relative_size_top: float) -> ArrayMesh:
	var mesh_data: MeshData
	if relative_size_top == 0.0:
		mesh_data = _create_fill_cone(resolution)
	else:
		mesh_data = _create_fill_cylinder(resolution, relative_size_top)
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	if _fill_material == null:
		_fill_material = _create_fill_material()
	
	array_mesh.surface_set_material(0, _fill_material)
	
	return array_mesh

func _create_lines_cylinder(resolution: int, relative_size_top: float) -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(resolution * 2)
	mesh_data.resize_for_lines(resolution * 3)
	
	_set_circle_vertices(mesh_data, 0         , resolution, Vector3(0.0, -0.5, 0.0), 1.0              )
	_set_circle_vertices(mesh_data, resolution, resolution, Vector3(0.0,  0.5, 0.0), relative_size_top)
	
	for segment: int in resolution:
		var top_index := _get_top_vertex_index(resolution, segment)
		var next_top_index := _get_top_vertex_index(resolution, segment + 1)
		var bottom_index := _get_bottom_vertex_index(resolution, segment)
		var next_bottom_index := _get_bottom_vertex_index(resolution, segment + 1)
		
		var line_index := segment * 3
		
		mesh_data.set_line_indices(line_index + 0, top_index, next_top_index)
		mesh_data.set_line_indices(line_index + 1, bottom_index, next_bottom_index)
		mesh_data.set_line_indices(line_index + 2, top_index, bottom_index)
	
	return mesh_data

func _create_lines_cone(resolution: int) -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(resolution + 1)
	mesh_data.resize_for_lines(resolution * 2)
	
	_set_circle_vertices(mesh_data, 0, resolution, Vector3(0.0, -0.5, 0.0), 1.0)
	
	var top_center_index := resolution
	
	mesh_data.set_vertex(top_center_index, Vector3(0.0, 0.5, 0.0))
	
	for segment: int in resolution:
		var bottom_index := _get_bottom_vertex_index(resolution, segment)
		var next_bottom_index := _get_bottom_vertex_index(resolution, segment + 1)
		
		var line_index := segment * 2
		
		mesh_data.set_line_indices(line_index + 0, top_center_index, bottom_index)
		mesh_data.set_line_indices(line_index + 1, bottom_index, next_bottom_index)
	
	return mesh_data

func _create_fill_cylinder(resolution: int, relative_size_top: float) -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(resolution * 2 + 2)
	mesh_data.resize_for_triangles(resolution * 4)
	
	_set_circle_vertices(mesh_data, 0         , resolution, Vector3(0.0, -0.5, 0.0), 1.0              )
	_set_circle_vertices(mesh_data, resolution, resolution, Vector3(0.0,  0.5, 0.0), relative_size_top)
	
	var top_center_index := resolution * 2
	var bottom_center_index := resolution * 2 + 1
	
	mesh_data.set_vertex(top_center_index, Vector3(0.0, 0.5, 0.0))
	mesh_data.set_vertex(bottom_center_index, Vector3(0.0, -0.5, 0.0))
	
	for segment: int in resolution:
		var top_index := _get_top_vertex_index(resolution, segment)
		var next_top_index := _get_top_vertex_index(resolution, segment + 1)
		var bottom_index := _get_bottom_vertex_index(resolution, segment)
		var next_bottom_index := _get_bottom_vertex_index(resolution, segment + 1)
		
		var triangle_index := segment * 4
		
		mesh_data.set_triangle_indices(triangle_index + 0, top_center_index, next_top_index, top_index)
		mesh_data.set_triangle_indices(triangle_index + 1, bottom_center_index, bottom_index, next_bottom_index)
		mesh_data.set_triangle_indices(triangle_index + 2, top_index, next_top_index, next_bottom_index)
		mesh_data.set_triangle_indices(triangle_index + 3, top_index, next_bottom_index, bottom_index)
	
	return mesh_data

func _create_fill_cone(resolution: int) -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(resolution + 2)
	mesh_data.resize_for_triangles(resolution * 2)
	
	_set_circle_vertices(mesh_data, 0, resolution, Vector3(0.0, -0.5, 0.0), 1.0)
	
	var top_center_index := resolution
	var bottom_center_index := resolution + 1
	
	mesh_data.set_vertex(top_center_index, Vector3(0.0, 0.5, 0.0))
	mesh_data.set_vertex(bottom_center_index, Vector3(0.0, -0.5, 0.0))
	
	for segment: int in resolution:
		var bottom_index := _get_bottom_vertex_index(resolution, segment)
		var next_bottom_index := _get_bottom_vertex_index(resolution, segment + 1)
		
		var triangle_index := segment * 2
		
		mesh_data.set_triangle_indices(triangle_index + 0, top_center_index, next_bottom_index, bottom_index)
		mesh_data.set_triangle_indices(triangle_index + 1, bottom_center_index, bottom_index, next_bottom_index)
	
	return mesh_data

func _set_circle_vertices(mesh_data: MeshData, index_offset: int, resolution: int, offset: Vector3, radius: float) -> void:
	var step := TAU / float(resolution)
	
	for segment: int in resolution:
		var angle := float(segment) * step
		var x := cos(angle)
		var z := sin(angle)
		
		mesh_data.set_vertex(index_offset + segment, offset + Vector3(x, 0.0, z) * radius)

func _get_mesh_key(resolution: int, relative_size_top: float) -> Vector2i:
	var rounded_size_top := roundi(relative_size_top * ROUNDING_FACTOR)
	
	return Vector2i(resolution, rounded_size_top)

func _get_top_vertex_index(resolution: int, segment: int) -> int:
	return resolution + posmod(segment, resolution)

func _get_bottom_vertex_index(resolution: int, segment: int) -> int:
	return posmod(segment, resolution)
