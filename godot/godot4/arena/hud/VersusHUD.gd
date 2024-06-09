extends Node2D

@export var bar_scene: PackedScene

var _max_score : float

func _ready() -> void:
	Events.score_updated.connect(_on_score_updated)
	
func _on_score_updated(new_score:float, team:String):
	%ScoreBars.get_node(team).set_value(new_score)

func add_team(name:String, species:Species) -> void:
	var bar = bar_scene.instantiate()
	bar.name = name
	bar.set_team(name)
	bar.set_species(species) # FIXME this should be read from elsewhere
	bar.set_max_value(_max_score)
	%ScoreBars.add_child(bar)

func set_max_score(v: float) -> void:
	_max_score = v
