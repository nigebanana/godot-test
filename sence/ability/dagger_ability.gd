class_name DaggerAbility
extends AbilityBase

# 飞刀基础属性
@export var dagger_projectile_scene: PackedScene  # 飞刀场景
@export var dagger_count: int = 1       # 飞刀数量
@export var spread_angle: float = 60.0  # 扇形角度（度）
@export var dagger_speed: float = 400.0 # 飞刀速度
@export var dagger_damage: float = 15.0 # 飞刀伤害
@export var search_radius: float = 500.0 # 搜索敌人的半径
@export var dagger_ability_data : AbilityData

# 视觉效果
@export var cast_effect: PackedScene    # 施法特效
@export var hit_effect: PackedScene     # 命中特效

# 运行时变量
var target_enemy: Node2D = null
var all_enemies: Array = []

func _ready():
	super()
	ability_name = "飞刀技能"

# 重写能力执行逻辑
func perform_ability():
	#print_debug("perform_ability")
	super()
	
	# 查找最近的敌人
	find_nearest_enemy()
	
	if target_enemy:
		# 播放施法特效
		#spawn_cast_effect()
		
		# 发射扇形飞刀
		throw_daggers_to_target()
	else:
		print("没有找到敌人")

# 获取玩家（角色）的位置
func get_player_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO
	
	return player.global_position

# 查找最近的敌人
func find_nearest_enemy():
	all_enemies.clear()
	target_enemy = null
	
	# 获取所有在组"enemy"中的节点
	var enemies = get_tree().get_nodes_in_group("enemy")
	#print_debug("enemies:", enemies.size())
	
	if enemies.is_empty():
		print("enemies.is_empty")
		return
	
	var player_pos = get_player_position()
	var nearest_distance = search_radius
	var nearest_enemy = null
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
			
		var distance = player_pos.distance_to(enemy.global_position)
		#print_debug("search_radius:", search_radius, ",nearest_distance:", nearest_distance, ",distance:", distance)
		if distance <= search_radius and distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	target_enemy = nearest_enemy

# 向目标发射扇形飞刀
func throw_daggers_to_target():
	#print_debug("throw_daggers")
	if not target_enemy or not dagger_projectile_scene:
		print("not target_enemy or not dagger_projectile_scene", target_enemy, dagger_projectile_scene)
		dagger_projectile_scene = load("res://ability/projecttile/dagger_projectile.tscn")
		if not dagger_projectile_scene:
			print("not dagger_projectile_scene")
			return
	
	var player_pos = get_player_position()
	# 计算目标方向
	var target_direction = (target_enemy.global_position - player_pos).normalized()
	
	# 如果只有1把飞刀，直接射向目标
	print("dagger_count:", dagger_count)
	if dagger_count == 1:
		spawn_dagger(target_direction, player_pos)
		return
	
	# 计算扇形起始角度
	var start_angle = -spread_angle / 2.0
	var angle_step = spread_angle / (dagger_count - 1)
	
	# 生成多把飞刀
	for i in range(dagger_count):
		# 计算当前飞刀的角度偏移
		var current_angle_deg = start_angle + (angle_step * i)
		var current_angle_rad = deg_to_rad(current_angle_deg)
		
		# 旋转目标方向来获得飞刀方向
		var dagger_direction = target_direction.rotated(current_angle_rad)
		
		# 生成飞刀
		spawn_dagger(dagger_direction, player_pos)

# 生成单把飞刀
func spawn_dagger(direction: Vector2, spawn_pos: Vector2):
	#print_debug("spawn_dagger")
	if not dagger_projectile_scene:
		return
	
	var dagger = dagger_projectile_scene.instantiate() as DaggerProjectile
	
	# 设置飞刀属性
	dagger.set_damage(dagger_damage)
	dagger.set_speed(dagger_speed)
	
	# 设置位置和方向
	dagger.global_position = spawn_pos
	dagger.rotation = direction.angle()
	
	# 传递额外数据
	dagger.set_direction(direction)
	#dagger.set_source(character)  # 设置来源（角色）
	
	# 连接命中信号
	#if dagger.has_signal("hit_enemy"):
		#dagger.hit_enemy.connect(_on_dagger_hit.bind(dagger))
	
	# 添加到场景
	get_tree().current_scene.add_child(dagger)

# 播放施法特效
#func spawn_cast_effect():
	#if cast_effect:
		#var effect = cast_effect.instantiate()
		#effect.global_position = global_position
		#get_tree().current_scene.add_child(effect)

# 飞刀命中敌人时的处理
#func _on_dagger_hit(enemy: Node2D, dagger: Node2D):
	## 播放命中特效
	#if hit_effect:
		#var effect = hit_effect.instantiate()
		#effect.global_position = enemy.global_position
		#get_tree().current_scene.add_child(effect)
	
	# 可以在这里添加其他效果，比如击退、减速等

# 重写检查条件
#func can_activate() -> bool:
	## 先检查父类的基础条件
	#if not super():
		#return false
	#
	## 检查是否有敌人
	#find_nearest_enemy()
	#if not target_enemy:
		#print("没有目标敌人")
		#return false
	#
	#return true

## 重写描述
#func get_description() -> String:
	#var description = "向最近的敌人投掷 %d 把飞刀" % dagger_count
	#if spread_angle > 0:
		#description += "，呈 %.0f 度扇形" % spread_angle
	#description += "，每把造成 %.0f 点伤害" % dagger_damage
	#return description

# 调试用：在编辑器中显示搜索范围
func _draw():
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, search_radius, Color(1, 0, 0, 0.1))
		draw_arc(Vector2.ZERO, search_radius, 0, 2*PI, 32, Color(1, 0, 0, 0.5))
