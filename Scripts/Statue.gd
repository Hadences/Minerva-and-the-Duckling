extends StaticBody2D

class_name Statue

signal StatueDeathEvent

@onready var game : Game = get_tree().root.get_node('Game')

#PLAYER AI STUFF

var _playerNearby : bool = false
var _needPlayer : bool = false

###############

func _ready():
	hideIndicator()
	var Health : HealthComponent = $HealthComponent
	var statue_health : StatueHealth = game.getGameHUD().get_node('StatueHealth')
	statue_health.updateMaxHealth(Health.MAX_HEALTH)
	statue_health.updateHealth(Health.health)

func _on_health_component_on_damage_event():
	var Health : HealthComponent = $HealthComponent
	var statue_health : StatueHealth = game.getGameHUD().get_node('StatueHealth')
	statue_health.updateHealth(Health.health)
	_needPlayer = true

func _on_health_component_on_death_event():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.STATUE_BREAK,1,1)
	var Health : HealthComponent = $HealthComponent
	var statue_health : StatueHealth = game.getGameHUD().get_node('StatueHealth')
	statue_health.updateHealth(Health.health)
	StatueDeathEvent.emit()

func showIndicator():
	$INDICATOR.show()

func hideIndicator():
	$INDICATOR.hide()


func _on_player_radius_body_entered(body):
	if body is PlayerEntity:
		_playerNearby = true

func _on_player_radius_body_exited(body):
	if body is PlayerEntity:
		_playerNearby = false
		
func healStatue(val : int):
	$HealthComponent.heal(val)
	


func _on_health_component_on_heal_event():
	var Health : HealthComponent = $HealthComponent
	var statue_health : StatueHealth = game.getGameHUD().get_node('StatueHealth')
	statue_health.updateHealth(Health.health)
