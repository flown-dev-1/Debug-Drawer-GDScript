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
	var array_mesh = ArrayMesh.new()
	
	var vertices := PackedVector3Array()
	vertices.resize(2)
	vertices[0] = Vector3(0.0, 0.0, 0.0)
	vertices[1] = Vector3(1.0, 0.0, 0.0)
	
	var indices := PackedInt32Array()
	indices.resize(2)
	indices[0] = 0
	indices[1] = 1
	
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
