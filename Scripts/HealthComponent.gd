extends Node2D
class_name HealthComponent

signal onDeathEvent
signal onDamageEvent
signal onHealEvent

@export var MAX_HEALTH : int = 10
var health : float 
const DAMAGE_INDICATOR = preload("res://Scenes/DamageIndicator.tscn")

const HURT_PARTICLE = preload("res://Scenes/HurtParticle.tscn")
const DEATH_PARTICLE = preload("res://Scenes/DeathParticle.tscn")

var _iframeActive : bool = false

func _ready():
	health = MAX_HEALTH
	
func damage(dmg : Damage):
	var particle : GPUParticles2D = HURT_PARTICLE.instantiate()
	get_tree().root.add_child(particle)
	particle.global_position = global_position
	particle.restart()
	
	if !_iframeActive:
		SoundPlayer.playSound(SoundPlayer.SOUNDS.HIT,1,1)
		_iframeActive = true
		health -= dmg.attack_damage
		onDamageEvent.emit()
		
		var dmgind : DamageIndicator = DAMAGE_INDICATOR.instantiate()
		add_child(dmgind)
		dmgind.damageText.add_theme_color_override("font_color",dmg.damage_indicator_color)
		dmgind.damageText.text = str(dmg.attack_damage)
		
		if get_owner() is RigidBody2D:
			var currPos = get_owner().global_position
			var entity : RigidBody2D = get_owner()
			var vec = Vector2(currPos.x - dmg.attack_position.x,0).normalized()
			vec = Vector2(vec.x,-1)
			entity.linear_velocity = vec * dmg.knockback_force
		if health <= 0:
			onDeathEvent.emit()
			var particle1 : GPUParticles2D = DEATH_PARTICLE.instantiate()
			get_tree().root.add_child(particle1)
			particle1.global_position = global_position
			particle1.restart()
			get_parent().queue_free()
		$IFrameTimer.start()

func heal(val : int):
	health += val
	if health >= MAX_HEALTH:
		health = MAX_HEALTH
	onHealEvent.emit()

func _on_i_frame_timer_timeout():
	$IFrameTimer.stop()
	_iframeActive = false
