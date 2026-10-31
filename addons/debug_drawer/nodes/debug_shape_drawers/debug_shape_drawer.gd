@tool
class_name DebugShapeDrawer extends DebugElementDrawer

#region private_functions
func _create_multi_mesh_instance(multimesh: MultiMesh) -> MultiMeshInstance3D:
	var multi_mesh_instance = MultiMeshInstance3D.new()
	add_child(multi_mesh_instance, false, Node.INTERNAL_MODE_FRONT)
	
	multi_mesh_instance.multimesh = multimesh
	
	return multi_mesh_instance

func _create_multimesh(array_mesh: ArrayMesh, use_custom_data: bool = false) -> MultiMesh:
	var multimesh = MultiMesh.new()
	
	multimesh.mesh = array_mesh
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.use_custom_data = use_custom_data
	multimesh.instance_count = _max_shape_instances
	multimesh.visible_instance_count = 0
	
	return multimesh

func _create_lines_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	
	return material

func _create_fill_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	return material

func _create_shader_material(shader: Shader) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	
	material.shader = shader
	
	return material
