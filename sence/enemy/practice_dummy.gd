extends CharacterBody2D

@onready var enemyAniSprite = $AnimatedSprite2D
@onready var healthComponent = $HealthComponent
@onready var healthBar: ProgressBar  = $HealthBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HurtboxComponent.hurt_entered.connect(on_hurt_entered)
	
func on_hurt_entered(hitbox: HitboxComponent):
	var damage = hitbox.damage
	if damage >= healthComponent.current_health:
		damage = healthComponent.current_health - 1
	healthComponent.sub_current_health(damage)
	update_health_display()
	
	if healthComponent.current_health == 1:
		healthComponent.add_current_health(healthComponent.max_health)
		healthBar.value = healthComponent.current_health
	

func update_health_display():
	healthBar.value = healthComponent.get_health_percent()
	
