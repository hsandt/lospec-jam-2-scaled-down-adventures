extends Node


@export var in_game_scene: PackedScene

@onready var in_game_manager: InGameManager = get_tree().get_first_node_in_group("in_game_manager")
@onready var room_in_played_scene: Room = get_tree().get_first_node_in_group("rooms")


func _ready():
	DebugUtils.assert_member_is_set(self, in_game_scene, "in_game_scene")

	# Check if we are directly F6 playing a Room scene instead of playing
	# the InGame scene (identified by the InGameManager)
	if room_in_played_scene and not in_game_manager:
		# To make it easy to debug game from any Room scene,
		# dynamically load the InGame scene now (it will detect the existing
		# room on its own ready and therefore not try to load the first scene on top)
		# Note: we let InGameManager's own _ready register themselves to GameManager,
		# so it works the same way as when normally loading InGame scene from main menu
		# in the end
		NodeUtils.instantiate_under_deferred(in_game_scene, get_tree().root)
