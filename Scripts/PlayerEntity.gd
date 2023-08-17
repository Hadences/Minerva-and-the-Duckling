extends RigidBody2D
class_name PlayerEntity

signal PlayerDeathEvent

enum PlayerDirection{
	LEFT,
	RIGHT,
}

enum PlayerState{
	MOVE,
	IDLE,
	JUMP,
}

var ATTACK_ANIMATION_COUNT = 3

var _movementInput : Vector2 = Vector2.ZERO
var _onGround : bool = true
var _canGroundCheck : bool = true
var _currentJumps : int = 0
var _canJump : bool = true
var _playerDir : PlayerDirection = PlayerDirection.RIGHT
var _playerState : PlayerState = PlayerState.IDLE
var _canAttack : bool = true
var _canThrow :bool = true

#AI SECTION ########################
var _autopilot : bool = false
var _nearbyStatue : bool = false
var _meleeRange : bool = false
var _throwRange : bool = false
var _tar = null
var _target : Vector2 = Vector2.ZERO

var _travel : bool = true
@onready var screen_size = get_viewport_rect().size
####################################

@export var max_speed : float = 750
@export var acceleration : float = 650
@export var jump_force : float = 500
@export var linearDrag : float = 5
@export var airDrag : float = 1

@export var jumps : int = 1
@export var spearForce : float = 300

var changingDir = true if ((linear_velocity.x > 0.0 && _movementInput.x < 0.0) || (linear_velocity.x < 0.0 && _movementInput.x > 0.0)) else false
@onready var game : Game = get_tree().root.get_node('Game')

@export var THROWING_SPEAR_DAMAGE : int = 2
@export var SPEAR_DAMAGE : int = 3
var PIERCEABLE : bool = false
var TRIPLE_THROW : bool = false
const SPEAR = preload("res://Scenes/ThrowingSpear.tscn")
var STATUE : Statue

# Called when the node enters the scene tree for the first time.
func _ready():
	getSpear().damage = SPEAR_DAMAGE
	hideIndicator()
	var Health : HealthComponent = $HealthComponent
	var player_health : PlayerHealth = game.getGameHUD().get_node('PlayerHealth')
	player_health.updateMaxHealth(Health.MAX_HEALTH)
	player_health.updateHealth(Health.health)
	STATUE = game.getWorld().getStatue()
	_target = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_autopilotAI()
	_updateInputs()
	_applyLinearDrag()
	_groundCheck()
	_updateDirection()
	_updateSprite()
	
func _physics_process(delta):
	_moveCharacter(delta)

func _autopilotAI() -> void:
	if !_autopilot:
		return
	
	#update nearby statue
	_nearbyStatue = STATUE._playerNearby
	
	#check if player nearby statue, else go there
	if !_nearbyStatue:
		_movementInput = (STATUE.position - position).normalized()
		_target = Vector2.ZERO
		_travel = false
		$TravelTimer.stop()
		$TravelTimer.start(randf_range(0,10))
		#move torwards the statue
	elif _target != Vector2.ZERO:
		_movementInput = (_target - position).normalized()
	else:
		_movementInput = Vector2.ZERO
		
	if STATUE._needPlayer:
		_target = STATUE.position
		STATUE._needPlayer = false
		_travel = true
		$TravelTimer.stop()
		
		
	if _movementInput == Vector2.ZERO:
		#idle
		_playerState = PlayerState.IDLE
	else:
		_playerState = PlayerState.MOVE
	
	if !_onGround:
		_playerState = PlayerState.JUMP
		
	if _target.x - 50 <= position.x && _target.x + 50 >= position.x:
		_travel = false
		_target = Vector2.ZERO
		$TravelTimer.stop()
		$TravelTimer.start(randf_range(0,10))

	
	#throw spear for far away enemies
	if _meleeRange:
		if _canAttack:
			if _tar != null:
				_attackAI(_tar)
	if _throwRange:
		if _canThrow:
			if _tar != null:
				_throwSpearAI(_tar)

	if randi_range(0,10) == 1 && _target == Vector2.ZERO && _travel: 
		_target = position + Vector2(randf_range(-200,200), 0)
		_target.x = clamp(_target.x, 0, screen_size.x)
		_target.y = clamp(_target.y, 0,screen_size.y)
	#attack for nearby enemies
	
func _attackAI(target):
	SoundPlayer.playSound(SoundPlayer.SOUNDS.SPEAR_SWING,1,1.2)
	
	var mousePos = target.global_position	
	if mousePos.x > position.x:
		#facing RIGHT
		_playerDir = PlayerDirection.RIGHT
	elif mousePos.x < position.x:
		#facing LEFT
		_playerDir = PlayerDirection.LEFT
	
	_canAttack = false
	#player attacks
	%WeaponAnimationPlayer.play("attack_" + str(randi_range(0,ATTACK_ANIMATION_COUNT-1)))
	
	await %WeaponAnimationPlayer.animation_finished
	%WeaponAnimationPlayer.play("RESET")
	%AttackCD.start()

