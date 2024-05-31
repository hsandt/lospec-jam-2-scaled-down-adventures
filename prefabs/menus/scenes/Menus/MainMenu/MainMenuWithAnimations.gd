extends MainMenu

@export var bgm_title_intro_loop: AudioStream

# used as fallback
@export var bgm_title_intro: AudioStream
@export var bgm_title_loop: AudioStream

## Speed factor for fade out animation
@export var fade_out_speed: float = 1.0


var animation_state_machine : AnimationNodeStateMachinePlayback

func intro_done():
	animation_state_machine.travel("OpenMainMenu")

func _is_in_intro():
	return animation_state_machine.get_current_node() == "Intro"

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _event_skips_intro(event : InputEvent):
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

func _open_sub_menu(menu):
	super._open_sub_menu(menu)
	animation_state_machine.travel("OpenSubMenu")

func _close_sub_menu():
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")

func _input(event):
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
	super._input(event)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		# Close sub menu, if any
		_close_sub_menu()

func _ready():
	super._ready()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")

	# CUSTOM
	ProjectMusicController.music_stream_player = $AudioStreamPlayer

	if bgm_title_intro_loop:
		ProjectMusicController.music_stream_player.stream = bgm_title_intro_loop
		ProjectMusicController.play()
	else:
		ProjectMusicController.music_stream_player.stream = bgm_title_intro
		ProjectMusicController.play()
		await ProjectMusicController.music_stream_player.finished
		ProjectMusicController.music_stream_player.stream = bgm_title_loop
		ProjectMusicController.play()

func _disable_button_including_focus(button: Button):
	button.disabled = true
	button.focus_mode = Control.FOCUS_NONE

# override
func play_game():
	_disable_button_including_focus(%PlayButton)
	_disable_button_including_focus(%OptionsButton)
	_disable_button_including_focus(%CreditsButton)
	_disable_button_including_focus(%ExitButton)

	ProjectMusicController.fade_out(1.0)
	await TransitionScreen.fade_out_async(fade_out_speed)
	super.play_game()
