class_name TurretFiring extends ActorBehavior
## Schedules fire calls; the actor decides what each shot does.

@export var enabled := true
@export var wait_time := 2.0
@export var time_jitter := 0.0
@export_group("Burst")
@export var burst_shots := 1
@export var burst_time := 0.2
@export var burst_time_jitter := 0.0

var _burst_count := 0

func _ready() -> void:
	super._ready()
	$Timer.timeout.connect(_on_timeout)

func start() -> void:
	$Timer.start(wait_time)

func stop() -> void:
	$Timer.stop()

func _on_timeout() -> void:
	if enabled:
		actor.call("fire")
		_burst_count += 1
	if not enabled or _burst_count >= burst_shots:
		_burst_count = 0
		$Timer.start(wait_time + randf() * time_jitter)
	else:
		$Timer.start(burst_time + randf() * burst_time_jitter)
