class_name NPC
extends Character


@export var dialogic_character: DialogicCharacter
@export var dialogic_timeline: DialogicTimeline


func _ready():
	DebugUtils.assert_member_is_set(self, dialogic_character, "dialogic_character")
	DebugUtils.assert_member_is_set(self, dialogic_timeline, "dialogic_timeline")
