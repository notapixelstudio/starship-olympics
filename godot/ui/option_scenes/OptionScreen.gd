extends ColorRect

signal back_at_you # signal that gives the line back to whoever instantiated the option

class_name UIOptions

export var title: String = "Options"
export var start_scene: PackedScene
onready var banner_info = $CanvasLayer/BannerInfo

var focus_index = 0


func _ready():
	Events.connect("ui_back_menu", self,"back")
	Events.connect("ui_nav_to", self, "nav_to")
	assert( start_scene is PackedScene)
	var instanced_scene = start_scene.instance()
	self.set_content(instanced_scene, true, null)
	
var separator = " > "
onready var navbar = [title] # Navbar of title string screen
onready var navbar_scene = []

func back_to_menu():
	emit_signal("back_at_you")
	queue_free()

func _exit_tree():
	# Let's save the changes
	persistance.save_game()

func nav_to(title, menu_scene: UIOptionPanel, extra_args = null):
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
		self.set_content(navbar_scene[len(navbar_scene)-1], false)
	else:
		back_to_menu()

func set_content(instanced_scene: UIOptionPanel, nav_forward: bool, extra_args =  null):
	# extra_args need to be setup before _ready()
	add_child(instanced_scene)
	if extra_args:
		instanced_scene.setup_device(extra_args)
	instanced_scene.get_focus()
	if nav_forward:
		navbar_scene.append(instanced_scene)

