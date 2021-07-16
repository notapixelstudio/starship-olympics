extends ColorRect

signal back

export var title: String = "Options"
export var start_scene: PackedScene
onready var panel: UIOptionPanel = $PanelNormal
onready var banner_info = $CanvasLayer/BannerInfo

onready var container = $Container

func _ready():
	Events.connect("ui_back_menu", self,"back")
	Events.connect("ui_nav_to", self, "nav_to")
	assert( start_scene is PackedScene)
	var instanced_scene = start_scene.instance()
	self.set_content(instanced_scene)
	

var focus_index = 0

var separator = " > "
onready var navbar = [title] # Navbar of title string screen
onready var navbar_scene = []

func back_to_menu():
	emit_signal("back")
	visible = false
	self.set_content(navbar_scene.pop_back())

func _exit_tree():
	# Let's save the changes
	persistance.save_game()

func nav_to(title, menu_scene: UIOptionPanel):
	"""
	will update the navbar and instance the new scene inside the tree
	"""
	var current = navbar_scene[len(navbar_scene)-1]
	remove_child(current)
	self.set_content(menu_scene)
	
func back():
	var current = navbar_scene.pop_back()
	current.queue_free()
	self.set_content(navbar_scene[len(navbar_scene)-1])
	
func _on_Back_pressed():
	if len(navbar) <= 1:
		back_to_menu()
	else:
		back()

func set_content(instanced_scene: UIOptionPanel):
	add_child(instanced_scene)
	navbar_scene.append(instanced_scene)
