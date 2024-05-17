class_name InteractableArea
extends Area2D


## Interactable associated to this area
@export var interactable: Interactable


func _ready():
	DebugUtils.assert_member_is_set(self, interactable, "interactable")
