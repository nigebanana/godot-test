# WaveManager.gd
extends Node

signal wave_changed(wave_index : int, wave_data : EnemyWaveData)

@export var waves : Array[EnemyWaveData]           # 使用 Resource 方案
var current_wave_index : int = 0
var current_wave_data : EnemyWaveData :
	get:
		return waves[current_wave_index] if waves.size() > 0 else null

@onready var spawner = $"../EnemySpawner"
@onready var wave_timer = $WaveTimer

func _ready():
	# 设置波次计时器
	wave_timer.one_shot = true
	wave_timer.timeout.connect(_on_wave_timer_timeout)
	add_child(wave_timer)
	
	# 启动第一波
	start_wave(0)

func start_wave(index : int):
	print("第几波:", index + 1)
	if index >= waves.size():
		# 所有波次结束，可循环或结束游戏
		print("第几波，结束", index + 1)
		# 结束游戏
		#get_tree().quit()
		# 转换场景
		#get_tree().change_scene_to_file("res://sence/main/main.tscn")
		# 暂停游戏
		get_tree().paused = true
		# 显示胜利界面（通过节点路径或组获取）
		$"../EndSence".show()
		return
	
	current_wave_index = index
	var wave_data = current_wave_data
	wave_timer.wait_time = wave_data.wave_duration
	wave_timer.start()
	
	# 通知生成器更新参数
	spawner.update_wave_parameters(wave_data, wave_timer)
	wave_changed.emit(index, wave_data)

func _on_wave_timer_timeout():
	# 时间到，进入下一波
	start_wave(current_wave_index + 1)
