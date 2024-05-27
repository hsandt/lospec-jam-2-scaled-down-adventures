extends Area2D


@export_file("*.tscn") var next_room_scene_path: String
var next_room_scene: PackedScene

## Index of entrance spot to warp to in next room
@export var warp_entrance_spot_index: int = 0


func _ready():
	DebugUtils.assert_string_member_is_not_empty(self, next_room_scene_path, "next_room_scene_path")
	next_room_scene = load(next_room_scene_path)


func _on_body_entered(body: Node2D):
	var player_character := body as PlayerCharacter
	if player_character:
		GameManager.in_game_manager.switches_room_scene_deferred(next_room_scene, warp_entrance_spot_index)
