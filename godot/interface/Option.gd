extends ColorRect

signal back

export var title: String = "Options"
export var start_scene: PackedScene
onready var panel: UIOptionPanel = $PanelNormal
onready var banner_info = $CanvasLayer/BannerInfo
	
func _ready():
	Events.connect("nav_to", self, "nav_to")
	assert( start_scene is PackedScene)
	set_content(start_scene)
	navbar_scene.append(start_scene)

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

func nav_to(title, menu_scene: PackedScene):
	"""
	will update the navbar and instance the new scene inside the tree
	"""
	var opt = navbar[len(navbar)-1]
	print("Exiting "+ opt)
	navbar.append(title)
	self.set_content(menu_scene)
	
func back():
	var opt = navbar.pop_back()
	
	
	
func _on_Back_pressed():
	if len(navbar) <= 1:
		back_to_menu()
	else:
		back()

func set_content(scene: PackedScene):
	var instance: OptionContainer = scene.instance()
	var panel_type = instance.panel_type
	for option_panel in get_tree().get_nodes_in_group("UIOptionPanel"):
		option_panel.visible = false
	for info in banner_info.get_children():
		info.queue_free()
		
	if panel_type == "normal":
		panel = $PanelNormal
	elif panel_type == "large":
		panel = $PanelLarge
	panel.visible = true
	panel.set_content(instance)
	
	if instance.banner_info:
		banner_info.add_child(instance.banner_info.instance())
