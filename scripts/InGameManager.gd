class_name InGameManager
extends Node


## First room to load and bind camera to
@export var first_room_scene: PackedScene

## Index of warp entrance spot in first room to start at
@export var first_warp_entrance_spot_index: int

@onready var camera: InGameCamera = $%InGameCamera
@onready var player_character: PlayerCharacter = get_tree().get_first_node_in_group("player_character")

var current_room_instance: Room


func _ready():
	DebugUtils.assert_member_is_set(self, first_room_scene, "first_room_scene")

	load_room_scene_deferred(first_room_scene, first_warp_entrance_spot_index)


## Load room scene deferred, so it works during initialization and collision checks
func load_room_scene_deferred(room_scene: PackedScene, warp_entrance_spot_index: int):
	_load_room_scene.call_deferred(room_scene, warp_entrance_spot_index)


## Load passed room scene and warp PC to entrance spot of index warp_entrance_spot_index
func _load_room_scene(room_scene: PackedScene, warp_entrance_spot_index: int):
	# instantiate room scene below same parent (InGame root node)
	current_room_instance = NodeUtils.instantiate_under(room_scene, get_parent())
	camera.set_camera_limits_for_room(current_room_instance)

	if warp_entrance_spot_index < current_room_instance.entrance_spots.size():
		player_character.global_position = current_room_instance.entrance_spots[warp_entrance_spot_index].global_position
	else:
		push_error("[InGameManager] load_room_scene: for room scene '%s', warp_entrance_spot_index (%d) >= current_room_instance.entrance_spots.size() (%d)" %
			[room_scene.resource_path, warp_entrance_spot_index, current_room_instance.entrance_spots.size()])
