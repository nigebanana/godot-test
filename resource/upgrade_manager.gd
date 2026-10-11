extends Node

@export var experience_manager: Node
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}


func _ready():
	experience_manager.level_updated.connect(on_level_up)
	

func apply_upgrade(upgrade: AbilityData):
	
	#update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


#func update_upgrade_pool(chosen_upgrade: AbilityData):
	#if chosen_upgrade.id == upgrade_axe.id:
		#upgrade_pool.add_item(upgrade_axe_damage, 10)


func pick_upgrades():
	var chosen_upgrades: Array[AbilityData] = []
	for i in 5:
		var chosen_upgrade = preload("res://resource/sword.tres")
		chosen_upgrades.append(chosen_upgrade)
	
	return chosen_upgrades


func on_upgrade_selected(upgrade: AbilityData):
	apply_upgrade(upgrade)


func on_level_up(current_level: int):
	print("on_level_up")
	var upgrade_select_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_select_instance)
	var chosen_upgrades = pick_upgrades()
	upgrade_select_instance.set_ability_upgrades(chosen_upgrades as Array[AbilityData])
	upgrade_select_instance.upgrade_selected.connect(on_upgrade_selected)
