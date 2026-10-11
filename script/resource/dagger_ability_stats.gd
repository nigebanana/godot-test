extends AbilityStats
class_name DaggerAbilitySta
# 基础伤害（每级数值，索引0对应1级）
@export var damage: Array[int] = []

# 冷却时间（每级数值，单位：秒）
@export var cooldown: Array[float] = []

# 持续时间（每级数值，单位：秒）
@export var duration: Array[float] = []

# 生效次数/穿透次数等
@export var hit_count: Array[int] = []

# 投射物数量
@export var projectile_count: Array[int] = []

# 范围/半径（单位：像素或游戏单位）
@export var radius: Array[float] = []

# 速度
@export var speed: Array[float] = []

# 获取指定等级的具体属性值
# 参数: level 从1开始
func get_damage(level: int) -> int:
	return damage[level - 1] if damage.size() >= level else 0

func get_cooldown(level: int) -> float:
	return cooldown[level - 1] if cooldown.size() >= level else 0.0

func get_duration(level: int) -> float:
	return duration[level - 1] if duration.size() >= level else 0.0

func get_hit_count(level: int) -> int:
	return hit_count[level - 1] if hit_count.size() >= level else 1

func get_projectile_count(level: int) -> int:
	return projectile_count[level - 1] if projectile_count.size() >= level else 1

func get_radius(level: int) -> float:
	return radius[level - 1] if radius.size() >= level else 0.0

func get_speed(level: int) -> float:
	return speed[level - 1] if speed.size() >= level else 0.0
