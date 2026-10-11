extends Node2D
class_name Pickup

# 信号：掉落物被收集时发出
signal collected(value: float, pickup: Node)

# 掉落物的数值（经验值/金币数量等）
@export var value: float = 1.0
# 是否启用向玩家吸引
@export var attract_to_player: bool = true
# 吸引速度（单位：像素/秒）
@export var attract_speed: float = 100.0

@onready var area2D = $Area2D
@onready var sprite = $Sprite2D

# 玩家节点引用（可选，用于吸引）
var isCollected: bool = false
var player: CharacterBody2D = null
var isFollowToPlayer: bool = false

func _init():
	print("_init()时 value = ", value)

func _ready():
	print("Pickup初始化 - value = ", value)  # 添加这行
	# 连接 body_entered 或 area_entered 信号来检测玩家
	# 假设玩家是 CharacterBody2D 或 Area2D，且带有 "player" 组
	area2D.body_entered.connect(_on_body_entered)
	area2D.area_entered.connect(_on_area_entered)
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	
	# 如果开启了吸引，启动处理循环
	if attract_to_player:
		set_process(true)
	else:
		set_process(false)

func _process(delta):
	if isFollowToPlayer:
		f_follow_to_player(delta)

func f_follow_to_player(delta):
	# 向玩家位置移动
	var direction = (player.global_position - global_position).normalized()
	global_position += direction * attract_speed * delta	

# 当物理体进入时触发（假设玩家是 CharacterBody2D）
func _on_body_entered(body):
	print("掉落物 [%s] (ID: %d, 位置: %s) 被对象 [%s] (ID: %d) 进入" % [
		name, get_instance_id(), global_position, body.name, body.get_instance_id()
	])
	if body.is_in_group("player"):
		if isCollected:
			return
		isCollected = true	
		collect(body)		

# 当区域进入时触发（假设玩家是 Area2D）
func _on_area_entered(area: Area2D):
	if attract_to_player and player != null and is_instance_valid(player):
		isFollowToPlayer = true

# 收集方法
func collect(collector: Node):
	print("pickup collect")	
	# 发出信号，传递数值和自身节点引用
	#collected.emit(value, self)
	GameEvents.emit_experience_vial_collected(value)
	# 移除掉落物
	queue_free()

# 可选：外部设置玩家引用（例如通过检测区域或由管理器设置）
func set_player_ref(p: Node2D):
	player = p
