extends GenericOption

const focus_color = Color(1,1,1)
var index_value

func _exit_tree():
	print(description, " -> ", value)

func _initialize():
	left.visible = true
	right.visible = true
	
	if elem_type == OPTION_TYPE.NUMBER:
		left.visible = value>min_value
		right.visible = value<max_value
	if elem_type == OPTION_TYPE.ARRAY:
		yield(get_tree().create_timer(2), "timeout")
		print(node_owner.get("array_"+description))
		print(description)
		print(node_owner.get(description))
		array_value = nested_get(node_owner, optional_path)
		
		# it might not be ready yet
		value = nested_get(node_owner, description)
		
		max_value = len(array_value) - 1
		min_value = 0
		index_value = array_value.find(value)
		left.visible = index_value>min_value
		right.visible = index_value<max_value
	value_node.text = str(value)

onready var value_node = $Container/ValueContainer/Value
onready var left = $Container/ValueContainer/left
onready var right = $Container/ValueContainer/right
onready var container = $Container

func _ready():
	_initialize()

func _input(event):
	if elem_type == OPTION_TYPE.ON_OFF:
		if event.is_action_pressed("ui_accept"):
			shake_node(value_node)
			value = (value_node.text == 'True')
			value = not value
			value_node.text = str(value)
			
	if elem_type == OPTION_TYPE.NUMBER:
		if event.is_action_pressed("ui_right") and right.visible:
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
	node_owner.set(description, value)
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

