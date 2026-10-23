@tool
class_name DebugShapeDrawer extends Node3D

#region private_functions
func _create_multi_mesh_instance(multimesh: MultiMesh) -> MultiMeshInstance3D:
	var multi_mesh_instance = MultiMeshInstance3D.new()
	add_child(multi_mesh_instance, false, Node.INTERNAL_MODE_FRONT)
	
	multi_mesh_instance.multimesh = multimesh
	
	return multi_mesh_instance

func _create_multimesh(array_mesh: ArrayMesh, max_shape_instances: int) -> MultiMesh:
	var multimesh = MultiMesh.new()
	
	multimesh.mesh = array_mesh
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.instance_count = max_shape_instances
	multimesh.visible_instance_count = 0
	
	return multimesh
