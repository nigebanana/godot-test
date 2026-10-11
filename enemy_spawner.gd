# EnemySpawner.gd
extends Node

@export var spawn_radius_min : float = 100.0      # 生成点距离玩家的最小距离
@export var spawn_radius_max : float = 300.0      # 最大距离
@export var max_enemies : int = 30                 # 全局最大敌人数（可选覆盖）
@export var enemies : Node2D = null   

var current_wave_data : EnemyWaveData
var enemy_count : int = 0     # 当前存在的敌人数量
var navigation_map = null     # 导航地图     
var current_wave_timer : Timer = null     

@onready var spawn_timer = $SpawnTimer
@onready var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	# 设置波次计时器
	# 获取导航地图
	var nav_region = get_tree().get_first_node_in_group("navigation_region")
	if nav_region:
		navigation_map = nav_region.get_navigation_map()
	else:
		push_error("EnemySpawner: NavigationRegion2D not found!")

func update_wave_parameters(data : EnemyWaveData, wave_timer: Timer):
	current_wave_data = data
	current_wave_timer = wave_timer
	if spawn_timer == null:
		spawn_timer = get_node("SpawnTimer")
	spawn_timer.wait_time = data.spawn_interval
	# 如果波次定义了最大同时敌人数，则使用它
	if data.max_concurrent_enemies > 0:
		max_enemies = data.max_concurrent_enemies

func _on_spawn_timer_timeout():
	if not current_wave_data:
		return
	
	# 检查是否达到敌人数量上限
	if enemy_count >= max_enemies:
		return
	
	# 计算生成位置：在玩家周围环形区域随机
	if not player:
		return
	
	# 当前波次阶段信息
	if not current_wave_data.wave_stages:
		return
		
	var wave_stages = current_wave_data.wave_stages as Array[WaveStage] 
	for stage in wave_stages:
		if not is_current_stage(stage):
			return
			
		var enemy_scene = stage.enemy_type
		# 生成敌人
		for i in stage.enemy_number:
			var angle = randf_range(0, 2 * PI)
			var distance = randf_range(spawn_radius_min, spawn_radius_max)
			var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
			
			# 最近可生成点
			var closest_pos = spawn_pos
			# 尝试10次如果无法找到有效位置，跳过此次生成
			for j in 10:
				closest_pos = NavigationServer2D.map_get_closest_point(navigation_map, spawn_pos)
				# 如果候选点与最近可行走点距离过大（比如大于5像素），则视为无效，重新尝试
				if closest_pos.distance_to(spawn_pos) > 5.0:
					if j == 10:
						return
					continue
			# 实例化敌人
			var enemy = enemy_scene.instantiate()
			enemies.add_child(enemy)   # 或添加到专门存放敌人的容器
			enemy.global_position = closest_pos
			
			# 连接敌人死亡信号以更新计数 enemy_died
			enemy.tree_exited.connect(_on_enemy_died.bind(enemy))
			enemy_count += 1

func is_current_stage(stage: WaveStage):
	var waveTotalTime = current_wave_timer.wait_time
	var elapsedTime  = current_wave_timer.wait_time - current_wave_timer.time_left
	# 当前时间在阶段时间内
	if waveTotalTime * stage.stage_start <= elapsedTime and elapsedTime <= waveTotalTime * stage.stage_end:
		return true


func _on_enemy_died(_enemy):
	enemies.remove_child(_enemy)
	enemy_count -= 1
