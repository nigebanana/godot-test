class_name upgradeCard
extends PanelContainer

signal selected

var pending_data: AbilityData = null

@onready var name_label: Label = $VBoxContainer/HBoxContainer/UpgradeCardNameLabel
@onready var description_label: Label = $VBoxContainer/UpgradeCardDescriptionLabel
@onready var confirm_button: Button = $VBoxContainer/HBoxContainer2/ConfirmButton
@onready var recycle_button: Button = $VBoxContainer/HBoxContainer2/RecycleButton

var disabled = false


func _ready():
	print("upgrade card _ready 1：%s" %is_node_ready())
	mouse_entered.connect(on_mouse_entered)
	confirm_button.pressed.connect(on_confirm_button_pressed)
	recycle_button.pressed.connect(on_recycle_button_pressed)
	# 如果有等待设置的数据，现在设置
	if pending_data:
		set_ability_upgrade(pending_data)

func play_in(delay: float = 0):
	print("play_in")
	if not is_instance_valid(self):
		return
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	$AnimationPlayer.play("in")
	

func play_discard():
	print("play_discard")
	#$AnimationPlayer.play("discard")


func set_ability_upgrade(abilityData: AbilityData):
	print("upgrade card set_ability_upgrade 1：%s" %is_node_ready())
	print("name_label:", name_label)          # 看看是不是 null
	print("description_label:", description_label)  # 看看是不是 null
	if not is_node_ready():
		# 节点还没准备好，暂存数据
		pending_data = abilityData
		return
	print("abilityData abilityData.name：",
	  abilityData.name, " abilityData.description:", abilityData.description)
	name_label.text = abilityData.name
	description_label.text = abilityData.description


func select_card():
	disabled = true
	#$AnimationPlayer.play("selected")
	
	for other_card in get_tree().get_nodes_in_group("upgrade_card"):
		if other_card == self:
			continue
		other_card.play_discard()
	
	#await $AnimationPlayer.animation_finished
	selected.emit()


func on_mouse_entered():
	print("on_mouse_entered")
	if disabled:
		return
	#$HoverAnimationPlayer.play("hover")

func on_confirm_button_pressed():
	print("on_confirm_button_pressed")
	if disabled:
		return
	select_card()
	visible = false
	
func on_recycle_button_pressed():
	print("on_recycle_button_pressed")
	pass
	
