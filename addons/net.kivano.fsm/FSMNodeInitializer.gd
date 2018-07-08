tool
extends Node

var scene2Manage = null;
export var DEBUG_INFO = "";

func _enter_tree():
	set_name("kivano.fsm_plugin_helper");
	
	#
	if(scene2Manage==null): 
		scene2Manage = preload("content/FSM.tscn").instance();

	#
	get_parent().add_child(scene2Manage);
	scene2Manage.set_owner(get_tree().get_edited_scene_root());
	queue_free();
	
func _exit_tree(): pass