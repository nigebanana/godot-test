extends Node

signal experience_updated(current_experience: float, target_experience: float)
signal level_updated(new_level: int)

const TARGET_EXPERIENCE_GROWTH = 5

var current_experience = 0
var current_level = 1
var target_experience = 5


func _ready():
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)


func increment_experience(number: float):
	current_experience += number
	while current_experience >= target_experience:
		number = (current_experience - target_experience)
		level_up()
		# 升级后 current_experience 重置为 0，target_experience 已增加
		current_experience += number
	experience_updated.emit(current_experience, target_experience)

func level_up():
	current_level += 1
	current_experience = 0
	target_experience += TARGET_EXPERIENCE_GROWTH
	level_updated.emit(current_level)
	
# 信号连接区域-------------------------------------------------------
# 经验获取处理
func on_experience_vial_collected(number: float):
	print("on_experience_vial_collected number：", number)
	increment_experience(number)
	
