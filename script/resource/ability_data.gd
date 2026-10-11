extends Resource
class_name AbilityData

## ---------- 通用属性 ----------
# 能力唯一标识符
@export var id: String
# 能力显示名称
@export var name: String
# 能力描述
@export_multiline() var description: String
# 能力图标
@export var icon: Texture2D
# 能力类型
@export var ability_type: String = "passive"  # "active", "passive", "weapon"
# 最大等级（0表示不可升级，1表示仅1级）
@export var max_level: int = 20
# 当前技能等级
@export var current_level: int = 1


## ---------- 基础属性 ----------
## 基础伤害
@export_category("base attribute")
@export var base_damage: float
## 基础冷却时间（秒）
@export var base_cooldown: float
## 基础攻击范围
@export var base_range: float
## 基础弹体速度
@export var base_speed: float

## ---------- 成长规则 ----------
## 每级增长值 { "damage": 2.0, "cooldown": -0.1, ... }
@export var growth: Dictionary = {
	"damage": 2.0,
	"cooldown": -0.1,
	"range": 10.0,
	"speed": 20.0
}
## 可升级的属性列表（用于生成升级卡片）
@export var upgradeable_attrs: Array[String] = ["damage", "cooldown", "range", "speed"]

# 能力属性集合（每级数值）
@export var stats: AbilityStats


# 获取指定等级的伤害
func get_damage(level: int) -> int:
	return stats.get_damage(level) if stats else 0

# 获取指定等级的冷却时间
func get_cooldown(level: int) -> float:
	return stats.get_cooldown(level) if stats else 0.0

# 获取下一级描述（可选）
func get_next_level_description(current_level: int) -> String:
	if current_level >= max_level:
		return "已达最大等级"
	# 这里可以根据具体属性拼接描述，例如 "伤害: 5 -> 10"
	var next_level = current_level + 1
	var desc_parts = []
	if stats and stats.damage.size() >= next_level:
		desc_parts.append("伤害: %d → %d" % [stats.damage[current_level-1], stats.damage[next_level-1]])
	if stats and stats.cooldown.size() >= next_level:
		desc_parts.append("冷却: %.1f → %.1f" % [stats.cooldown[current_level-1], stats.cooldown[next_level-1]])
	return "\n".join(desc_parts) if desc_parts else "升级效果待定义"
