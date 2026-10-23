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
	var array_mesh = ArrayMesh.new()
	
	var vertices := PackedVector3Array()
	vertices.resize(8)
	vertices[0] = Vector3(0.0, 0.0, 0.0)
	vertices[1] = Vector3(1.0, 0.0, 0.0)
	vertices[2] = Vector3(0.0, 1.0, 0.0)
	vertices[3] = Vector3(1.0, 1.0, 0.0)
	vertices[4] = Vector3(0.0, 0.0, 1.0)
	vertices[5] = Vector3(1.0, 0.0, 1.0)
	vertices[6] = Vector3(0.0, 1.0, 1.0)
	vertices[7] = Vector3(1.0, 1.0, 1.0)
	
	var indices := PackedInt32Array()
	indices.resize(12 * 2)
	indices[0] = 0
	indices[1] = 1
	indices[2] = 0
	indices[3] = 2
	indices[4] = 1
	indices[5] = 3
	indices[6] = 2
	indices[7] = 3
	indices[8] = 4
	indices[9] = 5
	indices[10] = 4
	indices[11] = 6
	indices[12] = 5
	indices[13] = 7
	indices[14] = 6
	indices[15] = 7
	indices[16] = 0
	indices[17] = 4
	indices[18] = 1
	indices[19] = 5
	indices[20] = 2
	indices[21] = 6
	indices[22] = 3
	indices[23] = 7
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	
	array_mesh.surface_set_material(0, material)
	
	return array_mesh

func _create_fill_array_mesh() -> ArrayMesh:
	var array_mesh = ArrayMesh.new()
	
	var vertices := PackedVector3Array()
	vertices.resize(8)
	vertices[0] = Vector3(0.0, 0.0, 0.0)
	vertices[1] = Vector3(1.0, 0.0, 0.0)
	vertices[2] = Vector3(0.0, 1.0, 0.0)
	vertices[3] = Vector3(1.0, 1.0, 0.0)
	vertices[4] = Vector3(0.0, 0.0, 1.0)
	vertices[5] = Vector3(1.0, 0.0, 1.0)
	vertices[6] = Vector3(0.0, 1.0, 1.0)
	vertices[7] = Vector3(1.0, 1.0, 1.0)
	
	var indices := PackedInt32Array()
	indices.resize(6 * 2 * 3)
	_create_fill_face(indices, 0 * 6, 0, 1, 2, 3)
	_create_fill_face(indices, 1 * 6, 5, 4, 7, 6)
	_create_fill_face(indices, 2 * 6, 4, 0, 6, 2)
	_create_fill_face(indices, 3 * 6, 1, 5, 3, 7)
	_create_fill_face(indices, 4 * 6, 2, 3, 6, 7)
	_create_fill_face(indices, 5 * 6, 1, 0, 5, 4)
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	array_mesh.surface_set_material(0, material)
	
	return array_mesh

func _create_fill_face(indices: PackedInt32Array, offset: int, bottom_left: int, bottom_right: int, top_left: int, top_right: int) -> void:
	indices[offset + 0] = bottom_left
	indices[offset + 1] = bottom_right
	indices[offset + 2] = top_right
	indices[offset + 3] = bottom_left
	indices[offset + 4] = top_right
	indices[offset + 5] = top_left
