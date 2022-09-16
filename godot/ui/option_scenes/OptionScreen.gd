extends ColorRect

class_name UIOptions

signal back_at_you # signal that gives the line back to whoever instantiated the option

@export var title: String = "Options"
@export var start_scene: PackedScene
@onready var banner_info = $CanvasLayer/BannerInfo

var focus_index = 0


func _ready():
	Events.connect("ui_back_menu",Callable(self,"back"))
	Events.connect("ui_nav_to",Callable(self,"nav_to"))
	assert( start_scene is PackedScene)
	var instanced_scene = start_scene.instantiate()
	self.set_content(instanced_scene, true, {})
	
var separator = " > "
@onready var navbar = [title] # Navbar of title string screen
@onready var navbar_scene = []

func back_to_menu():
	emit_signal("back_at_you")
	queue_free()

func _exit_tree():
	# Let's save the changes
	persistance.save_game()

func nav_to(title: String, menu_scene: UIOptionPanel, extra_args: Dictionary):
	"""
	will update the navbar and instance the new scene inside the tree
	"""
	var current = navbar_scene[len(navbar_scene)-1]
	remove_child(current)
	self.set_content(menu_scene, true, extra_args)
	
func back():
	var current = navbar_scene.pop_back()
	current.queue_free()
	if len(navbar_scene) >= 1:
		self.set_content(navbar_scene[len(navbar_scene)-1], false, {})
	else:
		back_to_menu()

func set_content(instanced_scene: UIOptionPanel, nav_forward: bool, extra_args: Dictionary):
	# extra_args need to be setup before _ready()
	if extra_args:
		for key in extra_args:
			instanced_scene.set(key, extra_args[key])
	add_child(instanced_scene)
	instanced_scene.get_focus()
	if nav_forward:
		navbar_scene.append(instanced_scene)

