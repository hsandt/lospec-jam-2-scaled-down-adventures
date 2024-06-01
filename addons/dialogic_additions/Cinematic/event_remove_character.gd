@tool
extends DialogicEvent
class_name DialogicRemoveCharacterEvent

# Define properties of the event here

var character: DialogicCharacter = null


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

var regex := RegEx.create_from_string(r'remove +((")?(?<name>(?(2)[^"\n]*|[^(: \n]*))(?(2)"|)?)')


func _execute() -> void:
	# This will execute when the event is reached
	if character:
		var character_node := Dialogic.Styles.get_layout_node().registered_characters[character] as Character
		if character_node:
			await character_node.remove_after_fade_out()
		else:
			push_error("[DialogicRemoveCharacterEvent] _execute: character has no registered node to remove")
	else:
		push_error("[DialogicRemoveCharacterEvent] _execute: character is not set")

	finish() # called to continue with the next event


#region INITIALIZE
################################################################################
# Set fixed settings of this event
func _init() -> void:
	event_name = "Remove Character"
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
	var result := "remove "

	if character:
		var name := DialogicResourceUtil.get_unique_identifier(character.resource_path)
		if name.count(" ") > 0:
			name = '"' + name + '"'
		result += name

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


func is_valid_event(string:String) -> bool:
	if string.strip_edges().begins_with("remove"):
		return true
	return false


#endregion


#region EDITOR REPRESENTATION
################################################################################

func build_event_editor() -> void:
	## Copied from event_text.gd
	add_header_edit('character_identifier', ValueType.DYNAMIC_OPTIONS,
			{'left_text':'Remove',
			'file_extension' 	: '.dch',
			'mode'				: 2,
			'suggestions_func' 	: get_character_suggestions,
			'empty_text' 		: '(No one)',
			'icon' 				: load("res://addons/dialogic/Editor/Images/Resources/character.svg")}, 'do_any_characters_exist()')

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
