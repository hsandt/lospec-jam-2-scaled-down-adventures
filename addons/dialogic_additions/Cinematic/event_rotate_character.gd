@tool
extends DialogicEvent
class_name DialogicRotateCharacterEvent

# Define properties of the event here

var character: DialogicCharacter = null
var new_direction: MathEnums.CardinalDirection


### Helpers (copied from event_text.gd)

## Used to set the character resource from the unique name identifier and vice versa
var character_identifier: String:
	get:
		if character:
			var identifier := DialogicResourceUtil.get_unique_identifier(character.resource_path)
			if not identifier.is_empty():
				return identifier
		return character_identifier
	set(value):
		character_identifier = value
		character = DialogicResourceUtil.get_character_resource(value)

var regex := RegEx.create_from_string(r'rotate +((")?(?<name>(?(2)[^"\n]*|[^(: \n]*))(?(2)"|)?\s*:)\s*(?<direction>\w*)')


func _execute() -> void:
	# This will execute when the event is reached
	if character:
		var character_node := Dialogic.Styles.get_layout_node().registered_characters[character] as Character
		if character_node:
			character_node.update_direction(new_direction)
		else:
			push_error("[DialogicRotateCharacterEvent] _execute: character has no registered node to rotate")
	else:
		push_error("[DialogicRotateCharacterEvent] _execute: character is not set")

	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Rotate Character"
	event_category = "Cinematic"



#endregion

#region SAVING/LOADING
################################################################################

# this is only here to provide a list of default values
# this way the module manager can add custom default overrides to this event.
func get_shortcode_parameters() -> Dictionary:
	return {
		#param_name 		: property_info
		"character"		: {"property": "character_identifier", "default": ""},
		"new_direction"	: {"property": "new_direction", "default": "down"},
	}

# You can alternatively overwrite these 3 functions: to_text(), from_text(), is_valid_event()

################################################################################
## 						SAVING/LOADING
################################################################################

func to_text() -> String:
	var result := "rotate "

	if character:
		var name := DialogicResourceUtil.get_unique_identifier(character.resource_path)
		if name.count(" ") > 0:
			name = '"' + name + '"'
		result += name

	result += ": "

	var direction_text: String

	match new_direction:
		MathEnums.CardinalDirection.DOWN:
			direction_text = "down"
		MathEnums.CardinalDirection.LEFT:
			direction_text = "left"
		MathEnums.CardinalDirection.UP:
			direction_text = "up"
		MathEnums.CardinalDirection.RIGHT:
			direction_text = "right"

	result = result + direction_text

	return result


func from_text(string:String) -> void:
	# Load default character
	# This is only of relevance if the default has been overriden (usually not)
	character = DialogicResourceUtil.get_character_resource(character_identifier)

	var result := regex.search(string.trim_prefix('\\'))
	if result:
		var name := result.get_string('name').strip_edges()

		# Unlike event_text.gd, don't allow '_' convention, just check for empty name
		if not name:
			character = null
		else:
			character = DialogicResourceUtil.get_character_resource(name)

			if character == null and Engine.is_editor_hint() == false:
				character = DialogicCharacter.new()
				character.display_name = name
				character.resource_path = "user://"+name+".dch"
				DialogicResourceUtil.add_resource_to_directory(character.resource_path, DialogicResourceUtil.get_character_directory())

		var direction_text := result.get_string('direction').replace("\\\n", "\n").replace('\\:', ':').strip_edges().trim_prefix('\\')
		match direction_text:
			"down":
				new_direction = MathEnums.CardinalDirection.DOWN
			"left":
				new_direction = MathEnums.CardinalDirection.LEFT
			"up":
				new_direction = MathEnums.CardinalDirection.UP
			"right":
				new_direction = MathEnums.CardinalDirection.RIGHT
			_:
				new_direction = MathEnums.CardinalDirection.DOWN


func is_valid_event(string:String) -> bool:
	if string.strip_edges().begins_with("rotate"):
		return true
	return false


#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	## Copied from event_text.gd
	add_header_edit('character_identifier', ValueType.DYNAMIC_OPTIONS,
			{'file_extension' 	: '.dch',
			'mode'				: 2,
			'suggestions_func' 	: get_character_suggestions,
			'empty_text' 		: '(No one)',
			'icon' 				: load("res://addons/dialogic/Editor/Images/Resources/character.svg")}, 'do_any_characters_exist()')

	add_header_edit('new_direction', ValueType.FIXED_OPTIONS, {'left_text':'rotates toward ',
		'options': [
			{
				'label': 'Down',
				'value': MathEnums.CardinalDirection.DOWN,
			},
			{
				'label': 'Left',
				'value': MathEnums.CardinalDirection.LEFT,
			},
			{
				'label': 'Up',
				'value': MathEnums.CardinalDirection.UP,
			},
			{
				'label': 'Right',
				'value': MathEnums.CardinalDirection.RIGHT,
			},
		]})

## Copied from event_text.gd
static func do_any_characters_exist() -> bool:
	return !DialogicResourceUtil.get_character_directory().is_empty()

## Adapted from event_text.gd
static func get_character_suggestions(search_text:String) -> Dictionary:
	var suggestions := {}

	var icon = load("res://addons/dialogic/Editor/Images/Resources/character.svg")

	var character_directory := DialogicResourceUtil.get_character_directory()
	for resource in character_directory.keys():
		suggestions[resource] = {
				'value' 	: resource,
				'tooltip' 	: character_directory[resource],
				'icon' 		: icon.duplicate()}
	return suggestions

#endregion
