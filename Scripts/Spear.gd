extends Area2D
class_name Spear
@export var damage : int = 5
@export var knockback_force : float = 20
@export var stun_time : float = 0.2

func _on_area_entered(area):
	if area is HitboxComponent:
		var hitbox : HitboxComponent = area
		var dmg = Damage.new()
		dmg.attack_damage = damage
		dmg.knockback_force = knockback_force
		dmg.attack_position = global_position
		dmg.damage_indicator_color = Color("cf573c")
		hitbox.damage(dmg)
