class_name ProjectileBase
extends Node2D

enum BulletMode { BOUNCE, PIERCE }
# 基础属性
@export var damage: float = 0
@export var speed: float = 300.0
@export var max_distance: float = 1000.0  # 最大飞行距离
@export var lifetime: float = 3.0         # 最大生命时间（秒）
@export var piercing: int = 0              # 穿透次数（0表示不穿透，-1表示无限穿透）
@export var homing_strength: float = 0.0   # 追踪强度（0表示直线）
@export var bounces: int = 0 			# 反弹次数
@export var mode: BulletMode = BulletMode.BOUNCE  # 默认反弹

# 组件引用
@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $HitboxComponent
@onready var visuals: Node2D = $Visuals
@onready var trail: Line2D = $Trail
@onready var lifetime_timer: Timer = $LifetimeTimer
#@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# 运行时变量
var direction: Vector2 = Vector2.RIGHT
var source: Node2D  # 发射者
var start_position: Vector2
var enemies_hit: Array = []  # 已经击中的敌人（用于穿透）
var current_pierce_count: int = 0 #当前穿透次数
var current_bounce_count: int = 0 #当前弹反次数
var target: Node2D  # 追踪目标

# 信号
signal hit_enemy(enemy: Node2D, projectile: ProjectileBase)
signal hit_obstacle(collision_point: Vector2, projectile: ProjectileBase)
signal expired(projectile: ProjectileBase)

func _ready():
	start_position = global_position
	rotation = direction.angle()
	
	# 连接信号
	setup_connections()
	
	# 启动生命周期计时器
	if lifetime > 0:
		lifetime_timer.wait_time = lifetime
		lifetime_timer.timeout.connect(_on_lifetime_timeout)
		lifetime_timer.start()

func _process(delta):
	# 移动投射物
	move_projectile(delta)
	
	# 检查最大距离
	if max_distance > 0:
		var distance_traveled = global_position.distance_to(start_position)
		if distance_traveled >= max_distance:
			expire()

# 移动逻辑（可重写）
func move_projectile(delta):
	if direction == Vector2.ZERO:
		return
	
	# 追踪逻辑
	if homing_strength > 0 and target and is_instance_valid(target):
		var target_dir = (target.global_position - global_position).normalized()
		var weight = 1.0 - exp(-homing_strength * delta)
		direction = direction.lerp(target_dir, weight).normalized()
		rotation = direction.angle()
	
	# 移动
	position += direction * speed * delta
	
	# 更新拖尾
	#update_trail()

# 设置连接（可重写）
func setup_connections():
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_entered)
		hitbox.area_entered.connect(_on_hitbox_entered)

# 击中处理
func _on_hitbox_entered(hit_object: Node2D):
	# 忽略发射者
	if hit_object == source:
		return
	
	# 检查是否是敌人
	if hit_object.is_in_group("enemy"):
		handle_enemy_hit(hit_object)
	# 检查是否是障碍物
	#elif hit_object.is_in_group("obstacle") or hit_object is StaticBody2D:
		#handle_obstacle_hit(hit_object)

# 处理击中敌人
func handle_enemy_hit(enemy: Node2D):
	# 检查是否已经击中过（防止多次击中同一敌人）
	if enemy in enemies_hit:
		return
	
	# 记录击中的敌人
	enemies_hit.append(enemy)
	
	# 应用伤害
	#if enemy.has_method("take_damage"):
		#enemy.take_damage(damage, source)
	
	# 发射信号
	hit_enemy.emit(enemy, self)
	
	# 播放命中效果
	play_hit_effect(enemy.global_position)
	
	match mode:
		BulletMode.BOUNCE:
			handle_bounce(enemy)
		BulletMode.PIERCE:
			handle_piercing()
	

# 处理击中障碍物
func handle_obstacle_hit(obstacle: Node2D):
	hit_obstacle.emit(global_position, self)
	play_obstacle_hit_effect(global_position)
	expire()

# 处理反弹
func handle_bounce(enemy: Node2D):
	if current_bounce_count >= bounces:
		queue_free()
		return
	# 1. 造成伤害（无衰减）
	enemies_hit.append(enemy)
	current_bounce_count += 1
	
	# 3. 寻找下一个目标
	var next_target = _find_nearest_enemy(global_position, enemies_hit)
	if next_target == null:
		queue_free()
		return
	
	target = next_target
	# 4. 重新定向
	direction = (next_target.global_position - global_position).normalized()

func _find_nearest_enemy(from_pos: Vector2, exclude_list: Array) -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest: Node2D = null
	var min_dist_sq: float = INF
	
	for e in enemies:
		if exclude_list.has(e):
			continue
		var dist_sq = from_pos.distance_squared_to(e.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest = e
	return nearest

# 处理穿透逻辑
func handle_piercing():
	current_pierce_count += 1
	if piercing == -1 or current_pierce_count <= piercing:
		return
	else:
		expire()

# 生命周期结束
func _on_lifetime_timeout():
	expire()

# 投射物消失
func expire():
	expired.emit(self)
	queue_free()

# 播放命中效果（可重写）
func play_hit_effect(position: Vector2):
	# 子类实现
	pass

# 播放障碍物命中效果（可重写）
func play_obstacle_hit_effect(position: Vector2):
	# 子类实现
	pass

# 更新拖尾（可重写）
func update_trail():
	if trail:
		trail.add_point(global_position)
		if trail.get_point_count() > 10:
			trail.remove_point(0)

# 设置方法
func set_damage(value: float):
	damage = value

func set_speed(value: float):
	speed = value

func set_direction(value: Vector2):
	direction = value.normalized()
	rotation = direction.angle()

func set_source(value: Node2D):
	source = value

func set_target(value: Node2D):
	target = value

# 工具方法
func is_valid() -> bool:
	return is_instance_valid(self) and not is_queued_for_deletion()
