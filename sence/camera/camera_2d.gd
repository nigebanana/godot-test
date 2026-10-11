extends Camera2D

# 跟随目标
@export var target: CharacterBody2D  # 要跟随的玩家节点
@export var follow_speed: float = 5.0  # 跟随平滑速度（越小越平滑）

# 地图
@export var tilemap: TileMapLayer  # 地图

# 边界限制
@export var use_limits: bool = true  # 是否使用边界限制

# 跟随区域（摄像机中心区域，在此区域内摄像机不移动）
@export var follow_dead_zone: Vector2 = Vector2(10, 10)  # 死区大小

# 平滑跟随类型
enum FollowType {
	SMOOTH,      # 平滑跟随（始终平滑移动）
	DEAD_ZONE,   # 死区跟随（玩家在死区内不移动）
	BOUNDARY     # 边界跟随（玩家靠近边界才移动）
}
@export var follow_type: FollowType = FollowType.SMOOTH

# 内部变量
var screen_size: Vector2

func _ready():
	# 获取屏幕大小
	screen_size = get_viewport().get_visible_rect().size
	
	# 如果没有设置目标，尝试自动查找玩家
	if target == null:
		find_player()
	
	# 设置摄像机边界
	if use_limits:
		set_camera_limits()
	
	# 初始位置
	if target != null:
		global_position = target.global_position

func _process(delta):
	if target == null:
		# 如果目标丢失，尝试重新查找
		find_player()
		return
	
	# 根据不同类型的跟随方式更新摄像机位置
	match follow_type:
		FollowType.SMOOTH:
			smooth_follow(delta)
		FollowType.DEAD_ZONE:
			dead_zone_follow()
		FollowType.BOUNDARY:
			boundary_follow()

# 平滑跟随
func smooth_follow(delta):
	# 目标位置（玩家的位置）
	var target_position = target.global_position
	
	# 使用线性插值平滑移动摄像机
	global_position = global_position.lerp(target_position, follow_speed * delta)

# 死区跟随（玩家在一定区域内移动时，摄像机不移动）
func dead_zone_follow():
	# 获取摄像机中心位置（注意：Camera2D的中心就是global_position）
	var camera_center = global_position
	
	# 计算玩家相对于摄像机中心的位置偏移
	var offset = target.global_position - camera_center
	
	# 用于存储新的摄像机位置
	var new_position = global_position
	
	# 如果玩家超出死区范围，移动摄像机
	if abs(offset.x) > follow_dead_zone.x:
		if offset.x > 0:
			new_position.x = target.global_position.x - follow_dead_zone.x
		else:
			new_position.x = target.global_position.x + follow_dead_zone.x
	
	if abs(offset.y) > follow_dead_zone.y:
		if offset.y > 0:
			new_position.y = target.global_position.y - follow_dead_zone.y
		else:
			new_position.y = target.global_position.y + follow_dead_zone.y
	
	global_position = new_position

# 边界跟随（玩家靠近边界时摄像机才开始移动）
func boundary_follow():
	# 获取摄像机中心
	var camera_center = global_position
	var player_pos = target.global_position
	
	# 计算摄像机应该移动的方向和距离
	var move_x = 0
	var move_y = 0
	
	# 检查水平方向
	if player_pos.x < camera_center.x - follow_dead_zone.x/2:
		# 玩家在左侧边界，摄像机向左移动
		move_x = player_pos.x - (camera_center.x - follow_dead_zone.x/2)
	elif player_pos.x > camera_center.x + follow_dead_zone.x/2:
		# 玩家在右侧边界，摄像机向右移动
		move_x = player_pos.x - (camera_center.x + follow_dead_zone.x/2)
	
	# 检查垂直方向
	if player_pos.y < camera_center.y - follow_dead_zone.y/2:
		move_y = player_pos.y - (camera_center.y - follow_dead_zone.y/2)
	elif player_pos.y > camera_center.y + follow_dead_zone.y/2:
		move_y = player_pos.y - (camera_center.y + follow_dead_zone.y/2)
	
	# 应用移动
	global_position.x += move_x
	global_position.y += move_y
	
	# 应用边界限制
	if use_limits:
		apply_limits()

# 应用边界限制
func apply_limits():
	# 获取摄像机实际大小（考虑缩放）
	var camera_size = get_viewport_rect().size / zoom
	
	# 计算摄像机边界（摄像机中心可以移动的范围）
	var min_x = limit_left + camera_size.x/2
	var max_x = limit_right - camera_size.x/2
	var min_y = limit_top + camera_size.y/2
	var max_y = limit_bottom - camera_size.y/2
	
	# 检查地图是否比屏幕小
	var horizontal_center = (limit_left + limit_right) / 2
	var vertical_center = (limit_top + limit_bottom) / 2
	
	# 如果地图宽度小于屏幕宽度，水平居中
	if limit_right - limit_left < camera_size.x:
		global_position.x = horizontal_center
	else:
		global_position.x = clamp(global_position.x, min_x, max_x)
	
	# 如果地图高度小于屏幕高度，垂直居中
	if limit_bottom - limit_top < camera_size.y:
		global_position.y = vertical_center
	else:
		global_position.y = clamp(global_position.y, min_y, max_y)

# 设置摄像机边界（自动计算）
func set_camera_limits():
	# 查找TileMap（如果存在）
	if tilemap:
		# 获取TileMap的使用区域
		var map_rect = tilemap.get_used_rect()
		
		# 获取TileMap的单元格大小
		var tileset = tilemap.tile_set
		if tileset:
			var cell_size = tileset.tile_size
			
			# 计算地图边界
			limit_left = map_rect.position.x * cell_size.x
			limit_right = (map_rect.position.x + map_rect.size.x) * cell_size.x
			limit_top = map_rect.position.y * cell_size.y
			limit_bottom = (map_rect.position.y + map_rect.size.y) * cell_size.y
			
			print("自动设置摄像机边界:")
			print("左: ", limit_left, " 右: ", limit_right, " 上: ", limit_top, " 下: ", limit_bottom)
		else:
			print("警告: TileMap没有设置TileSet")
	else:
		print("使用手动设置的边界: ", limit_left, ", ", limit_top, " 到 ", limit_right, ", ", limit_bottom)

# 查找玩家
func find_player():
	var found_player = get_tree().get_first_node_in_group("player")
	if found_player:
		target = found_player
		print("找到玩家: ", target.name)
	else:
		print("警告: 未找到玩家，请确保玩家在'player'组中")

# 设置新的跟随目标
func set_target(new_target: Node2D):
	target = new_target
	print("设置新跟随目标: ", target.name)

# 调试功能：显示摄像机范围（需要在主场景中启用绘制）
func _draw():
	if Engine.is_editor_hint():
		return
	
	# 绘制死区范围（调试用）
	if follow_type != FollowType.SMOOTH:
		var dead_zone_rect = Rect2(
			-follow_dead_zone.x/2,
			-follow_dead_zone.y/2,
			follow_dead_zone.x,
			follow_dead_zone.y
		)
		draw_rect(dead_zone_rect, Color(1, 0, 0, 0.3), true)
	
	# 绘制边界限制范围（需要在摄像机坐标空间中绘制）
	if use_limits:
		# 这个需要在主场景中绘制更准确
		pass
