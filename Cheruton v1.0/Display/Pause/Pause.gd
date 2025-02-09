extends basePopUp

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

#exiting to mm/exit needs to warn player about unsaved data
func _on_ExitDirect_pressed():
	SceneControl.button_click.play()
	DataResource.save_player()
	get_tree().quit()

func _on_Settings_pressed():
	SceneControl.button_click.play()
	SceneControl.settings_layer.show()

func _on_RMMenu_pressed():
	SceneControl.button_click.play()
	SceneControl.change_scene(SceneControl.levels.get_child(0), MAINMENU)
	emit_signal("release_gui", "pause")

func _on_ExitPause_pressed():
	SceneControl.button_click.play()
	DataResource.save_player()
	emit_signal("release_gui", "pause")

func handle_input(event):
	if isisActive_gui and Input.is_action_just_pressed("escape") and !SceneControl.settings_layer.visible:
		_on_ExitPause_pressed()
		$Resume.play()
		
func set_isisActive_gui(val):
	.set_isisActive_gui(val)
	if val:
		$Pause.play()
		
