extends Node2D

export (float, 1.0) var fraction = 0.0 setget set_fraction

func _ready():
	refresh()
	
func set_fraction(value):
	fraction = value
	
	if is_inside_tree():
		refresh()
	
func refresh():
	$ScoreLine.points = PoolVector2Array([Vector2(0,0),Vector2(130*fraction,0)])
	
