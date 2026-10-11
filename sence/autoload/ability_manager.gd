extends Node

var all_abilities: Array[AbilityData]  # 所有可用能力数据
var learned_abilities: Dictionary = {}  # id -> {data, level}

func get_random_candidates(count: int) -> Array:
	# 从 all_abilities 中随机挑选 count 个，排除已达最大等级的
	# 返回 AbilityData 数组
	var random_abilities : Array[AbilityData]
	var select_abilities = get_can_select_abilities()
	if select_abilities.size() < 1:
		return random_abilities
	for i in count:
		var randNumber = randi_range(0, all_abilities.size())
		random_abilities.append(select_abilities[randNumber])
	return random_abilities

func learn_or_upgrade(ability: AbilityData):
	if learned_abilities.has(ability.id):
		var entry = learned_abilities[ability.id]
		entry.level += 1
	else:
		learned_abilities[ability.id] = {data=ability, level=1}
		
func get_can_select_abilities():
	var select_abilities : Array[AbilityData]
	for data in all_abilities:
		var curent_level = learned_abilities[data.id]["level"]
		if curent_level < data.max_level:
			select_abilities.append(data)
	return select_abilities
		
