extends ColorRect

signal back

export var panel_normal: PackedScene
export var panel_large: PackedScene
export var title: String = "Options"
onready var container = $Panel/PanelItems/Options
onready var panel = $Panel/PanelItems
onready var navbar_node = $Panel/PanelItems/Navbar
	
	
func _ready():
	Events.connect("nav_to", self, "nav_to")


var focus_index = 0

var separator = " > "
onready var navbar = [title] # Navbar of title string screen

func back_to_menu():
	emit_signal("back")
	visible = false

func enable_all():
	visible = true
	focus_index = 0
	container.get_child(focus_index).grab_focus()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		container.get_child(container.get_child_count()-1).grab_focus()
		back_to_menu()
	if event.is_action_pressed("ui_up"):
		focus_index = clamp(focus_index-1, 0, container.get_child_count() -1)
		
	if event.is_action_pressed("ui_down"):
		focus_index = clamp(focus_index+1, 0, container.get_child_count() -1)
		
func _exit_tree():
	# Let's save the changes
	persistance.save_game()

func nav_to(title, menu_scene: Control):
	"""
	will update the navbar and instance the new scene inside the tree
	"""
	var opt = navbar[len(navbar)-1]
	print("Exiting "+ opt)

	container.visible = false
	panel.add_child(menu_scene)
	panel.move_child(menu_scene, 2)
	container = panel.get_node(title)
	container.visible  = true
	
	navbar.append(title)
	navbar_node.text = global.join_str(navbar, separator)
	
	focus_index = 0
	# resize to standard
	enable_all()

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
