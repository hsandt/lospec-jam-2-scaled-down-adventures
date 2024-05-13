extends Node


## First room to bind camera to
@export var first_room: Room

@onready var camera: InGameCamera = $%InGameCamera


func _ready():
	DebugUtils.assert_member_is_set(self, first_room, "first_room")

	deferred_ready.call_deferred()


## Post-ready setup
func deferred_ready():
	camera.set_camera_limits_for_room(first_room)
