extends RigidBody2D

@export var damage : int = 5
@export var knockback_force : float = 20
var PIERCEABLE : bool = false


func _on_hit_box_area_entered(area):
	if area is HitboxComponent:
			var hitbox : HitboxComponent = area
			var dmg = Damage.new()
			dmg.attack_damage = damage
			dmg.knockback_force = knockback_force
			dmg.attack_position = global_position
			dmg.damage_indicator_color = Color("cf573c")
			hitbox.damage(dmg)
			if !PIERCEABLE:
				queue_free() 


func _on_lifetime_timeout():
	queue_free()
