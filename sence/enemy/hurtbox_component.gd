extends Area2D

signal hurt_entered
signal hurt_exited

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)


func on_area_entered(other_area : Area2D):
	if not other_area is HitboxComponent:
		return
	
	hurt_entered.emit(other_area)
	
func on_area_exited(other_area : Area2D):
	if not other_area is HitboxComponent:
		return
	
	hurt_exited.emit(other_area)
