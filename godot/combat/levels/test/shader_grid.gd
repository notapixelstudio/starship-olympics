tool
extends Node2D


func _ready():
	$Grid.material.set_shader_param('size', $Grid.rect_size)
