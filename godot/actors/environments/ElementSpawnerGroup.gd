@tool

extends Marker2D
class_name ElementSpawnerGroup


@export_enum('slash', 'backslash', 'line', 'bigline', "vline", "single", "plus", "rhombus", "gigarhombus", "zig", "zag", "apart", "vapart", "farapart", "doublefarapart", "triplefarapart", "veryfarapart", "farslash", "farbackslash", "custom") var pattern = "line": set = _set_pattern

@export var spawner_scene: PackedScene
@export var element_scene: PackedScene: set = _set_element_scene
@export var guest_star_scene: PackedScene: set = _set_guest_star_scene
@export_enum("center", "random", "half") var guest_star_positioning = "center"

var map_pattern_distance = {
	"line": [Vector2(-300,0), Vector2(-150,0), Vector2(0,0), Vector2(150,0), Vector2(300,0)],
	"bigline": [Vector2(-600,0), Vector2(0,0), Vector2(600,0)],
	"vline": [Vector2(0,-150), Vector2(0,0), Vector2(0,150)],
	"backslash": [Vector2(-300,-300),Vector2(-150, -150),Vector2(0,0), Vector2(150,150), Vector2(300,300)],
	"slash": [Vector2(-300, 300), Vector2(-150, 150), Vector2(0,0), Vector2(150, -150), Vector2(300, -300)],
	"plus": [Vector2(0,-150), Vector2(-150,0), Vector2(0,0), Vector2(150,0), Vector2(0,150)],
	"rhombus": [Vector2(-150, -150), Vector2(-150, 150), Vector2(150, 150), Vector2(150, -150)],
	"gigarhombus": [Vector2(-450, -450), Vector2(-450, 450), Vector2(450, 450), Vector2(450, -450)],
	"zig": [Vector2(-300, 0), Vector2(-150, -150), Vector2(0, 0), Vector2(150, 150), Vector2(300, 0)],
	"zag": [Vector2(-300, 0), Vector2(-150, 150), Vector2(0, 0), Vector2(150, -150), Vector2(300, 0)],
	"apart": [Vector2(-900, 0), Vector2(900, 0)],
	"vapart": [Vector2(0, -900), Vector2(0, 900)],
	"farapart": [Vector2(-1350, 0), Vector2(1350, 0)],
	"doublefarapart": [Vector2(-1350, -150), Vector2(-1350, 150), Vector2(1350, -150), Vector2(1350, 150)],
	"triplefarapart": [Vector2(-1350, -150), Vector2(-1350, 0), Vector2(-1350, 150), Vector2(1350, -150), Vector2(1350, 0), Vector2(1350, 150)],
	"veryfarapart": [Vector2(-2250, 0), Vector2(2250, 0)],
	"farslash": [Vector2(-900, -450), Vector2(900, 450)],
	"farbackslash": [Vector2(-900, 450), Vector2(900, -450)],
	"single": [Vector2(0,0)]
	}
	
func _set_pattern(v: String):
	pattern = v
	if not is_inside_tree():
		await self.ready
	self.set_spawners()
	
func _set_element_scene(v: PackedScene):
	element_scene = v
	if not is_inside_tree():
		await self.ready
	self.set_spawners()
	
func _set_guest_star_scene(v: PackedScene):
	guest_star_scene = v
	if not is_inside_tree():
		await self.ready
	self.set_spawners()
	
func set_spawners():
	for n in get_children():
		remove_child(n)
		n.queue_free()
	if pattern != "custom":
		var index_guest_star = -1
		if guest_star_scene:
			if guest_star_positioning == "center":
				index_guest_star = floor(len(map_pattern_distance[pattern]))/2
			elif guest_star_positioning == "random":
				index_guest_star = randi()%len(map_pattern_distance[pattern])
				
		# in half mode, invert the displacement half the time
		var positions = map_pattern_distance[pattern]
		if guest_star_positioning == "half" and randf() >= 0.5:
			positions.invert()
			
		var i = 0
		for pos in positions:
			var spawner: ElementSpawner = spawner_scene.instantiate()
			if i == index_guest_star or (guest_star_positioning == "half" and i >= len(positions)/2):
				spawner.element_scene = guest_star_scene
			else:
				spawner.element_scene = self.element_scene
			spawner.position = pos
			add_child(spawner)
			i+=1
			
func _ready():
	# ignore instance if custom
	set_spawners()

func spawn(parent_node = null):
	if parent_node == null:
		parent_node = get_parent()
	for n in get_children():
		n.spawn(parent_node)
