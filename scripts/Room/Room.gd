class_name Room
extends TileMap


## Array of entrance spots, indexed from 0
## Warping from another room sends the player character there
@export var entrance_spots: Array[Node2D]


@onready var camera_limit_top_left: Node2D = $CameraLimit_TopLeft
@onready var camera_limit_bottom_right: Node2D = $CameraLimit_BottomRight

