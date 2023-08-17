extends CanvasLayer

func changeScene(scene : PackedScene):
	$AnimationPlayer.play("fade")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play_backwards("fade")
	get_tree().change_scene_to_packed(scene)
