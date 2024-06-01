class_name InGameManager
extends Node


@export_group("Assets preloading")

@export var dialogic_style_to_preload: DialogicStyle


@export_group("Assets references")

@export var dialogic_player_character: DialogicCharacter
@export var bgm_ingame: AudioStream

## Main menu scene
## Use @export_file to avoid circular reference
## See https://github.com/godotengine/godot/issues/24146
@export_file("*.tscn") var ingame_scene_path: String


@export_group("Setup")

@export var first_dialogic_timeline: DialogicTimeline

## First room to load and bind camera to
@export var first_room_scene: PackedScene

## Index of warp entrance spot in first room to start at
@export var first_warp_entrance_spot_index: int

## Speed factor for fade in animation
@export var fade_in_speed: float = 1.0

## Skip intro (debug only)
@export var debug_skip_intro: bool = false


@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var camera: InGameCamera = %InGameCamera
@onready var player_character: PlayerCharacter = get_tree().get_first_node_in_group("player_character")
@onready var room_on_ready: Room = get_tree().get_first_node_in_group("rooms")

var current_room_instance: Room


func _ready():
	DebugUtils.assert_member_is_set(self, dialogic_style_to_preload, "dialogic_style_to_preload")
	DebugUtils.assert_member_is_set(self, dialogic_player_character, "dialogic_player_character")
	DebugUtils.assert_member_is_set(self, bgm_ingame, "bgm_ingame")
	DebugUtils.assert_string_member_is_not_empty(self, ingame_scene_path, "ingame_scene_path")

	DebugUtils.assert_member_is_set(self, first_dialogic_timeline, "first_dialogic_timeline")
	DebugUtils.assert_member_is_set(self, first_room_scene, "first_room_scene")

	# This avoids most of the initial loading time on first timeline play and layout display
	# There is still a very small lag, but I need to identify which other resources need to be preloaded
	dialogic_style_to_preload.prepare()

	# Register self to GameManager to allow global access from other scripts
	# (which cannot rely on @onready time get_first_node_in_group("in_game_manager") when Play testing
	# F6 directly from a room, as InGame scene is loaded after ready)
	GameManager.in_game_manager = self

	# Defer further calls so we can manipulate nodes safely, and player character is ready
	# for camera, etc.
	await get_tree().physics_frame

	if not room_on_ready:
		# In normal play, there is no other room as we load InGame scene alone,
		# so we load the first room and warp on first spot as usual
		_load_room_scene(first_room_scene, first_warp_entrance_spot_index)
	else:
		# In debug F6 play a specific room, we load InGame scene additively from
		# GameManager, and so we must not also load the first scene on top
		# However we must still register the initial room and warp PC to first spot (index 0)
		# so it's not in the wild, possibly outside the room area
		current_room_instance = room_on_ready
		_setup_room(0)

	# only play intro in first room, whether played normally or via F6
	var is_playing_first_room := not room_on_ready or room_on_ready.room_index == 0

	if is_playing_first_room:
		player_character.is_playing_cinematic = true

	# important when playing from main menu as we must revert the fade out
	# if F6 playing in-game scene / room, it will just fade in from scratch
	await TransitionScreen.fade_in_async(fade_in_speed)

	if is_playing_first_room:
		await play_intro_async()
		player_character.is_playing_cinematic = false


func _exit_tree():
	# Cleanup to avoid invalid reference
	GameManager.in_game_manager = null


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed(&"debug_game_restart"):
		if OS.has_feature("debug"):
			await TransitionScreen.fade_out_async(10.0)
			current_room_instance.queue_free()
			await get_tree().physics_frame

			# Clear Dialogic state completely (esp. dialogue variables)
			Dialogic.clear()

			# await should wait for end of frame, so we can safely call _change_scene_immediate here
			# below doesn't work, as a hack we set ingame_scene_path to main menu scene
			# and then it works...
			SceneLoader.change_scene_to_path(ingame_scene_path)
			#get_tree().reload_current_scene
			await TransitionScreen.fade_in_async(10.0)
	elif event.is_action_pressed(&"dialogic_auto_skip"):
		Dialogic.Inputs.auto_skip.enabled = true
	elif event.is_action_released(&"dialogic_auto_skip"):
		Dialogic.Inputs.auto_skip.enabled = false


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
	_setup_room(warp_entrance_spot_index)


func _setup_room(warp_entrance_spot_index: int):
	camera.set_camera_limits_for_room(current_room_instance)
	_warp_player_character_to_entrance_spot(warp_entrance_spot_index)


func _warp_player_character_to_entrance_spot(warp_entrance_spot_index: int):
	if warp_entrance_spot_index < current_room_instance.entrance_spots.size():
		player_character.global_position = current_room_instance.entrance_spots[warp_entrance_spot_index].global_position
		camera.move_instantly_to_player_character()
	else:
		push_error("[InGameManager] load_room_scene: for room scene '%s', warp_entrance_spot_index (%d) >= current_room_instance.entrance_spots.size() (%d)" %
			[current_room_instance.get_path(), warp_entrance_spot_index, current_room_instance.entrance_spots.size()])


func _queue_unload_current_room():
	current_room_instance.queue_free()


func play_intro_async():
	if not debug_skip_intro and OS.has_feature("debug"):
		var layout := Dialogic.start(first_dialogic_timeline)
		layout.register_character(GameManager.in_game_manager.dialogic_player_character, player_character)
		await Dialogic.timeline_ended

	ProjectMusicController.music_stream_player = audio_stream_player

	ProjectMusicController.music_stream_player.stream = bgm_ingame
	ProjectMusicController.play()
