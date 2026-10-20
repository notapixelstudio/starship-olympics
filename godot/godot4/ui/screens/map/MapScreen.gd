extends BackScreen

@export var next_screen : PackedScene


func _ready() -> void:
	get_viewport().size_changed.connect(_fit_map_view)
	_fit_map_view()

# render the map at native window pixels (not a 1280x720 texture upscaled), keeping the same 2D framing
func _fit_map_view() -> void:
	var stretch := get_viewport().get_final_transform().get_scale()
	var canvas_size := get_viewport().get_visible_rect().size
	$MapView/SubViewport.size = Vector2i(canvas_size * stretch)
	$MapView/SubViewport.size_2d_override = Vector2i(canvas_size)
	$MapView/SubViewport.size_2d_override_stretch = true
	$MapView.scale = Vector2.ONE / stretch

func _on_map_arena_done() -> void:
	next.emit(next_screen.instantiate())
