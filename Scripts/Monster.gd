extends RigidBody2D
class_name Monster

enum MonsterDirection{
	LEFT,
	RIGHT,
}

enum MonsterState{
	MOVE,
	IDLE,
	ATTACK
}

var _movementInput : Vector2 = Vector2.ZERO
var _monsterDir : MonsterDirection = MonsterDirection.RIGHT
var _monsterState : MonsterState = MonsterState.IDLE
var _canAttack : bool = true
var _nearbyAttackRange : bool = false

var _nearbyPlayer : bool = false
var _target = null

var _pause : bool = false

@export var max_speed : float = 750
@export var acceleration : float = 650
@export var linearDrag : float = 5
@export var attack_damage : int = 10
@export var knockback_force : float = 200


var changingDir = true if ((linear_velocity.x > 0.0 && _movementInput.x < 0.0) || (linear_velocity.x < 0.0 && _movementInput.x > 0.0)) else false

#gets the world
@onready var world : World = get_tree().root.get_node("Game").getWorld() if get_tree().root.get_node("Game").has_method("getWorld") else null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_goalUpdate()
	_updateInputs()
	_applyLinearDrag()
	_updateDirection()
	_updateSprite()
	
func _physics_process(delta):
	_moveCharacter(delta)

func _goalUpdate() -> void:
	#target statue
	if world == null:
		return
	
	#update target
	_target = world.getStatue() # by default, target statue
	if _nearbyPlayer:
		_target = world.getPlayer()
		
	#attack player and target it if nearby
	
	if _nearbyAttackRange:
		if _canAttack:
			_attack()
	
	pass

func _updateInputs():
	_movementInput = Vector2.ZERO
	if _target != null && !_nearbyAttackRange:
		#movement/attack logic
		_movementInput = _target.position - position
		_movementInput.y = 0
	
	
	_movementInput = _movementInput.normalized()
	
	if !_pause:
		if _movementInput == Vector2.ZERO:
			#idle
			_monsterState = MonsterState.IDLE
		else:
			_monsterState = MonsterState.MOVE
	

func _updateDirection():
	if _movementInput.x < 0:
		#facing RIGHT
		_monsterDir = MonsterDirection.RIGHT
	elif _movementInput.x > 0:
		#facing LEFT
		_monsterDir = MonsterDirection.LEFT

func _updateSprite():
	if _monsterDir == MonsterDirection.RIGHT:
		%Sprite.flip_h = false
	elif _monsterDir == MonsterDirection.LEFT:
		%Sprite.flip_h = true
	if _monsterState == MonsterState.IDLE:
		%Sprite.play("idle")
	elif _monsterState == MonsterState.MOVE:
		%Sprite.play("run")
	else:
		pass
		#%Sprite.play("idle")

func _moveCharacter(delta):
	apply_force(_movementInput*acceleration)
	if(abs(linear_velocity.length()) > max_speed):
		linear_velocity = linear_velocity.normalized() * max_speed 

func _applyLinearDrag():
	if (_movementInput.length() < 0.4 || changingDir):
		linear_damp = linearDrag
	else:
		linear_damp = linearDrag/4
	
func _attack():
	_pause = true
	_monsterState = MonsterState.ATTACK
	%Sprite.stop()
	%Sprite.play("attack")
	var dmg = Damage.new()
	dmg.attack_damage = attack_damage
	dmg.attack_position = global_position
	dmg.knockback_force = knockback_force
	var hitboxComponent : HitboxComponent = _target.get_node_or_null('HitboxComponent')
	if hitboxComponent != null:
		hitboxComponent.damage(dmg)
	_startAttackCD()
	await %Sprite.animation_looped
	_pause = false
	
func _startAttackCD():
	_canAttack = false
	%AttackCD.start()

func _on_target_range_body_entered(body):
	if body is PlayerEntity:
		_nearbyPlayer = true
	else:
		_nearbyPlayer = false


func _on_target_range_body_exited(body):
	if body is PlayerEntity:
		_nearbyPlayer = false
		
		

func _on_attack_range_body_entered(body):
	if body == _target:
		_nearbyAttackRange = true


func _on_attack_range_body_exited(body):
	if body == _target:
		_nearbyAttackRange = false


func _on_attack_cd_timeout():
	_canAttack = true
	%AttackCD.stop()


func _on_health_component_on_damage_event():
	_startAttackCD()


func _on_health_component_on_death_event():
		SoundPlayer.playSound(SoundPlayer.SOUNDS.ENEMY_DEATH,1,1)
