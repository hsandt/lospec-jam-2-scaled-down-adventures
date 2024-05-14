class_name InteractableArea
extends Area2D


## Entity that PC interacts with
@export var owning_entity: Node2D
@export var dialogic_character: DialogicCharacter


func _ready():
	DebugUtils.assert_member_is_set(self, owning_entity, "owning_entity")
	DebugUtils.assert_member_is_set(self, dialogic_character, "dialogic_character")
