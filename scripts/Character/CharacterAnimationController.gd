class_name CharacterAnimationController
extends AnimationControllerBase


@export var character: PlayerCharacter


# override
## Return base animation based on owner state and last animation
func _get_base_animation(_last_animation: StringName) -> StringName:
	# Ex: "DOWN"
	var current_direction_enum_name = MathEnums.CardinalDirection.keys()[character.current_direction]
	# Ex: "Down"
	var current_direction_pascal_name = current_direction_enum_name.to_pascal_case()
	if character.velocity == Vector2.ZERO:
		return "Idle%s" % current_direction_pascal_name
	else:
		return "Walk%s" % current_direction_pascal_name
