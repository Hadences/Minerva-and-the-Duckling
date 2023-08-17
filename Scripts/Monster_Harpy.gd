extends RigidBody2D

@onready var world : World = get_tree().root.get_node("Game").getWorld() if get_tree().root.get_node("Game").has_method("getWorld") else null
var statue : Statue

var _nearbyStatue : bool = false
var _canAttack : bool = true
@export var flapForce : float = 500
@export var attack_damage : int = 3
@export var knockback_force : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.play("fly")
	if world != null:
		statue = world.getStatue()
		
func _process(delta):
	if _nearbyStatue && _canAttack:
		attack()

func attack():
	var dmg = Damage.new()
	dmg.attack_damage = attack_damage
	dmg.attack_position = global_position
	dmg.knockback_force = knockback_force
	var hitboxComponent : HitboxComponent = statue.get_node_or_null('HitboxComponent')
	if hitboxComponent != null:
		hitboxComponent.damage(dmg)
	_startAttackCD()
	pass

func fly():
	linear_velocity = Vector2.ZERO
	var tarPos = statue.global_position + Vector2(0,-20)
	var vectorDirection = tarPos - position
	vectorDirection = vectorDirection.normalized()
	vectorDirection.y += -2.2 
	#vectorDirection = vectorDirection.rotated(45)
	apply_impulse(vectorDirection * flapForce)

func _on_attack_range_body_entered(body):
	if body is Statue:
		_nearbyStatue = true


func _on_attack_range_body_exited(body):
	if body is Statue:
		_nearbyStatue = false

func _on_flap_timer_timeout():
	fly()

func _startAttackCD():
	_canAttack = false
	%AttackCD.start()

func _on_attack_timer_timeout():
	_canAttack = true
	%AttackCD.stop()


func _on_health_component_on_death_event():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.ENEMY_DEATH,1,1)
