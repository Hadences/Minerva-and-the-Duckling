extends CanvasLayer

func _on_button_pressed():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.UI_CLICK)
	SceneTransition.changeScene(Scenes.game_scene)
	#get_tree().change_scene_to_packed(Scenes.game_scene)
	
func showHTP():
	$AnimationPlayer.play("showHTP")
	
func unshowHTP():
	$AnimationPlayer.play_backwards("showHTP")


func _on_texture_button_pressed():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.UI_CLICK,1,1)
	unshowHTP()
	pass # Replace with function body.


func _on_how_to_play_pressed():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.UI_CLICK,1,1)
	showHTP()
	pass # Replace with function body.
