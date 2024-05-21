class_name InGameManager
extends Node


@export_group("Assets preloading")

@export var dialogic_style_to_preload: DialogicStyle

@export_group("Setup")

## First room to load and bind camera to
@export var first_room_scene: PackedScene

## Index of warp entrance spot in first room to start at
@export var first_warp_entrance_spot_index: int


@onready var room_on_ready: Room = get_tree().get_first_node_in_group("rooms")
@onready var camera: InGameCamera = $%InGameCamera
@onready var player_character: PlayerCharacter = get_tree().get_first_node_in_group("player_character")

var current_room_instance: Room


func _ready():
	DebugUtils.assert_member_is_set(self, dialogic_style_to_preload, "dialogic_style_to_preload")
	DebugUtils.assert_member_is_set(self, first_room_scene, "first_room_scene")

	# This avoids most of the initial loading time on first timeline play and layout display
	# There is still a very small lag, but I need to identify which other resources need to be preloaded
	dialogic_style_to_preload.prepare()

	# Register self to GameManager to allow global access from other scripts
	# (which cannot rely on @onready time get_first_node_in_group("in_game_manager") when Play testing
	# F6 directly from a room, as InGame scene is loaded after ready)
	GameManager.in_game_manager = self

	if not room_on_ready:
		# In normal play, there is no other room as we load InGame scene alone,
		# so we load the first room and warp on first spot as usual
		load_room_scene_deferred(first_room_scene, first_warp_entrance_spot_index)
	else:
		# In debug F6 play a specific room, we load InGame scene additively from
		# GameManager, and so we must not also load the first scene on top
		# However we must still register the initial room and warp PC to first spot
		# so it's not in the wild, possibly outside the room area
		current_room_instance = room_on_ready
		# Defer call so camera is ready and knows about player characteraaa
		_warp_player_character_to_entrance_spot.call_deferred(0)


func _exit_tree():
	# Cleanup to avoid invalid reference
	GameManager.in_game_manager = null


## Load room scene deferred, so it works during initialization and collision checks
func load_room_scene_deferred(room_scene: PackedScene, warp_entrance_spot_index: int):
	_load_room_scene.call_deferred(room_scene, warp_entrance_spot_index)


## Queue unload current room for end of frame, and load next room deferred
func switches_room_scene_deferred(room_scene: PackedScene, warp_entrance_spot_index: int):
	_queue_unload_current_room()
	load_room_scene_deferred(room_scene, warp_entrance_spot_index)


## Load passed room scene and warp PC to entrance spot of index warp_entrance_spot_index
func _load_room_scene(room_scene: PackedScene, warp_entrance_spot_index: int):
	# instantiate room scene below same parent (InGame root node)
	current_room_instance = NodeUtils.instantiate_under(room_scene, get_tree().root)
	camera.set_camera_limits_for_room(current_room_instance)
	_warp_player_character_to_entrance_spot(warp_entrance_spot_index)

func _warp_player_character_to_entrance_spot(warp_entrance_spot_index: int):
	if warp_entrance_spot_index < current_room_instance.entrance_spots.size():
		player_character.global_position = current_room_instance.entrance_spots[warp_entrance_spot_index].global_position
		camera.move_to_player_character()
	else:
		push_error("[InGameManager] load_room_scene: for room scene '%s', warp_entrance_spot_index (%d) >= current_room_instance.entrance_spots.size() (%d)" %
			[current_room_instance.get_path(), warp_entrance_spot_index, current_room_instance.entrance_spots.size()])


func _queue_unload_current_room():
	current_room_instance.queue_free()
