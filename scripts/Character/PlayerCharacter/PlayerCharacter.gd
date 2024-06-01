class_name PlayerCharacter
extends Character

## Area to detect interactable in
@export var interaction_area: Area2D


## Is the character interacting with something or someone?
var is_interacting: bool

## Is the character acting for a cinematic?
var is_playing_cinematic: bool


func _ready():
	DebugUtils.assert_member_is_set(self, interaction_area, "interaction_area")

	is_interacting = false
	is_playing_cinematic = false


func _process(_delta: float):
	if can_move_freely():
		# Classic ternary input (-1, 0, +1) for each component via sign()
		move_intention = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).sign()
	else:
		move_intention = Vector2.ZERO


func _unhandled_input(event: InputEvent):
	# check if a dialog is already running or if any other interaction is running
	if Dialogic.current_timeline != null or is_interacting or is_playing_cinematic:
		return

	# Exact match to avoid conflicts with Alt+Enter
	if event.is_action_pressed(&"dialogic_default_action", false, true):
		_process_interact()
		get_viewport().set_input_as_handled()


func can_move_freely() -> bool:
	return !is_interacting and !is_playing_cinematic


func can_interact() -> bool:
	# character cannot interrupt interaction with another interaction
	return !is_interacting and !is_playing_cinematic


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
