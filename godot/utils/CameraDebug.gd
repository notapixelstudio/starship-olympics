extends Node2D

@onready var camera = get_parent().get_parent().get_node('Camera3D')

func _process(delta):
	if camera.debug_mode:
		update()
	
func _draw() -> void:
	if not camera.debug_mode:
		return
		
	draw_rect(camera.get_viewport_rect(), Color("#ff0000"), false)
	draw_rect(camera.viewport_rect, Color("#00ff00"), false)
	draw_circle(camera.calculate_center(camera.viewport_rect), 10, Color(0,1,1,0.4))
	draw_rect(Rect2(camera.world_to_screen(Vector2(-50,-50)),Vector2(100,100)/camera.zoom), Color(1,0,0,0.4), true)
	