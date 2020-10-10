extends ColorRect

signal back

onready var container = $OptionScreen/PanelItems/Options
onready var panel = $OptionScreen/PanelItems

var focus_index = 0

var separator = " > "
var navbar = ["Options"]

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
		#container.get_child(focus_index).grab_focus()
		
	if event.is_action_pressed("ui_down"):
		focus_index = clamp(focus_index+1, 0, container.get_child_count() -1)
		#container.get_child(focus_index).grab_focus()
		
func _exit_tree():
	# Let's save the changes
	persistance.save_game()

func nav_to(title):
	var opt = navbar[len(navbar)-1]
	container.visible = false
	container = panel.get_node(title)
	container.visible  = true
	navbar.append(title)
	$Panel/PanelItems/Navbar.text = global.join_str(navbar, separator)
	focus_index = 0
	enable_all()

func back():
	var opt = navbar.pop_back()
	container.visible = false
	container = panel.get_node(navbar[len(navbar)-1])
	container.visible = true
	$Panel/PanelItems/Navbar.text = global.join_str(navbar, separator)
	
func _on_Back_pressed():
	if len(navbar) <= 1:
		back_to_menu()
	else:
		back()
