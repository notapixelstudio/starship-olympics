extends Position2D

class_name GroupSpawner
tool

export (String, 'slash', 'backslash', 'line', "single", "custom") var pattern = "line" setget _set_pattern

export var spawner_scene: PackedScene
export var element_scene: PackedScene
export var guest_star_scene: PackedScene
export (String, "center", "random") var position_guest_star = "center"

var map_pattern_distance = {
	"line": [Vector2(-300,0), Vector2(-150,0), Vector2(0,0), Vector2(150,0), Vector2(300,0)],
	"backslash": [Vector2(-300,-300),Vector2(-150, -150),Vector2(0,0), Vector2(150,150), Vector2(300,300)],
	"slash": [Vector2(-300, 300), Vector2(-150, 150), Vector2(0,0), Vector2(150, -150), Vector2(300, -300)],
	"single": [Vector2(0,0)]
	}
	
func _set_pattern(v: String):
	pattern = v
	if not is_inside_tree():
		yield(self, "ready")
	self.set_spawners()
	
func set_spawners():
	for n in get_children():
		remove_child(n)
		n.queue_free()
	if pattern != "custom":
		var index_guest_star = -1
		if guest_star_scene:
			if position_guest_star == "center":
				index_guest_star = len(map_pattern_distance[pattern])%2+1
			else:
				index_guest_star = randi()%len(map_pattern_distance[pattern])
		var i = 0
		for pos in map_pattern_distance[pattern]:
			var spawner: SpawnerElement = spawner_scene.instance()
			if i == index_guest_star:
				spawner.element_scene = guest_star_scene
			else:
				spawner.element_scene = self.element_scene
			spawner.position = pos
			add_child(spawner)
			i+=1
			
func _ready():
	# ignore instance if custom
	set_spawners()

func spawn():
	for n in get_children():
		n.spawn()
