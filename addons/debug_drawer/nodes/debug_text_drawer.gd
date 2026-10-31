@tool
class_name DebugTextDrawer extends DebugElementDrawer

#region references
var _count: int = 0
var _current_active_nodes: int = 0
var _labels: Array[Label3D] = []

#region node_events
func _enter_tree() -> void:
	super._enter_tree()
	
	_labels.resize(_max_shape_instances)

#region public_functions
func draw(string: String, position: Vector3, font_size: int, horizontal_alignment: HorizontalAlignment, vertical_alignment: VerticalAlignment) -> void:
	if string.is_empty():
		return
	
	if _count >= _max_shape_instances:
		_push_too_many_shapes_warning()
		return
	
	if _count >= _current_active_nodes:
		_labels[_count] = _create_label()
		
		_current_active_nodes = _count + 1
	
	var label := _labels[_count]
	
	if label.text != string:
		label.text = string
	label.position = position
	label.horizontal_alignment = horizontal_alignment
	label.vertical_alignment = vertical_alignment
	label.font_size = font_size
	
	_count += 1

func reset() -> void:
	while _count < _current_active_nodes:
		_labels[_count].free()
		
		_current_active_nodes -= 1
	
	_count = 0

#region private_functions
func _create_label() -> Label3D:
	var label := Label3D.new()
	
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.alpha_cut = Label3D.ALPHA_CUT_DISCARD
	
	add_child(label)
	
	return label
