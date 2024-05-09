extends CharacterBody2D


## Move speed applied to each cardinal axis (moving diagonally is sqrt(2) times faster)
@export var move_cardinal_speed: float = 100.0

## Move intention vector: ternary value (-1, 0, +1) for each cardinal axis
var move_intention: Vector2


func _process(_delta: float):
	move_intention = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))


func _physics_process(_delta: float):
	velocity = move_cardinal_speed * move_intention
	move_and_slide()
