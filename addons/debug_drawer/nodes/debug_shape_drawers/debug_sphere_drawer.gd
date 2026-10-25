@tool
class_name DebugSphereDrawer extends DebugShapeDrawer

#region enums
enum SphereResolution {
	LOWEST = 0,
	LOW = 1,
	MEDIUM = 2,
	HIGH = 3,
	HIGHEST = 4
}

#region references
var _lines_material: Dictionary[int, StandardMaterial3D] = {}
var _lines_array_meshes: Dictionary[int, ArrayMesh] = {}
var _lines_multimeshes: Dictionary[int, MultiMesh] = {}
var _lines_multi_mesh_instances: Dictionary[int, MultiMeshInstance3D] = {}

var _fill_material: Dictionary[int, StandardMaterial3D] = {}
var _fill_array_meshes: Dictionary[int, ArrayMesh] = {}
var _fill_multimeshes: Dictionary[int, MultiMesh] = {}
var _fill_multi_mesh_instances: Dictionary[int, MultiMeshInstance3D] = {}

#region public_functions
func draw(center: Vector3, radius: float, resolution: SphereResolution, line_color: Color, fill_color: Color) -> void:
	resolution = clampi(resolution, SphereResolution.LOWEST, SphereResolution.HIGHEST)
	
	var instance_transform := Transform3D(Basis.from_scale(Vector3.ONE * radius), center)
	
	if line_color.a > 0.0:
		_ensure_lines_resolution(resolution)
		
		var lines_multimesh := _lines_multimeshes[resolution]
		
		if lines_multimesh.visible_instance_count >= lines_multimesh.instance_count:
			_push_too_many_shapes_warning()
		
		lines_multimesh.set_instance_transform(lines_multimesh.visible_instance_count, instance_transform)
		lines_multimesh.set_instance_color(lines_multimesh.visible_instance_count, line_color)
		
		lines_multimesh.visible_instance_count += 1
	
	if fill_color.a > 0.0:
		_ensure_fill_resolution(resolution)
		
		var fill_multimesh := _fill_multimeshes[resolution]
		
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
func _ensure_lines_resolution(resolution: int) -> void:
	if !_lines_array_meshes.has(resolution):
		var lines_material := _create_lines_material()
		var lines_array_mesh := _create_lines_array_mesh(lines_material, resolution)
		var lines_multimesh := _create_multimesh(lines_array_mesh)
		var lines_mesh_instance := _create_multi_mesh_instance(lines_multimesh)
		
		_lines_material[resolution] = lines_material
		_lines_array_meshes[resolution] = lines_array_mesh
		_lines_multimeshes[resolution] = lines_multimesh
		_lines_multi_mesh_instances[resolution] = lines_mesh_instance

func _ensure_fill_resolution(resolution: int) -> void:
	if !_fill_array_meshes.has(resolution):
		var fill_material := _create_fill_material()
		var fill_array_mesh := _create_fill_array_mesh(fill_material, resolution)
		var fill_multimesh := _create_multimesh(fill_array_mesh)
		var fill_mesh_instance := _create_multi_mesh_instance(fill_multimesh)
		
		_fill_material[resolution] = fill_material
		_fill_array_meshes[resolution] = fill_array_mesh
		_fill_multimeshes[resolution] = fill_multimesh
		_fill_multi_mesh_instances[resolution] = fill_mesh_instance

func _create_lines_array_mesh(material: StandardMaterial3D, resolution: int) -> ArrayMesh:
	var mesh_data := _create_ico_sphere(resolution)
	var line_mesh_data := MeshData.new(mesh_data.vertices, PackedInt32Array())
	
	var added_edges: Dictionary[int, bool] = {}
	for index: int in range(0, mesh_data.indices.size(), 3):
		var a := mesh_data.indices[index + 0]
		var b := mesh_data.indices[index + 1]
		var c := mesh_data.indices[index + 2]
		
		_add_line_edge(line_mesh_data, added_edges, a, b)
		_add_line_edge(line_mesh_data, added_edges, b, c)
		_add_line_edge(line_mesh_data, added_edges, c, a)
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = line_mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = line_mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	array_mesh.surface_set_material(0, material)
	
	return array_mesh

func _create_fill_array_mesh(material: StandardMaterial3D, resolution: int) -> ArrayMesh:
	var mesh_data := _create_ico_sphere(resolution)
	
	var array_mesh := ArrayMesh.new()
	
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = mesh_data.vertices
	arrays[Mesh.ARRAY_INDEX] = mesh_data.indices
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	array_mesh.surface_set_material(0, material)
	
	return array_mesh

func _create_ico_sphere(resolution: int) -> MeshData:
	var mesh_data := MeshData.new(PackedVector3Array(), PackedInt32Array())
	
	mesh_data = _add_base_icosahedron(mesh_data)
	
	for subdivision: int in resolution:
		mesh_data = _subdivide(mesh_data)
	
	return mesh_data

