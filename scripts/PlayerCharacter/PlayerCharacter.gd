class_name PlayerCharacter
extends CharacterBody2D


## Parent of all objects that should rotate by multiple of 90 degrees when character changes
## direction (generally Area2D nodes)
@export var directional_parent: Node2D

## Area to detect interactable in
@export var interaction_area: Area2D

## Move speed applied to each cardinal axis (moving diagonally is sqrt(2) times faster)
@export var move_cardinal_speed: float = 100.0


## Move intention vector: ternary value (-1, 0, +1) for each cardinal axis
var move_intention: Vector2

## Is the character interacting with something or someone?
var is_interacting: bool


func _ready():
	DebugUtils.assert_member_is_set(self, directional_parent, "directional_parent")
	DebugUtils.assert_member_is_set(self, interaction_area, "interaction_area")


func _process(_delta: float):
	if can_move():
		move_intention = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	else:
		move_intention = Vector2.ZERO


func _physics_process(_delta: float):
	if move_intention != Vector2.ZERO:
		_update_direction_toward(move_intention)

	velocity = move_cardinal_speed * move_intention
	move_and_slide()


func _unhandled_input(event: InputEvent):
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return

	if event.is_action_pressed(&"dialogic_default_action"):
		_process_interact()
		get_viewport().set_input_as_handled()


func _update_direction_toward(direction_vector: Vector2):
	# DirectionalParent children must all face RIGHT in initial scene setup, as it is
	# Godot's angle reference
	var cardinal_direction := MathUtils.vector2i_to_dominant_cardinal_direction(direction_vector, true)
	directional_parent.rotation = MathUtils.cardinal_direction_to_angle(cardinal_direction)


func can_move() -> bool:
	return !is_interacting


func can_interact() -> bool:
	# character cannot interrupt interaction with another interaction
	return !is_interacting


func _process_interact():
	if can_interact():
		# find all interactables in front of player character
		var interactable_candidates := interaction_area.get_overlapping_areas()

		# usually interactables are not too close to every other, so no need for priority
		# system, just pick the first one if any
		if interactable_candidates:
			_interact_async(interactable_candidates[0])


# Play full interaction from start to end
func _interact_async(interactable_area: InteractableArea):
	is_interacting = true
	await interactable_area.interactable.interact_async()
	is_interacting = false
