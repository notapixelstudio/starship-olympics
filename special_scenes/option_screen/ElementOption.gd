extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
enum OPTION_TYPE{ON_OFF, NUMBER, ARRAY}
export (String) var description = "Life"
export (OPTION_TYPE) var elem_type = OPTION_TYPE.ON_OFF
var value 
var min_value
var max_value
var index_value
var array_value
const focus_color = Color(1,0,0)

func _exit_tree():
	print(description, " -> ", value)
	
func _ready():
	$Description.text = description
	value = global.get(description)
	$Value/Value.text = str(value)
	if elem_type == NUMBER:
		$Value/left.visible = true
		$Value/right.visible = true
		min_value = global.get("min_"+description)
		max_value = global.get("max_"+description)
		$Value/left.visible = value>min_value
		$Value/right.visible = value<max_value
		
	if elem_type == ARRAY:
		$Value/left.visible = true
		$Value/right.visible = true
		array_value = global.get("array_"+description)
		print(array_value)
		max_value = len(array_value) - 1
		min_value = 0
		index_value = array_value.find(value)
		$Value/left.visible = index_value>min_value
		$Value/right.visible = index_value<max_value
		
	set_process_input(false)
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	if elem_type == ON_OFF:
		if event.is_action_pressed("ui_accept"):
			shake_node($Value)
			value = ($Value/Value.text == 'True')
			value = not value
			$Value/Value.text = str(value)
			
	if elem_type == NUMBER:
		if event.is_action_pressed("ui_right") and $Value/right.visible:
			$Value/left.visible = true
			shake_node($Value)
			value = int($Value/Value.text)
			value +=1
			$Value/Value.text = str(value)
			$Value/right.visible = value<max_value
		elif event.is_action_pressed("ui_left") and $Value/left.visible:
			$Value/right.visible = true
			shake_node_backwards($Value)
			value = int($Value/Value.text)
			value -=1
			$Value/Value.text = str(value)
			$Value/left.visible = value>min_value

	if elem_type == ARRAY:
		if event.is_action_pressed("ui_right") and $Value/right.visible:
			$Value/left.visible = true
			shake_node($Value)
			value = str($Value/Value.text)
			index_value = array_value.find(value)
			index_value = mod((index_value + 1), len(array_value))
			value = array_value[index_value]
			$Value/Value.text = str(value)
			$Value/right.visible = index_value<max_value
		elif event.is_action_pressed("ui_left") and $Value/left.visible:
			$Value/right.visible = true
			shake_node_backwards($Value)
			value = str($Value/Value.text)
			index_value = array_value.find(value)
			index_value = mod((index_value - 1), len(array_value))
			value = array_value[index_value]
			$Value/Value.text = str(value)
			$Value/left.visible = index_value>min_value
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
	d.modulate = focus_color
	$Value/Value.modulate = focus_color
	

func _on_Element_focus_exited():
	for node in get_children():
		node.modulate = Color(1,1,1)
	$Value/Value.modulate = Color(1,1,1)
	set_process_input(false)
	
func mod(a,b):
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret