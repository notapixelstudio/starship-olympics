tool
extends Line2D

export var path_star_scene: PackedScene
export var path_line_scene: PackedScene

onready var unlocked_status := TheUnlocker.get_status("map_paths", self.name, TheUnlocker.UNLOCKED if Engine.editor_hint else TheUnlocker.HIDDEN)

const D = 25

signal appeared

func set_points(v):
	points = v
	refresh()
	
func _ready():
	refresh()
	if unlocked_status != TheUnlocker.HIDDEN:
		appear(unlocked_status==TheUnlocker.UNLOCKED)
	
func refresh():
	for child in $Content.get_children():
		child.queue_free()
		
	# add a smaller line to each segment
	for i in range(len(points)-1):
		add_line(points[i], points[i+1])
		
		# add a star to each internal corner
		if i < len(points)-2:
			var star = path_star_scene.instance()
			star.position = points[i+1]
			$Content.add_child(star)

func add_line(p1, p2):
	var dir = (p2-p1).normalized()
	
	var line = path_line_scene.instance()
	line.set_endpoints(p1+dir*D, p2-dir*D)
	$Content.add_child(line)

func get_global_endpoints() -> Dictionary: # Dictionary {start: Vector2, end: Vector2}
	return {
		'start': to_global(points[0]),
		'end': to_global(points[-1])
	}

func appear(force: bool = false) -> void:
	for child in $Content.get_children():
		child.appear(force)
		if not force:
			yield(child, 'appeared')
		
	emit_signal('appeared')
