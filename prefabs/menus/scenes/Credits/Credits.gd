@tool
extends Credits


@onready var scroll_container: ScrollContainer = $ScrollContainer
var scroll_container_content: Control

## Vertical scrolling stored as float for extra precision, required in such
## a lores game, to allow lower speeds than 1px/s
var stored_scroll_vertical: float


func _ready():
	super._ready()

	assert(scroll_container.get_child_count() == 1, "[custom Credits] scroll_container at %s does not have exactly 1 child" % scroll_container.get_path())

	scroll_container_content = scroll_container.get_child(0)


func reset():
	$ScrollContainer.scroll_vertical = 0
	stored_scroll_vertical = 0.0
	scroll_active = true
	set_header_and_footer()

func _check_end_reached(previous_scroll):
	# IMPROVED by hsandt:
	# checking that previous_scroll changed works ok for integers, to detect
	# that we hit the end, but when using floats we may not move by a full pixel
	# yet be still scrolling, so unreliable
	# instead, be pragmatic: just check if reached end of scrolling
	# however this needs more complex calculation

	# HOTFIX for scroll_container.get_v_scroll_bar().max_value being incorrect
	# See https://godotengine.org/qa/111691/how-find-the-max-value-scroll_horizontal-scrollcontainer
	# and https://www.reddit.com/r/godot/comments/bu9wvc/anyone_know_how_to_get_scrollcontainers_scroll/
	var v_scroll_bar_max = max(0, scroll_container_content.size.y - size.y)

	# in theory == just works, but to be safe I use >=
	if $ScrollContainer.scroll_vertical >= v_scroll_bar_max:
		_end_reached()

func _scroll_container(amount : float) -> void:
	if not scroll_active or scroll_paused or amount == 0.0:
		return
	var previous_scroll = $ScrollContainer.scroll_vertical
	# apply float amount for high precision, then round
	stored_scroll_vertical += amount
	$ScrollContainer.scroll_vertical = round(stored_scroll_vertical)
	_check_end_reached(previous_scroll)
