tool
extends GenericOption

export (OPTION_TYPE) var elem_type = OPTION_TYPE.NUMBER
onready var value_node = $Container/ValueContainer/Value
onready var left = $Container/ValueContainer/left
onready var right = $Container/ValueContainer/right
onready var container = $Container
onready var description_node = $Container/Description

const focus_color = Color(1,1,1)

var index_value
var min_value
var max_value
var array_value

func _ready():
	if not label_description:
		label_description = element_path
		
	description_node.text = label_description.to_upper()
	
	left.visible = true
	right.visible = true
	self.value = node_owner.get(element_path)
	
	if elem_type == OPTION_TYPE.NUMBER:
		min_value = node_owner.get("min_"+element_path)
		max_value = node_owner.get("max_"+element_path)
		left.visible = value>min_value
		right.visible = value<max_value
	elif elem_type == OPTION_TYPE.ARRAY:
		array_value = node_owner.get("array_"+element_path)
		# get first element if there is not already set
		var default_value = node_owner.get(element_path)
		if default_value:
			self.value = default_value
		else:
			self.value = array_value[0]
		max_value = len(array_value) - 1
		min_value = 0
		index_value = array_value.find(value)
		left.visible = index_value>min_value
		right.visible = index_value<max_value
	
	value_node.text = tr(str(value))
	
func _process(_delta):
	# with this we make sure we 
	$Container/Description.text = tr(str(label_description))
	

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
			index_value = array_value.find(self.value)
			index_value = global.mod((index_value + 1), len(array_value))
			
			self.value = array_value[index_value]
			value_node.text = str(value)
			right.visible = index_value<max_value
		elif event.is_action_pressed("ui_left") and left.visible:
			right.visible = true
			value = str(value_node.text)
			index_value = array_value.find(value)
			
			index_value = global.mod((index_value - 1), len(array_value))
			
			self.value = array_value[index_value]
			value_node.text = str(value)
			left.visible = index_value>min_value

	node_owner.set(element_path, value)
	

func _on_Element_focus_entered():
	set_process_input(true)
	description_node.add_stylebox_override("normal", load("res://interface/themes/grey/focus.tres"))
	description_node.modulate = focus_color.darkened(0.1)
	value_node.modulate = focus_color.darkened(0.1)
	

func _on_Element_focus_exited():
	description_node.add_stylebox_override("normal", load("res://interface/themes/grey/normal.tres"))
	for node in container.get_children():
		node.modulate = Color(1,1,1)
	value_node.modulate = Color(1,1,1)
	set_process_input(false)


