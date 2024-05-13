extends Node2D


func _unhandled_input(event: InputEvent):
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return

	#if event.is_action_pressed(&"dialogic_default_action"):
		#Dialogic.start('timeline')
		#get_viewport().set_input_as_handled()
