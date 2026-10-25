class_name MeshData extends RefCounted

var vertices: PackedVector3Array
var indices: PackedInt32Array

func _init(_vertices: PackedVector3Array, _indices: PackedInt32Array) -> void:
	vertices = _vertices
	indices = _indices

func resize_for_vertices(amount: int) -> void:
	vertices.resize(amount)

func add_vertex(position: Vector3) -> void:
	vertices.push_back(position)

func set_vertex(index: int, position: Vector3) -> void:
	vertices[index] = position

func resize_for_indices(amount: int) -> void:
	indices.resize(amount)

func resize_for_triangles(amount: int) -> void:
	indices.resize(amount * 3)

func add_triangle_indices(a: int, b: int, c: int) -> void:
	indices.push_back(a)
	indices.push_back(b)
	indices.push_back(c)

func set_triangle_indices(index: int, a: int, b: int, c: int) -> void:
	var triangle_index := index * 3
	
	indices[triangle_index + 0] = a
	indices[triangle_index + 1] = b
	indices[triangle_index + 2] = c

func resize_for_lines(amount: int) -> void:
	indices.resize(amount * 2)

func add_line_indices(a: int, b: int) -> void:
	indices.push_back(a)
	indices.push_back(b)

func set_line_indices(index: int, a: int, b: int) -> void:
	var line_index := index * 2
	
	indices[line_index + 0] = a
	indices[line_index + 1] = b
