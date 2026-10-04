extends Control
class_name Screen
## Base class for application-specific Screens, i.e., a Control scene that fills the entire screen.
## Useful for example for game menus.
## A Screen has the ability to require a transition to a new Screen by emitting [signal next] or
## to require going back to the previous Screen by emitting [signal back].

signal next(next_screen: Screen) ## Emit this signal to request a transition to the given Screen.
signal back ## Emit this signal to request a transition back to the previous screen.

var _old_focus_modes := {}

func entering() -> void:
	_enable_all_focusables()

## Executed right after a transition to this Screen has ended. Override it in your inherited scenes
## to customize its behavior. Remember to either call [code]super.enter()[/code] in your override method if
## you also want to retain the default behavior (which enables input processing).
func enter() -> void:
	set_process_input(true)
	set_process_unhandled_input(true)
	
## Executed right before starting a transition from this Screen. Override it in your inherited scenes
## to customize its behavior. Remember to either call [code]super.exiting()[/code] in your override method if
## you also want to retain the default behavior (which releases and disable focus and disables input processing).
func exiting() -> void:
	set_process_input(false)
	set_process_unhandled_input(false)
	recursive_release_focus()
	
## Executed right after a transition from this Screen has ended. Override it in your inherited scenes
## to customize its behavior.
func exited() -> void:
	_disable_all_focusables()

## Call this method to recursively cause this Screen and all of its Control descendants to lose focus.
func recursive_release_focus() -> void:
	release_focus()
	for descendant in find_children("*", "Control"):
		descendant.release_focus()
		
## Returns a [String] identifier for the Screen (defaults to the [member Node.name], override this method
## if you want to provide a different identifier).
func get_id() -> String:
	return name
	
## FIXME these are made to support Control nodes out of the box as well as custom nodes having a set_focus_mode method
## is there a cleaner way to have an off-screen disable of the whole content?
func _disable_all_focusables():
	for descendant in find_children("*"):
		if descendant.has_method('set_focus_mode'):
			_old_focus_modes[descendant] = descendant.focus_mode
			descendant.set_focus_mode(Control.FOCUS_NONE)
		
func _enable_all_focusables():
	for descendant in find_children("*"):
		if descendant.has_method('set_focus_mode') and _old_focus_modes.has(descendant):
			descendant.set_focus_mode(_old_focus_modes[descendant])
			_old_focus_modes.erase(descendant)
