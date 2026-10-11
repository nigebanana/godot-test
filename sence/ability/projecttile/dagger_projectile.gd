class_name DaggerProjectile
extends ProjectileBase

# 飞刀特有属性
@export var rotation_speed: float = 10.0  # 旋转速度
@export var fade_out_time: float = 0.2    # 消失淡出时间
@export var impact_strength: float = 5.0  # 击退强度

# 飞刀特有组件
@onready var shadow: Sprite2D = $Shadow  # 阴影
@onready var spin_animation: AnimationPlayer = $AnimationPlayer  # 旋转动画
@onready var hit_particles: CPUParticles2D = $HitParticles  # 命中粒子

# 运行时变量
var is_fading: bool = false
var fade_timer: float = 0.0

func _ready():
	super()
	$HitboxComponent.damage = damage
	
	# 飞刀特有初始化
	#setup_dagger_specifics()
	
	# 开始旋转动画
	if spin_animation:
		spin_animation.play("spin")

func _process(delta):
	super(delta)
	
	# 飞刀特有逻辑
	process_dagger_specifics(delta)
	
	# 淡出处理
	if is_fading:
		process_fade_out(delta)

# 飞刀特有初始化
func setup_dagger_specifics():
	# 设置碰撞形状为矩形（更适合飞刀）
	if hitbox and hitbox.has_node("CollisionShape2D"):
		var shape = RectangleShape2D.new()
		shape.size = Vector2(20, 5)  # 飞刀形状
		hitbox.get_node("CollisionShape2D").shape = shape
	
	# 设置拖尾颜色
	#if trail:
		#trail.gradient.colors[0] = Color(1, 1, 1, 0.8)
		#trail.gradient.colors[1] = Color(1, 1, 1, 0)

# 飞刀特有每帧处理
func process_dagger_specifics(delta):
	# 旋转效果（如果没用动画）
	#if not spin_animation and sprite:
		#sprite.rotation += rotation_speed * delta
	
	# 阴影跟随
	if shadow:
		shadow.global_position = global_position + Vector2(5, 5)
		shadow.rotation = rotation

# 淡出处理
func process_fade_out(delta):
	fade_timer -= delta
	var alpha = fade_timer / fade_out_time
	
	if sprite:
		sprite.modulate.a = alpha
	if trail:
		trail.modulate.a = alpha
	if shadow:
		shadow.modulate.a = alpha * 0.5
	
	if fade_timer <= 0:
		queue_free()

# 重写：击中敌人效果
func play_hit_effect(position: Vector2):
	# 播放命中音效
	#if audio_player and audio_player.stream:
		#audio_player.play()
	
	# 生成命中粒子
	if hit_particles:
		var particles = hit_particles.duplicate()
		particles.global_position = position
		particles.emitting = true
		get_parent().add_child(particles)
	
	# 击退效果
	if impact_strength > 0 and source:
		var enemy = get_last_hit_enemy()
		if enemy and enemy.has_method("knockback"):
			var knockback_dir = (enemy.global_position - source.global_position).normalized()
			enemy.knockback(knockback_dir * impact_strength)

# 重写：击中障碍物效果
func play_obstacle_hit_effect(position: Vector2):
	pass
	# 播放碰撞音效（不同的音效）
	#if audio_player and audio_player.stream:
		## 可以换一个更沉闷的音效
		#audio_player.play()
	
	# 生成碰撞粒子
	#var spark_particles = preload("res://effects/spark_particles.tscn")
	#if spark_particles:
		#var sparks = spark_particles.instantiate()
		#sparks.global_position = position
		#get_parent().add_child(sparks)

# 重写：覆盖消失行为
func expire():
	if not is_fading:
		is_fading = true
		fade_timer = fade_out_time
		
		# 禁用碰撞
		if hitbox:
			hitbox.monitoring = false
			hitbox.monitorable = false
		
		# 停止移动
		speed = 0
		
		# 发射信号
		expired.emit(self)

# 辅助方法：获取最后一个击中的敌人
func get_last_hit_enemy() -> Node2D:
	if enemies_hit.size() > 0:
		return enemies_hit[-1]
	return null

# 设置飞刀特有属性
func set_rotation_speed(value: float):
	rotation_speed = value

func set_impact_strength(value: float):
	impact_strength = value

# 可选：添加刀刃闪光效果
func enable_blade_flash():
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(2, 2, 2, 1), 0.1)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
