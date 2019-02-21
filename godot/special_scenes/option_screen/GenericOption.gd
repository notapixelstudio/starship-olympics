extends Control

class_name GenericOption

enum OPTION_TYPE{ON_OFF, NUMBER, ARRAY}
export (String) var description = "Life"
export (OPTION_TYPE) var elem_type = OPTION_TYPE.ON_OFF
export (bool) var is_global = false
export (NodePath) var node_owner_path