func _throwSpearAI(target):
	SoundPlayer.playSound(SoundPlayer.SOUNDS.THROW_SPEAR,1,1)
	var mousePos = target.global_position
	var throwSpear :RigidBody2D = SPEAR.instantiate()
	game.getWorld().get_node("Entities").add_child(throwSpear)
	throwSpear.global_position = global_position
	throwSpear.PIERCEABLE = PIERCEABLE
	throwSpear.damage = THROWING_SPEAR_DAMAGE
	var x : Vector2 = Vector2.RIGHT
	var z : Vector2 = (mousePos-throwSpear.global_position).normalized()
	throwSpear.rotate(-1*acos((x.dot(z))/x.length()*z.length()))
	var throwVec =	(mousePos - throwSpear.global_position).normalized()
	throwSpear.apply_impulse(throwVec*spearForce)
	if TRIPLE_THROW:
		var throwSpear2 : RigidBody2D = SPEAR.instantiate()
		var throwSpear3 : RigidBody2D = SPEAR.instantiate()
		game.getWorld().get_node("Entities").add_child(throwSpear2)
		game.getWorld().get_node("Entities").add_child(throwSpear3)
		throwSpear2.global_position = global_position
		throwSpear3.global_position = global_position
		throwSpear2.PIERCEABLE = PIERCEABLE
		throwSpear3.PIERCEABLE = PIERCEABLE
		throwSpear2.damage = THROWING_SPEAR_DAMAGE
		throwSpear3.damage = THROWING_SPEAR_DAMAGE
		throwSpear2.rotate(-1*(acos((x.dot(z))/x.length()*z.length())))
		throwSpear3.rotate(-1*(acos((x.dot(z))/x.length()*z.length())))
		var throwVec2 = throwVec.rotated(85)
		var throwVec3 = throwVec.rotated(-85)
		throwSpear2.apply_impulse(-1*throwVec2*spearForce)
		throwSpear3.apply_impulse(-1*throwVec3*spearForce)
	_canThrow = false
	%ThrowCD.start()


func _updateInputs() -> void:
	if _autopilot:
		return
		
	if Input.is_action_pressed("attack"):
		if _canAttack:
			_attack()
	if Input.is_action_pressed("throw"):
		if _canThrow:
			_throwSpear()
	
	_movementInput = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		_movementInput += Vector2(-1,0)
	if Input.is_action_pressed("move_right"):
		_movementInput += Vector2(1,0)
	_movementInput = _movementInput.normalized()
	
	if _movementInput == Vector2.ZERO:
		#idle
		_playerState = PlayerState.IDLE
	else:
		_playerState = PlayerState.MOVE
	
	if !_onGround:
		_playerState = PlayerState.JUMP
	
	if Input.is_action_just_pressed("jump") && (_onGround || _canJump):
		_jump()

func _groundCheck():
	if _canGroundCheck:
		if $GroundCheck.has_overlapping_bodies() && !_onGround:
			_onGround = true
			_currentJumps = 0
			_canJump = true
	
func _jump():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.JUMP,-2,2)
#	_playerState = PlayerState.JUMP
	_currentJumps += 1
	linear_velocity.y = 0
	apply_impulse(Vector2(0,-1).normalized() * jump_force)
	_onGround = false
	_canGroundCheck = false
	$GroundCheckCD.start()
	if _currentJumps >= jumps:
		_canJump = false
		_currentJumps = 0

func _updateDirection() -> void:
	if !_canAttack:
		return
	if _movementInput.x > 0:
		#facing RIGHT
		_playerDir = PlayerDirection.RIGHT
	elif _movementInput.x < 0:
		#facing LEFT
		_playerDir = PlayerDirection.LEFT

func _updateSprite():
	if _playerDir == PlayerDirection.RIGHT:
		%PlayerSprite.flip_h = false
		%Handle.scale.x = 1
	elif _playerDir == PlayerDirection.LEFT:
		%PlayerSprite.flip_h = true
		%Handle.scale.x = -1
	
	if _playerState == PlayerState.IDLE && %PlayerSprite.animation_finished:
		%PlayerSprite.play("idle")
	elif _playerState == PlayerState.MOVE && %PlayerSprite.animation_finished:
		%PlayerSprite.play("run")
	elif _playerState == PlayerState.JUMP && %PlayerSprite.animation_finished:
		%PlayerSprite.play("jump")
	else:
		%PlayerSprite.play("idle")

func _moveCharacter(delta):
	apply_force(_movementInput*acceleration)
	if(abs(linear_velocity.length()) > max_speed):
		linear_velocity = linear_velocity.normalized() * max_speed 

func _applyLinearDrag():
	if (_movementInput.length() < 0.4 || changingDir) && _onGround:
		linear_damp = linearDrag
	elif !_onGround:
		linear_damp = airDrag
	else:
		linear_damp = linearDrag/4

func _on_ground_check_cd_timeout():
	_canGroundCheck = true
	
