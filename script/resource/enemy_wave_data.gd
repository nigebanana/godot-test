# enemy_wave_data.gd
extends Resource
class_name EnemyWaveData

@export var wave_number : int = 1
@export var spawn_interval : float = 2.0               # 生成间隔（秒）
@export var max_concurrent_enemies : int = 30          # 最大同时存在敌人数量
@export var wave_duration : float = 60.0                # 波次持续时间（秒），0表示无限
@export var wave_stages : Array[WaveStage]  
