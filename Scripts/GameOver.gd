extends CanvasLayer

@onready var textLabel = $Text

func _ready():
	textLabel.text = "You survived " + str(Game.wave) + " wave(s)!"

func _on_main_menu_button_pressed():
	SoundPlayer.playSound(SoundPlayer.SOUNDS.UI_CLICK)
	SceneTransition.changeScene(Scenes.main_menu_scene)

