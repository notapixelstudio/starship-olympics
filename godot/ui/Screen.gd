extends Control

export var next_scene: PackedScene

signal next(next_packed_scene) 
signal back

class_name ScreenScene

func enter():
	set_process_input(true)

func exit():
	set_process_input(false)