func _add_base_icosahedron(mesh_data: MeshData) -> MeshData:
	var phi := (1.0 + sqrt(5.0)) / 2.0
	
	var vertices := mesh_data.vertices
	var indices := mesh_data.indices
	
	mesh_data.add_vertex(Vector3(-1.0,  phi,  0.0).normalized())
	mesh_data.add_vertex(Vector3( 1.0,  phi,  0.0).normalized())
	mesh_data.add_vertex(Vector3(-1.0, -phi,  0.0).normalized())
	mesh_data.add_vertex(Vector3( 1.0, -phi,  0.0).normalized())
	mesh_data.add_vertex(Vector3( 0.0, -1.0,  phi).normalized())
	mesh_data.add_vertex(Vector3( 0.0,  1.0,  phi).normalized())
	mesh_data.add_vertex(Vector3( 0.0, -1.0, -phi).normalized())
	mesh_data.add_vertex(Vector3( 0.0,  1.0, -phi).normalized())
	mesh_data.add_vertex(Vector3( phi,  0.0, -1.0).normalized())
	mesh_data.add_vertex(Vector3( phi,  0.0,  1.0).normalized())
	mesh_data.add_vertex(Vector3(-phi,  0.0, -1.0).normalized())
	mesh_data.add_vertex(Vector3(-phi,  0.0,  1.0).normalized())
	
	mesh_data.add_triangle_indices(0 , 11, 5 )
	mesh_data.add_triangle_indices(0 , 5 , 1 )
	mesh_data.add_triangle_indices(0 , 1 , 7 )
	mesh_data.add_triangle_indices(0 , 7 , 10)
	mesh_data.add_triangle_indices(0 , 10, 11)
	mesh_data.add_triangle_indices(1 , 5 , 9 )
	mesh_data.add_triangle_indices(5 , 11, 4 )
	mesh_data.add_triangle_indices(11, 10, 2 )
	mesh_data.add_triangle_indices(10, 7 , 6 )
	mesh_data.add_triangle_indices(7 , 1 , 8 )
	mesh_data.add_triangle_indices(3 , 9 , 4 )
	mesh_data.add_triangle_indices(3 , 4 , 2 )
	mesh_data.add_triangle_indices(3 , 2 , 6 )
	mesh_data.add_triangle_indices(3 , 6 , 8 )
	mesh_data.add_triangle_indices(3 , 8 , 9 )
	mesh_data.add_triangle_indices(4 , 9 , 5 )
	mesh_data.add_triangle_indices(2 , 4 , 11)
	mesh_data.add_triangle_indices(6 , 2 , 10)
	mesh_data.add_triangle_indices(8 , 6 , 7 )
	mesh_data.add_triangle_indices(9 , 8 , 1 )
	
	return mesh_data

func _subdivide(mesh_data: MeshData) -> MeshData:
	var vertices := mesh_data.vertices
	var indices := mesh_data.indices
	
	var new_indices := PackedInt32Array()
	new_indices.resize(indices.size() * 4)
	
	var new_mesh_data := MeshData.new(vertices, new_indices)
	
	var added_midpoints: Dictionary[int, int] = {}
	for index in range(0, indices.size(), 3):
		var a := indices[index + 0]
		var b := indices[index + 1]
		var c := indices[index + 2]
		
		var ab := _get_midpoint_index(mesh_data, added_midpoints, a, b)
		var bc := _get_midpoint_index(mesh_data, added_midpoints, b, c)
		var ca := _get_midpoint_index(mesh_data, added_midpoints, c, a)
		
		new_mesh_data.add_triangle_indices(a, ab, ca)
		new_mesh_data.add_triangle_indices(b, bc, ab)
		new_mesh_data.add_triangle_indices(c, ca, bc)
		new_mesh_data.add_triangle_indices(ab, bc, ca)
	
	return new_mesh_data

func _get_midpoint_index(mesh_data: MeshData, added_midpoints: Dictionary[int, int], a: int, b: int) -> int:
	var key := _get_edge_key(a, b)
	
	if added_midpoints.has(key):
		return added_midpoints[key]
	
	var vertices := mesh_data.vertices
	
	var midpoint_position := ((vertices[a] + vertices[b]) * 0.5).normalized()
	mesh_data.add_vertex(midpoint_position)
	
	var midpoint_index := vertices.size() - 1
	added_midpoints[key] = midpoint_index
	
	return midpoint_index

func _add_line_edge(mesh_data: MeshData, added_edges: Dictionary[int, bool], a: int, b: int) -> void:
	var key := _get_edge_key(a, b)
	
	if added_edges.has(key):
		return
	
	added_edges[key] = true
	mesh_data.add_line_indices(a, b)

func _get_edge_key(a: int, b: int) -> int:
	return (mini(a, b) << 32) | maxi(a, b)
