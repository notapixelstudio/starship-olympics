tool

extends Position2D
class_name ElementSpawnerGroup


export (String, 'slash', 'backslash', 'line', "vline", "single", "rhombus", "gigarhombus", "farapart", "custom") var pattern = "line" setget _set_pattern

export var spawner_scene: PackedScene
export var element_scene: PackedScene setget _set_element_scene
export var guest_star_scene: PackedScene setget _set_guest_star_scene
export (String, "center", "random") var guest_star_positioning = "center"

var map_pattern_distance = {
	"line": [Vector2(-300,0), Vector2(-150,0), Vector2(0,0), Vector2(150,0), Vector2(300,0)],
	"vline": [Vector2(0,-150), Vector2(0,0), Vector2(0,150)],
	"backslash": [Vector2(-300,-300),Vector2(-150, -150),Vector2(0,0), Vector2(150,150), Vector2(300,300)],
	"slash": [Vector2(-300, 300), Vector2(-150, 150), Vector2(0,0), Vector2(150, -150), Vector2(300, -300)],
	"rhombus": [Vector2(-150, -150), Vector2(-150, 150), Vector2(150, 150), Vector2(150, -150)],
	"gigarhombus": [Vector2(-450, -450), Vector2(-450, 450), Vector2(450, 450), Vector2(450, -450)],
	"farapart": [Vector2(-1350, 0), Vector2(1350, 0)],
	"single": [Vector2(0,0)]
	}
	
func _set_pattern(v: String):
	pattern = v
	if not is_inside_tree():
		yield(self, "ready")
	self.set_spawners()
	
func _set_element_scene(v: PackedScene):
	element_scene = v
	if not is_inside_tree():
		yield(self, "ready")
	self.set_spawners()
	
func _set_guest_star_scene(v: PackedScene):
	guest_star_scene = v
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
			if guest_star_positioning == "center":
				index_guest_star = len(map_pattern_distance[pattern])%2+1
			else:
				index_guest_star = randi()%len(map_pattern_distance[pattern])
		var i = 0
		for pos in map_pattern_distance[pattern]:
			var spawner: ElementSpawner = spawner_scene.instance()
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
