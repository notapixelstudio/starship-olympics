@tool

extends Node2D
class_name ElementSpawner

@export var element_scene: PackedScene: set = set_element_scene

const JITTER = 1.0

@onready var _ctx := ArenaScope.get_scope(self)

func set_element_scene(v: PackedScene):
	element_scene = v
	if not is_inside_tree():
		await self.ready
	refresh_preview()
	
func refresh_preview():
	# in editor, just use the element's sprite texture instead of the actual element
	if Engine.is_editor_hint():
		var element = element_scene.instantiate()
		assert(element is Collectable)
		$PreviewSprite.texture = element.get_node('Graphics/Sprite2D').texture # WARNING can't use get_texture() unless all scripts are tool
		element.queue_free()
	else:
		$PreviewSprite.queue_free()
		
func spawn():
	var element = element_scene.instantiate()
	var where_to_spawn = global_position + Vector2(randfn(0.0,JITTER),randfn(0.0,JITTER))
	
	var appear
	if element.has_method('create_appear_effect'): # WARNING duck typing
		appear = element.create_appear_effect()
		appear.global_position = where_to_spawn
		_ctx.spawn_request.emit(appear)
		await appear.done
		
	element.global_position = where_to_spawn
	_ctx.spawn_request.emit(element, func(el):
		# spawn request defers the element insertion, so we continue execution in a callback
		if appear and appear.was_touched():
			# trigger a fake high-level touch collision
			_ctx.collision.emit(appear.get_toucher(), el, 'touch')
		
		if traits.has_trait(el, 'Waiter'):
			el.start()
	)
	
func remove_child(element):
	super.remove_child(element)
	element.queue_free()
