extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
enum OPTION_TYPE{ON_OFF, NUMBER}
export (String) var description = "Life"
export (OPTION_TYPE) var elem_type = OPTION_TYPE.ON_OFF
var value 

func _exit_tree():
	print(description, " -> ", value)
	
func _ready():
	if elem_type == NUMBER:
		$Value/left.visible = true
		$Value/right.visible = true

	$Description.text = description
	value = str(global.get(description))
	$Value/Value.text = value
	print(description,"=>", value)
	
	set_process_input(false)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	if elem_type == ON_OFF:
		if event.is_action_pressed("ui_accept"):
			print("change")
			shake_node($Value)
			value = ($Value/Value.text == 'True')
			value = not value
			$Value/Value.text = str(value)
			
	if elem_type == NUMBER:
		if event.is_action_pressed("ui_right"):
			shake_node($Value)
			value = int($Value/Value.text)
			value +=1
			$Value/Value.text = str(value)
		elif event.is_action_pressed("ui_left"):
			shake_node_backwards($Value)
			value = int($Value/Value.text)
			value -=1
			$Value/Value.text = str(value)
		
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
func shake_node_backwards(node):
	var actual_d_pos = node.rect_position
	$Tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position - Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.interpolate_method(node, "set_position", node.rect_position - Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	$Tween.start()
	yield($Tween,"tween_completed")

func shake_node(node):
	var actual_d_pos = node.rect_position
	$Tween.interpolate_method(node, "set_position", node.rect_position, node.rect_position + Vector2(5, 0), 0.05, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.interpolate_method(node, "set_position", node.rect_position + Vector2(5, 0), actual_d_pos, 0.05, Tween.TRANS_BACK, Tween.EASE_OUT, 0.05)
	$Tween.start()
	yield($Tween,"tween_completed")

func _on_Element_focus_entered():
	set_process_input(true)
	var d= $Description
	shake_node(d)
	d.modulate = Color(1,0,1)
	

func _on_Element_focus_exited():
	for node in get_children():
		node.modulate = Color(1,1,1)
	set_process_input(false)
	
