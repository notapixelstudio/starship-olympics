@tool
extends PopupMenu

@export var icon_names: Dictionary[int, String]:
	set(v):
		icon_names = v
		for id: int in v.keys():
			var idx := get_item_index(id)
			var icon_name := v[id]
			if has_theme_icon(icon_name, "EditorIcons"):
				set_item_icon(idx, get_theme_icon(icon_name, "EditorIcons"))


func _ready() -> void:
	self.icon_names = (icon_names)
