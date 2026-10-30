@tool
class_name DebugCylinderDrawer extends DebugShapeDrawer

#region constants
const SHADER: Shader = preload("res://addons/debug_drawer/shaders/cylinder.gdshader")
const MIN_RESOLUTION: int = 3

#region references
var _material: ShaderMaterial = null

var _lines_dirty: Dictionary[int, bool] = {}
var _lines_counts: Dictionary[int, int] = {}
var _lines_array_meshes: Dictionary[int, ArrayMesh] = {}
var _lines_multimeshes: Dictionary[int, MultiMesh] = {}
var _lines_multi_mesh_instances: Dictionary[int, MultiMeshInstance3D] = {}

var _fill_dirty: Dictionary[int, bool] = {}
var _fill_counts: Dictionary[int, int] = {}
var _fill_array_meshes: Dictionary[int, ArrayMesh] = {}
var _fill_multimeshes: Dictionary[int, MultiMesh] = {}
var _fill_multi_mesh_instances: Dictionary[int, MultiMeshInstance3D] = {}

#region public_functions
func draw(center: Vector3, height: float, top_radius: float, bottom_radius: float, rotation: Quaternion, resolution: int, line_color: Color, fill_color: Color) -> void:
	if height == 0.0 || (top_radius == 0.0 && bottom_radius == 0.0):
		return
	
	resolution = maxi(resolution, MIN_RESOLUTION)

	var instance_transform := Transform3D(Basis(rotation).scaled_local(Vector3(1.0, height, 1.0)), center)
	var instance_custom_data := Color(top_radius, bottom_radius, 0.0, 0.0)
	
	if line_color.a > 0.0:
		if !_lines_array_meshes.has(resolution):
			_create_lines_resolution(resolution)
		
		_lines_dirty[resolution] = false
		
		var lines_multimesh := _lines_multimeshes[resolution]
		var lines_count := _lines_counts[resolution]
		
		if lines_count >= _max_shape_instances:
			_push_too_many_shapes_warning()
		
		lines_multimesh.set_instance_transform(lines_count, instance_transform)
		lines_multimesh.set_instance_color(lines_count, line_color)
		lines_multimesh.set_instance_custom_data(lines_count, instance_custom_data)
		
		_lines_counts[resolution] = lines_count + 1
	
	if fill_color.a > 0.0:
		if !_fill_array_meshes.has(resolution):
			_create_fill_resolution(resolution)
		
		_fill_dirty[resolution] = false
		
		var fill_multimesh := _fill_multimeshes[resolution]
		var fill_count := _fill_counts[resolution]
		
		if fill_count >= _max_shape_instances:
			_push_too_many_shapes_warning()
		
		fill_multimesh.set_instance_transform(fill_count, instance_transform)
		fill_multimesh.set_instance_color(fill_count, fill_color)
		fill_multimesh.set_instance_custom_data(fill_count, instance_custom_data)
		
		_fill_counts[resolution] = fill_count + 1

func finalize() -> void:
	for resolution: int in _lines_multimeshes.keys():
		_lines_multimeshes[resolution].visible_instance_count = _lines_counts[resolution]
	
	for resolution: int in _fill_multimeshes.keys():
		_fill_multimeshes[resolution].visible_instance_count = _fill_counts[resolution]

func reset() -> void:
	for resolution: int in _lines_dirty.keys():
		if _lines_dirty[resolution]:
			_lines_multi_mesh_instances[resolution].free()
			
			_lines_dirty.erase(resolution)
			_lines_counts.erase(resolution)
			_lines_array_meshes.erase(resolution)
			_lines_multimeshes.erase(resolution)
			_lines_multi_mesh_instances.erase(resolution)
		else:
			_lines_counts[resolution] = 0
			_lines_dirty[resolution] = true
	
	for resolution: int in _fill_dirty.keys():
		if _fill_dirty[resolution]:
			_fill_multi_mesh_instances[resolution].free()
			
			_fill_dirty.erase(resolution)
			_fill_counts.erase(resolution)
			_fill_array_meshes.erase(resolution)
			_fill_multimeshes.erase(resolution)
			_fill_multi_mesh_instances.erase(resolution)
		else:
			_fill_counts[resolution] = 0
			_fill_dirty[resolution] = true

#region private_functions
func _create_lines_resolution(resolution: int) -> void:
	var lines_array_mesh := _create_lines_array_mesh(resolution)
	var lines_multimesh := _create_multimesh(lines_array_mesh, true)
	var lines_mesh_instance := _create_multi_mesh_instance(lines_multimesh)
	
	_lines_counts[resolution] = 0
	_lines_array_meshes[resolution] = lines_array_mesh
	_lines_multimeshes[resolution] = lines_multimesh
	_lines_multi_mesh_instances[resolution] = lines_mesh_instance

func _create_fill_resolution(resolution: int) -> void:
	var fill_array_mesh := _create_fill_array_mesh(resolution)
	var fill_multimesh := _create_multimesh(fill_array_mesh, true)
	var fill_mesh_instance := _create_multi_mesh_instance(fill_multimesh)
	
	_fill_counts[resolution] = 0
	_fill_array_meshes[resolution] = fill_array_mesh
	_fill_multimeshes[resolution] = fill_multimesh
	_fill_multi_mesh_instances[resolution] = fill_mesh_instance

func _create_lines_array_mesh(resolution: int) -> ArrayMesh:
	var mesh_data := _create_lines_cylinder(resolution)
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	if _material == null:
		_material = _create_shader_material(SHADER)
	
	array_mesh.surface_set_material(0, _material)
	
	return array_mesh

func _create_fill_array_mesh(resolution: int) -> ArrayMesh:
	var mesh_data := _create_fill_cylinder(resolution)
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	if _material == null:
		_material = _create_shader_material(SHADER)
	
	array_mesh.surface_set_material(0, _material)
	
	return array_mesh

func _create_lines_cylinder(resolution: int) -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(resolution * 2)
	mesh_data.resize_for_lines(resolution * 3)
	
	_set_circle_vertices(mesh_data, 0         , resolution, Vector3(0.0, -0.5, 0.0), 1.0)
	_set_circle_vertices(mesh_data, resolution, resolution, Vector3(0.0,  0.5, 0.0), 1.0)
	
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

func _create_fill_cylinder(resolution: int) -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(resolution * 2 + 2)
	mesh_data.resize_for_triangles(resolution * 4)
	
	_set_circle_vertices(mesh_data, 0         , resolution, Vector3(0.0, -0.5, 0.0), 1.0)
	_set_circle_vertices(mesh_data, resolution, resolution, Vector3(0.0,  0.5, 0.0), 1.0)
	
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

func _set_circle_vertices(mesh_data: MeshData, index_offset: int, resolution: int, offset: Vector3, radius: float) -> void:
	var step := TAU / float(resolution)
	
	for segment: int in resolution:
		var angle := float(segment) * step
		var x := cos(angle)
		var z := sin(angle)
		
		mesh_data.set_vertex(index_offset + segment, offset + Vector3(x, 0.0, z) * radius)

func _get_top_vertex_index(resolution: int, segment: int) -> int:
	return resolution + posmod(segment, resolution)

func _get_bottom_vertex_index(resolution: int, segment: int) -> int:
	return posmod(segment, resolution)
