@tool
class_name DebugLineDrawer extends DebugShapeDrawer

#region references
var _lines_array_mesh: ArrayMesh = null
var _lines_multimesh: MultiMesh = null
var _lines_multi_mesh_instance: MultiMeshInstance3D = null

#region node_events
func _enter_tree() -> void:
	super._enter_tree()
	
	if _lines_array_mesh == null:
		_lines_array_mesh = _create_lines_array_mesh()
		_lines_multimesh = _create_multimesh(_lines_array_mesh)
		_lines_multi_mesh_instance = _create_multi_mesh_instance(_lines_multimesh)

#region public_functions
func draw(start: Vector3, end: Vector3, line_color: Color) -> void:
	if line_color.a <= 0.0:
		return
	
	if _lines_multimesh.visible_instance_count >= _lines_multimesh.instance_count:
		_push_too_many_shapes_warning()
	
	var offset := end - start
	var instance_transform := Transform3D(Basis(offset, Vector3.ZERO, Vector3.ZERO), start)
	
	_lines_multimesh.set_instance_transform(_lines_multimesh.visible_instance_count, instance_transform)
	_lines_multimesh.set_instance_color(_lines_multimesh.visible_instance_count, line_color)
	
	_lines_multimesh.visible_instance_count += 1

func reset() -> void:
	_lines_multimesh.visible_instance_count = 0

#region private_functions
func _create_lines_array_mesh() -> ArrayMesh:
	var mesh_data := _create_lines_line()
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	var material := _create_lines_material()
	
	array_mesh.surface_set_material(0, material)
	
	return array_mesh

func _create_lines_line() -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	mesh_data.resize_for_vertices(2)
	mesh_data.resize_for_lines(1)
	
	mesh_data.set_vertex(0, Vector3(0.0, 0.0, 0.0))
	mesh_data.set_vertex(1, Vector3(1.0, 0.0, 0.0))
	
	mesh_data.set_line_indices(0, 0, 1)
	
	return mesh_data
