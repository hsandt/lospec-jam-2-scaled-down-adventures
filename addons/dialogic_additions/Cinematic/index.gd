@tool
extends DialogicIndexer

func _get_events() -> Array:
	return [
		this_folder.path_join('event_rotate_character.gd'),
		this_folder.path_join('event_remove_character.gd')
	]

