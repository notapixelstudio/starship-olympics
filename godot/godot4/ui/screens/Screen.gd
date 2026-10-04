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
	pass

## Executed right after a transition to this Screen has ended. Override it in your inherited scenes
## to customize its behavior. Remember to either call [code]super.enter()[/code] in your override method if
## you also want to retain the default behavior (which enables input processing).
func enter() -> void:
	pass
	
## Executed right before starting a transition from this Screen. Override it in your inherited scenes
## to customize its behavior. Remember to either call [code]super.exiting()[/code] in your override method if
## you also want to retain the default behavior (which releases and disable focus and disables input processing).
func exiting() -> void:
	pass
	
## Executed right after a transition from this Screen has ended. Override it in your inherited scenes
## to customize its behavior.
func exited() -> void:
	pass
	
## Returns a [String] identifier for the Screen (defaults to the [member Node.name], override this method
## if you want to provide a different identifier).
func get_id() -> String:
	return name
	
