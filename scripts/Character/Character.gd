class_name Character
extends CharacterBody2D


## (Optional) Parent of all objects that should rotate by multiple of 90 degrees when character changes
## direction (generally InteractionArea for PlayerCharacter)
@export var directional_parent: Node2D

## Move speed applied to each cardinal axis (moving diagonally is sqrt(2) times faster)
@export var move_cardinal_speed: float = 200.0


## Move intention vector: ternary value (-1, 0, +1) for each cardinal axis
var move_intention: Vector2

## Current direction faced by character
var current_direction: MathEnums.CardinalDirection


func _ready():
	move_intention = Vector2.ZERO
	current_direction = MathEnums.CardinalDirection.DOWN


func _physics_process(_delta: float):
	if move_intention != Vector2.ZERO:
		_update_direction_toward(move_intention)

	velocity = move_cardinal_speed * move_intention
	move_and_slide()


func _update_direction_toward(direction_vector: Vector2):
	# DirectionalParent children must all face RIGHT in initial scene setup, as it is
	# Godot's angle reference
	current_direction = MathUtils.vector2i_to_dominant_cardinal_direction(direction_vector, true)
	if directional_parent:
		directional_parent.rotation = MathUtils.cardinal_direction_to_angle(current_direction)
