# 能力基类（方案 A：_process 手动倒计时 + 自动循环释放）
class_name AbilityBase
extends Node2D

# 能力基本属性
@export var ability_name: String = "能力名称"
@export var cooldown_time: float = 1.0
@export var mana_cost: float = 0.0
@export var icon: Texture2D

# 状态变量
var is_on_cooldown: bool = false
var current_cooldown: float = 0.0
#var character: Node  # 持有该能力的角色引用

# 信号
signal ability_activated          # 每次真正释放技能时发出
signal cooldown_started
signal cooldown_finished

func _ready():
	pass

func _process(delta):
	# 冷却推进
	if is_on_cooldown:
		current_cooldown -= delta
		if current_cooldown <= 0:
			finish_cooldown()

	# 自动释放：不在冷却中且可激活时，立刻放
	if not is_on_cooldown and can_activate():
		activate()

# 激活能力
func activate() -> bool:
	if not can_activate():
		return false

	# 扣除消耗
	#if character and character.has_method("use_mana"):
		#character.use_mana(mana_cost)

	start_cooldown()
	perform_ability()
	return true

# 检查是否能激活（子类可扩展）
func can_activate() -> bool:
	if is_on_cooldown:
		return false

	#if character and character.has_method("get_current_mana"):
		#if character.get_current_mana() < mana_cost:
			#return false

	return true

# 执行能力逻辑（子类重写，放真正的技能效果）
func perform_ability():
	ability_activated.emit()
	pass

# 开始冷却
func start_cooldown():
	if cooldown_time > 0:
		is_on_cooldown = true
		current_cooldown = cooldown_time
		cooldown_started.emit()

# 结束冷却
func finish_cooldown():
	is_on_cooldown = false
	current_cooldown = 0.0
	cooldown_finished.emit()

# 获取冷却进度（0-1，剩余比例：1=刚进入冷却，0=冷却完毕）
func get_cooldown_progress() -> float:
	if not is_on_cooldown:
		return 0.0
	return current_cooldown / cooldown_time

# 获取描述信息（可重写）
func get_description() -> String:
	return "基础能力描述"
