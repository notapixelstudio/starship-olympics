extends RigidBody2D

@export var texture : Texture : set = set_texture
@export var shard_scene : PackedScene

## adapted from: https://www.reddit.com/r/godot/comments/nimkqg/how_to_break_a_2d_sprite_in_a_cool_and_easy_way

## Number of break points.
@export_range(0, 20) var number_of_shards: int = 5

## Prevents slim triangles being created at the sprite edges.
@export var threshold: float = 20.0

## How long the shards live.
@export var lifetime: float = 5.0


@onready var _ctx = ArenaScope.get_scope(self)


func set_texture(v: Texture) -> void:
	texture = v
	%Sprite2D.texture = v

func _ready() -> void:
	var rect = %Sprite2D.get_rect()
	var points = []
	
	# add outer frame points
	points.append(rect.position)
	points.append(rect.position + Vector2(rect.size.x, 0))
	points.append(rect.position + Vector2(0, rect.size.y))
	points.append(rect.end)

	#add random break points
	for i in number_of_shards:
		var p = rect.position + Vector2(randi_range(0, rect.size.x), randi_range(0, rect.size.y))
		# move outer points onto rectangle edges
		if p.x < rect.position.x + threshold:
			p.x = rect.position.x
		elif p.x > rect.end.x - threshold:
			p.x = rect.end.x
		if p.y < rect.position.y + threshold:
			p.y = rect.position.y
		elif p.y > rect.end.y - threshold:
			p.y = rect.end.y
		points.append(p)

	# calculate triangles
	var delaunay = Geometry2D.triangulate_delaunay(points)
	var triangles = []
	for i in range(0, delaunay.size(), 3):
		triangles.append([points[delaunay[i + 2]], points[delaunay[i + 1]], points[delaunay[i]]])

	# create Shards
	for t in triangles:
		var center = Vector2((t[0].x + t[1].x + t[2].x)/3.0,(t[0].y + t[1].y + t[2].y)/3.0)

		var shard = shard_scene.instantiate()
		shard.global_position = global_position
		shard.global_rotation = global_rotation
		shard.linear_velocity = linear_velocity/2.0 + 8.0*(center-t[0])
		shard.set_texture(texture)
		shard.set_polygon(t)
		
		_ctx.spawn_request.emit.call_deferred(shard)
	
	queue_free()
