extends Control

onready var buttons = $margin_container/v_box_container/Options


func _ready():
	buttons.get_child(0).grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene(global.from_scene)


func _on_Label_focus_entered():
	$Label.modulate = Color(0,1,1)
