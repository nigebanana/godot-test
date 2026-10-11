extends CanvasLayer

signal upgrade_selected(abilityData: AbilityData)

@export var upgrade_card_scene: PackedScene

@export var card_container: HBoxContainer

#@onready var card_container: HBoxContainer = $%CardContainer


func _ready():
	get_tree().paused = true


func set_ability_upgrades(abilityDatas: Array[AbilityData]):
	var delay = 0
	for abilityData in abilityDatas:
	#for i in 3:
		var card_instance = upgrade_card_scene.instantiate()
		card_container.add_child(card_instance)
		await get_tree().process_frame
		print("card_instance")
		card_instance.set_ability_upgrade(abilityData)
		#card_instance.play_in(delay)
		card_instance.selected.connect(on_upgrade_selected.bind(abilityData))
		delay += .2


func on_upgrade_selected(abilityData: AbilityData):
	upgrade_selected.emit(abilityData)
	#$AnimationPlayer.play("out")
	#await $AnimationPlayer.animation_finished
	get_tree().paused = false
	queue_free()
