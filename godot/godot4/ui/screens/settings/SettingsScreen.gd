extends BackScreen

func enter():
	super.enter()
	%SettingsContainer.grab_focus()

func exiting():
	super.exiting()
	Events.store_settings.emit()
