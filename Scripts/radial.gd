extends TextureProgressBar

@export var monitoring_timer: Timer
@export var monitor_variable: String
@export var monitor_max_variable: String
@onready var parent = get_parent().get_parent()

func _ready():
	if !parent.is_multiplayer_authority():
		queue_free()
	if monitoring_timer:
		max_value = monitoring_timer.wait_time
	else:
		max_value = parent.get(monitor_max_variable)

func _process(_delta):
	if monitoring_timer:
		value = monitoring_timer.time_left
	else:
		value = parent.get(monitor_variable)
