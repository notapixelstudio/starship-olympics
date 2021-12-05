extends Node2D

var owner_ship: Ship

export var arsenal : Dictionary # of id -> Weapon Scenes

func _ready():
	owner_ship = get_parent() # WARNING
