class_name InteractableNPC
extends Interactable


## NPC to interact with
@export var npc: NPC


func _ready():
	DebugUtils.assert_member_is_set(self, npc, "npc")


# implement
func interact_async():
	var layout := Dialogic.start(npc.dialogic_timeline)
	layout.register_character(npc.dialogic_character, npc)
	layout.register_character(GameManager.in_game_manager.dialogic_player_character, GameManager.in_game_manager.player_character)

	# We asume we only play one timeline at a time, so when we detect timeline ending,
	# it is this one that is ending
	await Dialogic.timeline_ended
