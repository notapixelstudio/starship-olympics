extends GenericOption

onready var value_node = $Container/ValueContainer/Value
onready var left = $Container/ValueContainer/left
onready var right = $Container/ValueContainer/right
onready var container = $Container
onready var description_node = $Container/Description

const focus_color = Color(1,1,1)
var index_value

func _process(_delta):
	$Container/Description.text = label_description

func _initialize():
	left.visible = true
	right.visible = true
	
	if elem_type == OPTION_TYPE.NUMBER:
		self.value = node_owner.get(variable_name)
		left.visible = value>min_value
		right.visible = value<max_value
	
	if elem_type == OPTION_TYPE.ARRAY:
		# it might not be ready yet
		
		array_value = nested_get(node_owner, "array_"+variable_name)
		# get first element if there is not already set
		var default_value = nested_get(node_owner, variable_name)
		if default_value:
			self.value = default_value
		else:
			self.value = array_value[0]
		
		max_value = len(array_value) - 1
		min_value = 0
		index_value = array_value.find(value)
		left.visible = index_value>min_value
		right.visible = index_value<max_value
		
	value_node.text = str(value)


func _ready():
	if not label_description:
		label_description = variable_name
		
	description_node.text = label_description.to_upper()
	
	if elem_type == OPTION_TYPE.NUMBER:
		min_value = node_owner.get("min_"+variable_name)
		max_value = node_owner.get("max_"+variable_name)
	
	_initialize()

func _input(event):
	if elem_type == OPTION_TYPE.ON_OFF:
		if event.is_action_pressed("ui_fire"):
			value = (value_node.text == 'TRUE')
			self.value = not value
			value_node.text = str(value)
			
	if elem_type == OPTION_TYPE.NUMBER:
		if event.is_action_pressed("ui_right") and right.visible:
			left.visible = true
			value = int(value_node.text)
			value +=1
			self.value = value
			value_node.text = str(value)
			right.visible = value<max_value
			
		elif event.is_action_pressed("ui_left") and left.visible:
			right.visible = true
			value = int(value_node.text)
			value -=1
			self.value = value
			value_node.text = str(value)
			left.visible = value>min_value

	if elem_type == OPTION_TYPE.ARRAY:
		if event.is_action_pressed("ui_right") and right.visible:
			left.visible = true
			#value = str(value_node.text)
			value = node_owner.get(variable_name)
			index_value = array_value.find(value)
			index_value = mod((index_value + 1), len(array_value))
			
			self.value = array_value[index_value]
			value_node.text = str(value)
			right.visible = index_value<max_value
		elif event.is_action_pressed("ui_left") and left.visible:
			right.visible = true
			value = str(value_node.text)
			index_value = array_value.find(value)
			
			index_value = mod((index_value - 1), len(array_value))
			
			self.value = array_value[index_value]
			value_node.text = str(value)
			left.visible = index_value>min_value

	node_owner.set(variable_name, value)
	

func _on_Element_focus_entered():
	add_stylebox_override("panel", load("res://interface/themes/grey/focus.tres"))
	set_process_input(true)
	description_node.modulate = focus_color.darkened(0.1)
	value_node.modulate = focus_color.darkened(0.1)
	

func _on_Element_focus_exited():
	add_stylebox_override("panel", load("res://interface/themes/grey/normal.tres"))
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

