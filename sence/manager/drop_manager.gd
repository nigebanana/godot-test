extends Node

@export_range(0, 1) var drop_percent: float = .5
@export var health_component: Node
# 可扩展成多种掉落物
@export var pickup_scene: PackedScene


func _ready():
	# 打印pickup_scene的详细信息
	print("=== 掉落管理器调试 ===")
	print("pickup_scene: ", pickup_scene)
	if pickup_scene:
		print("pickup_scene路径: ", pickup_scene.resource_path)
		print("pickup_scene名称: ", pickup_scene.resource_name)
	else:
		print("pickup_scene为空!")
	
	# 打印调用堆栈，看谁调用了这个节点的_ready
	print("调用堆栈:", "")
	print_stack()
	(health_component as HealthComponent).died.connect(on_died)


func on_died():
	var adjusted_drop_percent = drop_percent
	# 根据难度调整掉落概率
	if randf() > adjusted_drop_percent:
		return
	
	if pickup_scene == null:
		return
	
	if not owner is Node2D:
		return
	
	var spawn_position = (owner as Node2D).global_position
	var pickup_instance = pickup_scene.instantiate() as Node2D
	print("实例化后value: ", pickup_instance.value)
	print("实例化后场景文件: ", pickup_instance.get_scene_file_path())
	
	print("on_died：", pickup_instance.get_instance_id())
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(pickup_instance)
	pickup_instance.global_position = spawn_position
