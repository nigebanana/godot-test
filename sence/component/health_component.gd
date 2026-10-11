extends Node
class_name HealthComponent

signal died
signal health_changed

@export var max_health: float = 10
var current_health
var isDied = false

func _ready():
	current_health = max_health


func sub_current_health(amount: float):
	print("sub_current_health:", amount)
	current_health = max(current_health - amount, 0)
	health_changed.emit()
	Callable(check_death).call_deferred()


func add_current_health(amount: float):
	sub_current_health(-amount)


func sub_max_health(amount: float):
	max_health = max(max_health - amount, 0)
	health_changed.emit()
	Callable(check_death).call_deferred()


func add_max_health(amount: float):
	current_health = current_health + amount
	sub_max_health(-amount)


func get_health_percent():
	if max_health <= 0:
		return 0
	return min(current_health / max_health, 1)


func check_death():
	#print("current_health:", current_health)
	if current_health == 0:
		if isDied:
			return;
		isDied = true
		print("check_death died")
		died.emit()
		owner.queue_free()
