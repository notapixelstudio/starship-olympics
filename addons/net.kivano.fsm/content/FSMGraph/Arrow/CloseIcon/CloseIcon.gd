tool
extends Node2D
signal onCloseBtnClicked;

onready var animator = get_node("Animator")
onready var visual = get_node("Button");
func _ready():
	modulate.a = 0;


func _on_Area2D_input_event( viewport, event, shape_idx ):
	if(event.type==InputEvent.MOUSE_BUTTON):
		queue_free();

func _on_Button_pressed():
	if(get_parent().getTargetNode()==null):return;
	emit_signal("onCloseBtnClicked");


func _on_Button_mouse_entered():
	if(get_parent().getTargetNode()==null):return;
#	visual.modulate.a = 0;
	animator.play("appear");


func _on_Button_mouse_exited():
	if(get_parent().getTargetNode()==null):return;
#	visual.modulate.a = 1;
	animator.play("dissapear");
