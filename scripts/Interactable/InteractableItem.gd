class_name InteractableItem
extends Interactable


## Item to interact with
@export var item: Node2D


func _ready():
	DebugUtils.assert_member_is_set(self, item, "item")


# implement
func interact_async():
	var layout := Dialogic.start(item.dialogic_timeline)
	layout.register_character(GameManager.in_game_manager.dialogic_player_character, GameManager.in_game_manager.player_character)

	# We asume we only play one timeline at a time, so when we detect timeline ending,
	# it is this one that is ending
	await Dialogic.timeline_ended
