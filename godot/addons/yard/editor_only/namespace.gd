const PluginCFG := "res://addons/yard/plugin.cfg"

# Static Util Classes
const RegistryIO := preload("res://addons/yard/editor_only/registry_io.gd")
const YardEditorCache := preload("res://addons/yard/editor_only/classes/yard_editor_cache.gd")
const ClassUtils := preload("res://addons/yard/editor_only/classes/class_utils.gd")
const EditorThemeUtils := preload("res://addons/yard/editor_only/classes/editor_theme_utils.gd")
const FuzzySearch := preload("res://addons/yard/editor_only/classes/fuzzy_search.gd")
const AnyIcon := preload("res://addons/yard/editor_only/classes/any_icon.gd")

# UI Scenes
const RegistryEditor := preload("res://addons/yard/editor_only/ui_scenes/registry_editor.gd")
const RegistryTableView := preload("res://addons/yard/editor_only/ui_scenes/registry_table_view.gd")
const MarkdownLabel := preload("res://addons/yard/editor_only/classes/markdownlabel/markdownlabel.gd")
const DynamicTable := preload("res://addons/yard/editor_only/ui_scenes/components/dynamic_table.gd")
const RegistriesItemList := preload("res://addons/yard/editor_only/ui_scenes/components/registries_itemlist.gd")
const NewRegistryDialog := preload("res://addons/yard/editor_only/ui_scenes/components/new_registry_dialog.gd")
const EditorPropertyOptionWrapper := preload("res://addons/yard/editor_only/ui_scenes/components/editor_property_option_wrapper.gd")
const MultiOptionEditorProperty = preload("res://addons/yard/editor_only/ui_scenes/components/multi_option_editor_property.gd")
const REGISTRY_EDITOR_SCENE := preload("res://addons/yard/editor_only/ui_scenes/registry_editor.tscn")
const REGISTRY_TABLE_VIEW_SCENE := preload("res://addons/yard/editor_only/ui_scenes/registry_table_view.tscn")

# Misc
const FILESYSTEM_CREATE_CONTEXT_MENU_PLUGIN = preload("res://addons/yard/editor_only/editor_context_menu_plugin.gd")
const EDITOR_INSPECTOR_PLUGIN = preload("res://addons/yard/editor_only/editor_inspector_plugin.gd")
const TRANSLATIONS := {
	"de_DE": "res://addons/yard/editor_only/locale/de_DE.po",
	"en_US": "res://addons/yard/editor_only/locale/en_US.po",
	"es_ES": "res://addons/yard/editor_only/locale/es_ES.po",
	"fr_FR": "res://addons/yard/editor_only/locale/fr_FR.po",
	"it_IT": "res://addons/yard/editor_only/locale/it_IT.po",
	"pl_PL": "res://addons/yard/editor_only/locale/pl_PL.po",
	"pt_BR": "res://addons/yard/editor_only/locale/pt_BR.po",
	"ru_RU": "res://addons/yard/editor_only/locale/ru_RU.po",
	"tr_TR": "res://addons/yard/editor_only/locale/tr_TR.po",
	"zh_CN": "res://addons/yard/editor_only/locale/zh_CN.po",
}
