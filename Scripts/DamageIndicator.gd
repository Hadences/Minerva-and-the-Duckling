extends Node2D
class_name DamageIndicator

@export var randomOffset : float = 1
@onready var damageText : Label = $DamageValue
# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = global_position + Vector2((-1 if randi_range(0,1) == 0 else 1) *randf_range(0.8,randomOffset),randf_range(0.8,randomOffset))
	$AnimationPlayer.stop()
	$AnimationPlayer.play("damage_indicator")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.stop()
