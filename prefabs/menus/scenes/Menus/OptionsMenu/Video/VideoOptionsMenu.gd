extends "res://addons/maaacks_menus_template/base/scenes/Menus/OptionsMenu/Video/VideoOptionsMenu.gd"


# note: _preselect_resolution still exists on base to update the hidden resolution setting
# when manualling resizing the window... not much we can do to adapt to resolution scale
# since we cannot enforce window to keep the same aspect ratio, nor use an integer scale
# on OS-level window resize
func _preselect_resolution_scale():
	%ResolutionScaleControl.value = AppManager.cached_valid_window_scale_presets[AppManager.current_window_scale_preset_index]

func _update_resolution_options_enabled(window : Window):
	if OS.has_feature("web"):
		%ResolutionScaleControl.editable = false
		%ResolutionScaleControl.tooltip_text = "Disabled for web"
	elif AppSettings.is_fullscreen(window):
		%ResolutionScaleControl.editable = false
		%ResolutionScaleControl.tooltip_text = "Disabled for fullscreen"
	else:
		%ResolutionScaleControl.editable = true
		%ResolutionScaleControl.tooltip_text = "Select a screen size"

func _update_ui(window : Window):
	%FullscreenControl.value = AppSettings.is_fullscreen(window)
	_preselect_resolution_scale()
	_update_resolution_options_enabled(window)

func _on_fullscreen_control_setting_changed(value):
	print("DisplayServer.window_get_mode: " + str(DisplayServer.window_get_mode()))
	var window : Window = get_window()
	AppManager.set_fullscreen_enabled(value)

	_update_resolution_options_enabled(window)

func _on_resolution_scale_control_setting_changed(value):
	# Hack: index = value - 1
	# we could also call set_window_scale(value), this is really just to update
	# the tracked scale preset index so we can chain with scale change keyboard shortcuts
	AppManager.set_window_scale_preset_index(value - 1, false)
