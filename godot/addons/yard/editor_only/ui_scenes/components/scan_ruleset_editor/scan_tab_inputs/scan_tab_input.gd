@tool
@abstract
extends Control
## Represents some scan-related property input that belongs in a tab container.

const ScanTabInput := preload("./scan_tab_input.gd")

@warning_ignore_start("unused_signal")
signal input_changed
signal request_action(action: StringName, args: Variant)

var disabled: bool = false:
	set = _set_disabled


func _set_disabled(value: bool) -> void:
	disabled = value


@abstract func get_value() -> Variant


@abstract func set_value(value: Variant) -> void


@abstract func reset_value() -> void


@abstract func render_validation_results(args: Variant) -> void
