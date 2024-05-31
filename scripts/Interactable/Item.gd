extends Node


@export var dialogic_timeline: DialogicTimeline


func _ready():
	DebugUtils.assert_member_is_set(self, dialogic_timeline, "dialogic_timeline")
