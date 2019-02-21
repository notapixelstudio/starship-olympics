extends Control

enum OPTION_TYPE{ON_OFF, NUMBER, ARRAY}
export (String) var description = "Life"
export (OPTION_TYPE) var elem_type = OPTION_TYPE.ON_OFF
export (bool) var is_global = false
export (NodePath) var node_owner_path

var value 
var min_value
var max_value
var index_value
var array_value
var node_owner

const focus_color = Color(1,1,1)

func _exit_tree():
	print(description, " -> ", value)

func initialize(_description, _value, _min_value, _max_value):
	description = _description
	value = _value
	min_value = _min_value
	max_value = _max_value
	
onready var description_node = $Container/Description
onready var value_node = $Container/ValueContainer/Value
onready var left = $Container/ValueContainer/left
onready var right = $Container/ValueContainer/right
onready var container = $Container

func _ready():
	if is_global:
		node_owner = global
	else:
		node_owner = get_node(node_owner_path)
	description_node.text = description
	value = node_owner.get(description)
	value_node.text = str(value)
	if elem_type == OPTION_TYPE.NUMBER:
		left.visible = true
		right.visible = true
		min_value = node_owner.get("min_"+description)
		max_value = node_owner.get("max_"+description)
		left.visible = value>min_value
		right.visible = value<max_value
		
	if elem_type == OPTION_TYPE.ARRAY:
		left.visible = true
		right.visible = true
		array_value = node_owner.get("array_"+description)
		max_value = len(array_value) - 1
		min_value = 0
		index_value = array_value.find(value)
		left.visible = index_value>min_value
		right.visible = index_value<max_value
		
	set_process_input(false)

func _input(event):
	if has_focus():
		print("focussiamoci")
	if elem_type == OPTION_TYPE.ON_OFF:
		if event.is_action_pressed("ui_accept"):
			shake_node(value_node)
			value = (value_node.text == 'True')
			value = not value
			value_node.text = str(value)
			
	if elem_type == OPTION_TYPE.NUMBER:
		if event.is_action_pressed("ui_right") and right.visible:
			print("Destra")
			left.visible = true
			shake_node(value_node)
			value = int(value_node.text)
			value +=1
			value_node.text = str(value)
			right.visible = value<max_value
		elif event.is_action_pressed("ui_left") and left.visible:
			right.visible = true
			shake_node_backwards(value_node)
			value = int(value_node.text)
			value -=1
			value_node.text = str(value)
			left.visible = value>min_value

	if elem_type == OPTION_TYPE.ARRAY:
		if event.is_action_pressed("ui_right") and right.visible:
			left.visible = true
			shake_node(value_node)
			value = str(value_node.text)
			index_value = array_value.find(value)
			index_value = mod((index_value + 1), len(array_value))
			value = array_value[index_value]
			value_node.text = str(value)
			right.visible = index_value<max_value
		elif event.is_action_pressed("ui_left") and left.visible:
			right.visible = true
			shake_node_backwards(value_node)
			value = str(value_node.text)
			index_value = array_value.find(value)
			index_value = mod((index_value - 1), len(array_value))
			value = array_value[index_value]
			value_node.text = str(value)
			left.visible = index_value>min_value

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
	shake_node(description_node)
	description_node.modulate = focus_color.darkened(0.1)
	value_node.modulate = focus_color.darkened(0.1)
	

func _on_Element_focus_exited():
	for node in container.get_children():
		node.modulate = Color(1,1,1)
	value_node.modulate = Color(1,1,1)
	set_process_input(false)
	
func mod(a,b):
	var ret = a%b
	if ret < 0: 
		return ret+b
	else:
		return ret

