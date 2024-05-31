extends "res://addons/maaacks_menus_template/extras/scenes/PauseMenu/PauseMenu.gd"


@onready var in_game_manager: InGameManager = get_tree().get_first_node_in_group("in_game_manager")


func _unhandled_input(event):
	if event.is_action_pressed(&"toggle_pause_menu"):
		if popup_open != null:
			close_popup()
		elif %SubMenuContainer.visible:
			close_options_menu()
		else:
			InGameMenuController.close_menu()


func _on_confirm_restart_confirmed():
	in_game_manager._queue_unload_current_room()
	SceneLoader.reload_current_scene()
	InGameMenuController.close_menu()
