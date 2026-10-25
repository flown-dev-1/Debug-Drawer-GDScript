class_name MeshData extends RefCounted

var vertices: PackedVector3Array
var indices: PackedInt32Array

func _init(_vertices: PackedVector3Array, _indices: PackedInt32Array) -> void:
	vertices = _vertices
	indices = _indices

func add_vertex(position: Vector3) -> void:
	vertices.push_back(position)

func add_triangle_indices(a: int, b: int, c: int) -> void:
	indices.push_back(a)
	indices.push_back(b)
	indices.push_back(c)

func add_line_indices(a: int, b: int) -> void:
	indices.push_back(a)
	indices.push_back(b)
