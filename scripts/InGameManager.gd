extends Node


## First room to load and bind camera to
@export var first_room_scene: PackedScene

@onready var camera: InGameCamera = $%InGameCamera

var current_room_instance: Room


func _ready():
	DebugUtils.assert_member_is_set(self, first_room_scene, "first_room_scene")

	deferred_ready.call_deferred()


## Post-ready setup (so all nodes are ready)
func deferred_ready():
	# This must be deferred because it relies on parent node's own ready, else we get error:
	# "Parent node is busy setting up children, `add_child()` failed. Consider using `add_child.call_deferred(child)` instead."
	load_room_scene(first_room_scene)


func load_room_scene(room_scene: PackedScene):
	# instantiate room scene below same parent (InGame root node)
	current_room_instance = NodeUtils.instantiate_under(room_scene, get_parent())
	setup_room()


func setup_room():
	camera.set_camera_limits_for_room(current_room_instance)
