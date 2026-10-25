@tool
class_name DebugCubeDrawer extends DebugShapeDrawer

#region references
var _lines_array_mesh: ArrayMesh = null
var _lines_multimesh: MultiMesh = null
var _lines_multi_mesh_instance: MultiMeshInstance3D = null

var _fill_array_mesh: ArrayMesh = null
var _fill_multimesh: MultiMesh = null
var _fill_multi_mesh_instance: MultiMeshInstance3D = null

#region node_events
func _enter_tree() -> void:
	super._enter_tree()
	
	if _lines_array_mesh == null:
		_lines_array_mesh = _create_lines_array_mesh()
		_lines_multimesh = _create_multimesh(_lines_array_mesh)
		_lines_multi_mesh_instance = _create_multi_mesh_instance(_lines_multimesh)
	
	if _fill_array_mesh == null:
		_fill_array_mesh = _create_fill_array_mesh()
		_fill_multimesh = _create_multimesh(_fill_array_mesh)
		_fill_multi_mesh_instance = _create_multi_mesh_instance(_fill_multimesh)

#region public_functions
func draw(min_point: Vector3, size: Vector3, line_color: Color, fill_color: Color) -> void:
	if _lines_multimesh.visible_instance_count >= _lines_multimesh.instance_count:
		_push_too_many_shapes_warning()
	
	var instance_transform := Transform3D(Basis.from_scale(size), min_point)
	
	if line_color.a > 0.0:
		_lines_multimesh.set_instance_transform(_lines_multimesh.visible_instance_count, instance_transform)
		_lines_multimesh.set_instance_color(_lines_multimesh.visible_instance_count, line_color)
		
		_lines_multimesh.visible_instance_count += 1
	
	if fill_color.a > 0.0:
		_fill_multimesh.set_instance_transform(_fill_multimesh.visible_instance_count, instance_transform)
		_fill_multimesh.set_instance_color(_fill_multimesh.visible_instance_count, fill_color)
		
		_fill_multimesh.visible_instance_count += 1

func reset() -> void:
	_lines_multimesh.visible_instance_count = 0
	_fill_multimesh.visible_instance_count = 0

#region private_functions
func _create_lines_array_mesh() -> ArrayMesh:
	var mesh_data := _create_lines_cube()
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	var material := _create_lines_material()
	
	array_mesh.surface_set_material(0, material)
	
	return array_mesh

func _create_fill_array_mesh() -> ArrayMesh:
	var mesh_data := _create_fill_cube()
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var material := _create_fill_material()
	
	array_mesh.surface_set_material(0, material)
	
	return array_mesh

func _create_lines_cube() -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(8)
	mesh_data.resize_for_lines(12)
	
	mesh_data.set_vertex(0, Vector3(0.0, 0.0, 0.0))
	mesh_data.set_vertex(1, Vector3(1.0, 0.0, 0.0))
	mesh_data.set_vertex(2, Vector3(0.0, 1.0, 0.0))
	mesh_data.set_vertex(3, Vector3(1.0, 1.0, 0.0))
	mesh_data.set_vertex(4, Vector3(0.0, 0.0, 1.0))
	mesh_data.set_vertex(5, Vector3(1.0, 0.0, 1.0))
	mesh_data.set_vertex(6, Vector3(0.0, 1.0, 1.0))
	mesh_data.set_vertex(7, Vector3(1.0, 1.0, 1.0))
	
	mesh_data.set_line_indices(0 , 0, 1)
	mesh_data.set_line_indices(1 , 0, 2)
	mesh_data.set_line_indices(2 , 1, 3)
	mesh_data.set_line_indices(3 , 2, 3)
	mesh_data.set_line_indices(4 , 4, 5)
	mesh_data.set_line_indices(5 , 4, 6)
	mesh_data.set_line_indices(6 , 5, 7)
	mesh_data.set_line_indices(7 , 6, 7)
	mesh_data.set_line_indices(8 , 0, 4)
	mesh_data.set_line_indices(9 , 1, 5)
	mesh_data.set_line_indices(10, 2, 6)
	mesh_data.set_line_indices(11, 3, 7)
	
	return mesh_data

func _create_fill_cube() -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(8)
	mesh_data.resize_for_triangles(6 * 2)
	
	mesh_data.set_vertex(0, Vector3(0.0, 0.0, 0.0))
	mesh_data.set_vertex(1, Vector3(1.0, 0.0, 0.0))
	mesh_data.set_vertex(2, Vector3(0.0, 1.0, 0.0))
	mesh_data.set_vertex(3, Vector3(1.0, 1.0, 0.0))
	mesh_data.set_vertex(4, Vector3(0.0, 0.0, 1.0))
	mesh_data.set_vertex(5, Vector3(1.0, 0.0, 1.0))
	mesh_data.set_vertex(6, Vector3(0.0, 1.0, 1.0))
	mesh_data.set_vertex(7, Vector3(1.0, 1.0, 1.0))
	
	_create_fill_face(mesh_data, 0, 0, 1, 2, 3)
	_create_fill_face(mesh_data, 1, 5, 4, 7, 6)
	_create_fill_face(mesh_data, 2, 4, 0, 6, 2)
	_create_fill_face(mesh_data, 3, 1, 5, 3, 7)
	_create_fill_face(mesh_data, 4, 2, 3, 6, 7)
	_create_fill_face(mesh_data, 5, 1, 0, 5, 4)
	
	return mesh_data

func _create_fill_face(mesh_data: MeshData, face_index: int, bottom_left: int, bottom_right: int, top_left: int, top_right: int) -> void:
	mesh_data.set_triangle_indices(face_index * 2 + 0, bottom_left, bottom_right, top_right)
	mesh_data.set_triangle_indices(face_index * 2 + 1, bottom_left, top_right, top_left)
