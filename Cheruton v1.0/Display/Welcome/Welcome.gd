extends Node

const MAINMENU = "res://Display/MainMenu/MainMenu.tscn"

func _ready():
	DataResource.load_data()
	init_music()
	#Cursor.init_cursor()
	#Testing loot functionality
	SceneControl.get_node("masterGui").enabled = false


func _on_Timer_timeout():
	SceneControl.load_screen(MAINMENU)
	self.queue_free()

func init_music():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), DataResource.dict_settings.is_mute)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), DataResource.dict_settings.audio_master)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), DataResource.dict_settings.audio_music)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), DataResource.dict_settings.audio_sfx)
