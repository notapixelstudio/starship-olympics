extends Node2D

@export var score_bar_scene: PackedScene

var _max_score : float
var _starting_score : float
var _thresholds := []

func _ready() -> void:
	Events.score_updated.connect(_on_score_updated)
	
func _on_score_updated(score: float, team: String, new_standings: Array) -> void:
	%ScoreBars.get_node(team).set_value(score)
	
func add_team(name:String, species_list: Array[Species]) -> void:
	var bar = score_bar_scene.instantiate()
	bar.name = name
	bar.set_team(name)
	bar.set_species_list(species_list)
	bar.set_max_value(_max_score)
	bar.set_value(_starting_score)
	bar.set_thresholds(_thresholds)
	%ScoreBars.add_child(bar)
	
func set_max_score(v: float) -> void:
	_max_score = v

func set_starting_score(v: float) -> void:
	_starting_score = v

func set_thresholds(v: Array) -> void:
	_thresholds = v
	
