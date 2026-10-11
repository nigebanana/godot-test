extends Resource
class_name WaveStage

@export_range(0, 1, 0.1, "prefer_slider") var stage_start : float  # 阶段开始时间段
@export_range(0, 1, 0.1, "prefer_slider") var stage_end : float  # 阶段结束时间段
@export var enemy_type : PackedScene        # 可用敌人场景
@export var enemy_number : int  # 数量（每次生成数量）
