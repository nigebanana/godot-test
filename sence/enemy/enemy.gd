extends CharacterBody2D

signal enemy_died

# 移动速度
@export var speed: float = 70.0
@export var damage: float = 2.0

@onready var enemyAniSprite = $AnimatedSprite2D
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var healthComponent = $HealthComponent
@onready var healthBar: ProgressBar  = $HealthBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 设置导航代理参数
	navigation_agent.path_desired_distance = 10.0  # 到达目标多远就算到达
	navigation_agent.target_desired_distance = 10.0  # 距离目标多远停止
	
	$HurtboxComponent.hurt_entered.connect(on_hurt_entered)
	$HitboxComponent.damage = damage
	healthComponent.died.connect(on_enemy_died)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	
	#var direction = (player.global_position - global_position).normalized()
	var direction = player.global_position
	navigation_agent.target_position = direction
	# 检查导航代理是否准备好
	if navigation_agent.is_navigation_finished():
		# 已经到达目标附近，停止移动
		velocity = Vector2.ZERO
		return
	
	# 获取下一个路径点
	var next_position = navigation_agent.get_next_path_position()
	
	# 计算移动方向
	var move_direction = (next_position - global_position).normalized()
	# 翻转
	if move_direction.x != 0:
		enemyAniSprite.flip_h = move_direction.x < 0
	
	# 设置速度
	var desired_velocity = move_direction * speed
	velocity = velocity.lerp(desired_velocity, 1 - exp(-0.5 * get_process_delta_time()))
	move_and_slide()
	enemyAniSprite.play("run")
	
func on_hurt_entered(hitbox: HitboxComponent):
	healthComponent.sub_current_health(hitbox.damage)
	update_health_display()
	

func update_health_display():
	healthBar.value = healthComponent.get_health_percent()
	
	
func on_enemy_died():
	#enemyAniSprite.play("death")
	enemy_died.emit(self)
