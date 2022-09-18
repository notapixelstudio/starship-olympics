extends Node2D

const COLORS = ['#66c2a5','#fc8d62','#8da0cb','#e78ac3','#a6d854','#ffd92f']

func _ready():
	var random = randi()%6
	$Label.text = 'abcdef'[random]
	modulate = COLORS[random]
