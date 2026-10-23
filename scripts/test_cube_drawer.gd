@tool
extends Node

#region exports
@export var debug_drawer: DebugDrawer = null

#region node_events
func _process(_delta: float) -> void:
	debug_drawer.draw_cube(Vector3.ZERO, Vector3.ONE, Color.RED, Color(1.0, 0.0, 0.0, 0.2))
	debug_drawer.draw_cube(Vector3(-0.5, 0.0, -2.0), Vector3(2.0, 1.0, 1.0), Color.AQUA, Color(0.0, 1.0, 1.0, 0.2))
	
	#for i: int in range(1024):
		#debug_drawer.draw_cube( \
			#Vector3(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0), randf_range(-10.0, 10.0)), \
			#Vector3(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0), randf_range(-10.0, 10.0)), \
			#Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0), 1.0), \
			#Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0)) \
		#)