func _attack():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.SPEAR_SWING,1,1.2)
	var mousePos = get_viewport().get_mouse_position()
	if mousePos.x > position.x:
		#facing RIGHT
		_playerDir = PlayerDirection.RIGHT
	elif mousePos.x < position.x:
		#facing LEFT
		_playerDir = PlayerDirection.LEFT
	
	_canAttack = false
	#player attacks
	%WeaponAnimationPlayer.play("attack_" + str(randi_range(0,ATTACK_ANIMATION_COUNT-1)))
	
	await %WeaponAnimationPlayer.animation_finished
	%WeaponAnimationPlayer.play("RESET")
	%AttackCD.start()

func _throwSpear():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.THROW_SPEAR,1,1.2)
	var mousePos = get_viewport().get_mouse_position()
	var throwSpear :RigidBody2D = SPEAR.instantiate()
	game.getWorld().get_node("Entities").add_child(throwSpear)
	throwSpear.global_position = global_position
	throwSpear.PIERCEABLE = PIERCEABLE
	throwSpear.damage = THROWING_SPEAR_DAMAGE
	var x : Vector2 = Vector2.RIGHT
	var z : Vector2 = (mousePos-throwSpear.global_position).normalized()
	throwSpear.rotate(-1*acos((x.dot(z))/x.length()*z.length()))
	var throwVec =	(mousePos - throwSpear.global_position).normalized()
	throwSpear.apply_impulse(throwVec*spearForce)
	if TRIPLE_THROW:
		var throwSpear2 : RigidBody2D = SPEAR.instantiate()
		var throwSpear3 : RigidBody2D = SPEAR.instantiate()
		game.getWorld().get_node("Entities").add_child(throwSpear2)
		game.getWorld().get_node("Entities").add_child(throwSpear3)
		throwSpear2.global_position = global_position
		throwSpear3.global_position = global_position
		throwSpear2.PIERCEABLE = PIERCEABLE
		throwSpear3.PIERCEABLE = PIERCEABLE
		throwSpear2.damage = THROWING_SPEAR_DAMAGE
		throwSpear3.damage = THROWING_SPEAR_DAMAGE
		throwSpear2.rotate(-1*(acos((x.dot(z))/x.length()*z.length())))
		throwSpear3.rotate(-1*(acos((x.dot(z))/x.length()*z.length())))
		var throwVec2 = throwVec.rotated(85)
		var throwVec3 = throwVec.rotated(-85)
		throwSpear2.apply_impulse(-1*throwVec2*spearForce)
		throwSpear3.apply_impulse(-1*throwVec3*spearForce)
	_canThrow = false
	%ThrowCD.start()


func _on_attack_cd_timeout():
	%AttackCD.stop()
	_canAttack = true

func _on_health_component_on_damage_event():
	var Health : HealthComponent = $HealthComponent
	var player_health : PlayerHealth = game.getGameHUD().get_node('PlayerHealth')
	player_health.updateHealth(Health.health)


func _on_health_component_on_death_event():
	var Health : HealthComponent = $HealthComponent
	var player_health : PlayerHealth = game.getGameHUD().get_node('PlayerHealth')
	player_health.updateHealth(Health.health)
	PlayerDeathEvent.emit()
	
func showIndicator():
	$INDICATOR.show()

func hideIndicator():
	$INDICATOR.hide()

func _on_throw_cd_timeout():
	%ThrowCD.stop()
	_canThrow = true

func _on_travel_timer_timeout():
	$TravelTimer.stop()
	_travel = true


func _on_throw_range_area_entered(area):
	if area is HitboxComponent:
		_throwRange = true
		_tar = area


func _on_throw_range_area_exited(area):
	if area is HealthComponent:
		_throwRange = false
		_tar = null


func _on_melee_range_area_entered(area):
	if area is HitboxComponent:
		_meleeRange = true
		_tar = area


func _on_melee_range_area_exited(area):
	if area is HitboxComponent:
		_meleeRange = false
		_tar = null
		
func setAttackSpeedCD(val : float):
	%AttackCD.wait_time = val

func setThrowSpeedCD(val : float):
	%ThrowCD.wait_time = val

func getAttackSpeedTime():
	return %AttackCD.wait_time
	
func getThrowSpeedTime():
	return %ThrowCD.wait_time
	
func healPlayer(val : int):
	$HealthComponent.heal(val)
	
func getSpear() -> Spear:
	return %Handle/Spear

func _on_health_component_on_heal_event():
	var Health : HealthComponent = $HealthComponent
	var player_health : PlayerHealth = game.getGameHUD().get_node('PlayerHealth')
	player_health.updateHealth(Health.health)
	
func setSpearDamageUpdate():
	getSpear().damage = SPEAR_DAMAGE

func setSpearDamage(val : int):
	SPEAR_DAMAGE = val
	setSpearDamageUpdate()

func getSpearDamage() -> int:
	return SPEAR_DAMAGE
	
func setThrowingSpearDamage(val : int):
	THROWING_SPEAR_DAMAGE = val

func getThrowingSpearDamage() -> int:
	return THROWING_SPEAR_DAMAGE
	
