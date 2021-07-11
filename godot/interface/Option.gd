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

var focus_index = 0

var separator = " > "
onready var navbar = [title] # Navbar of title string screen

func back_to_menu():
	emit_signal("back")
	visible = false

func _exit_tree():
	# Let's save the changes
	persistance.save_game()

func nav_to(title, menu_scene: Control):
	"""
	will update the navbar and instance the new scene inside the tree
	"""
	var opt = navbar[len(navbar)-1]
	print("Exiting "+ opt)

	panel.add_child(menu_scene)
	panel.move_child(menu_scene, 2)
	container = panel.get_node(title)
	container.visible  = true
	
	navbar.append(title)
	navbar_node.text = global.join_str(navbar, separator)
	
	focus_index = 0


func back():
	var opt = navbar.pop_back()
	container.queue_free()
	container = panel.get_node(navbar[len(navbar)-1])
	container.visible = true
	
	# this will reset panel size
	panel.visible = false
	yield(get_tree(), "idle_frame")
	panel.call_deferred("set_visible", true)
	
	navbar_node.text = global.join_str(navbar, separator)
	
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
