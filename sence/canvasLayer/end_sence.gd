extends CanvasLayer

@onready var start_button : Button = $"Start Button"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.pressed.connect(on_start_button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func on_start_button_pressed():
	# main场景
	get_tree().paused = false
	var sence = load("uid://blq5krtk2bsg3")
	get_tree().change_scene_to_packed(sence)
