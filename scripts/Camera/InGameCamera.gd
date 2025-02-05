class_name InGameCamera
extends Camera2D


## Enable this flag to follow player character,
## disable during cinematic for fixed camera or puppet camera
@export var follow_player_character: bool = true

## Player character to follow
@onready var player_character: PlayerCharacter = get_tree().get_first_node_in_group("player_character")


func _process(_delta: float):
	move_to_player_character()


func move_to_player_character():
	if follow_player_character:
		position = player_character.position


func move_instantly_to_player_character():
	if follow_player_character:
		position = player_character.position

		# Disable drag window for the instant reset
		# to make sure camera is centered on target
		drag_horizontal_enabled = false
		drag_vertical_enabled = false

		reset_smoothing()

		# Re-enable drag
		drag_horizontal_enabled = true
		drag_vertical_enabled = true


func set_camera_limits_for_room(room: Room):
	limit_left = room.camera_limit_top_left.global_position.x as int
	limit_right = room.camera_limit_bottom_right.global_position.x as int
	limit_top = room.camera_limit_top_left.global_position.y as int
	limit_bottom = room.camera_limit_bottom_right.global_position.y as int
