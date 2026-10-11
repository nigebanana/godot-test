extends CharacterBody2D

@onready var damageIntervalTimer = $DamageIntervalTimer
@onready var aniSprite = $AnimatedSprite2D
@onready var healthComponent = $HealthComponent
@onready var healthBar: ProgressBar  = $HealthBar
@onready var abilitys : Node = $abilitys
var attack_finished: bool = true
var isDamageIntervalTimer: bool = true
# 存储当前重叠的Hitbox
var active_hitboxes: Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HurtboxComponent.hurt_entered.connect(on_hurt_entered)
	$HurtboxComponent.hurt_exited.connect(on_hurt_exited)
	damageIntervalTimer.timeout.connect(on_damage_interval_timer_timeout)
	healthComponent.died.connect(on_player_died)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	
	update_health_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !attack_finished:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
			attack_finished = false
			aniSprite.play("attack")
			# 等待攻击动画完成
			await aniSprite.animation_finished
			attack_finished = true
			
	
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction.length() > 0:
		velocity = input_direction * 200
		move_and_slide()
		# 翻转精灵方向
		if input_direction.x != 0:
			aniSprite.flip_h = input_direction.x < 0
		aniSprite.play("run")
	else:
		aniSprite.play("idle")

		
func handle_input():
	if Input.is_action_just_pressed("ui_accept"):
			aniSprite.play("attack")
			# 等待攻击动画完成
			await aniSprite.animation_finished
	
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction.length() > 0:
		velocity = input_direction * 200
		move_and_slide()
		# 翻转精灵方向
		if input_direction.x != 0:
			aniSprite.flip_h = input_direction.x < 0
		aniSprite.play("run")
	else:
		aniSprite.play("idle")

func on_damage_interval_timer_timeout():
	isDamageIntervalTimer = true
	check_take_damage()
	
		
func on_hurt_entered(hitbox: HitboxComponent):
	active_hitboxes.append(hitbox)
	check_take_damage()


func on_hurt_exited(hitbox: HitboxComponent):	
	active_hitboxes.erase(hitbox)
	

func check_take_damage():
	if active_hitboxes.size() == 0 || !isDamageIntervalTimer:
		return;
	
	var totalDamage = get_total_damage()
	print("player hurt damage", totalDamage)
	# 受伤扣血
	healthComponent.sub_current_health(totalDamage)
	update_health_display()
	# 无敌帧
	isDamageIntervalTimer = false
	damageIntervalTimer.start()
	print("player curHealth：", healthComponent.current_health)


func get_total_damage() -> int:
	var total = 0
	for hitbox in active_hitboxes:
		total += hitbox.damage
	return total


func update_health_display():
	healthBar.value = healthComponent.get_health_percent()
	
	
func on_player_died():
		get_tree().paused = true
		# 显示胜利界面（通过节点路径或组获取）
		$"../EndSence".show()
		

func on_ability_upgrade_added(upgrade: AbilityData, current_upgrades: Dictionary):
	#abilitys.add_child()
	return
	
		
#func get_movement_vector():
	#var x_movement = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	#var y_movement = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	#return Vector2(x_movement, y_movement)
