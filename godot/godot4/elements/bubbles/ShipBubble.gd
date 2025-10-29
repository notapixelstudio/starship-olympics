extends Bubble
class_name ShipBubble

@export var player_brain_scene : PackedScene
@export var cpu_brain_scene : PackedScene

var _auto_popping := false


func set_ship(v:Ship) -> void:
	if not v:
		return
		
	_content = v.clone() # save a clone of the given ship as content

func _ready() -> void:
	%ContentSprite2D.texture = _content.get_player().get_ship_image()
	_refresh_auto_popping()
	
func set_auto_popping(v:bool) -> void:
	_auto_popping = v
	_refresh_auto_popping()
	
func _refresh_auto_popping():
	if _auto_popping:
		%Timer.start()
		%HelpCallout.visible = false
	else:
		%Timer.stop()
		%HelpCallout.visible = true

func set_content_rotation(v:float) -> void:
	super(v)
	_content.global_rotation = v
	
func release_content(author) -> void:
	super.release_content(author)
	Events.ship_released.emit.call_deferred(_content, self)
	
func _on_timer_timeout():
	pop()
