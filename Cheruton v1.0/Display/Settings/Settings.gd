extends baseGui

onready var main_bar = $MainVol/MainVolBar
onready var music_bar = $MusicVol/MusicVolBar
onready var sfx_bar = $SFXVol/SFXVolBar

func _ready():
	main_bar.value = (10 - ((10 - DataResource.dict_settings.audio_master)/8)) * 10
	music_bar.value = (10 - ((10 - DataResource.dict_settings.audio_master)/8)) * 10
	sfx_bar.value = (10 - ((10 - DataResource.dict_settings.audio_sfx)/8)) * 10
	DataFunctions.connect("change_audio_master", self, "change_master_vol")
	DataFunctions.connect("change_audio_music", self, "change_music_vol")
	DataFunctions.connect("change_audio_sfx", self, "change_sfx_vol")

func _on_MuteToggle_pressed():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !(DataResource.dict_settings.is_mute))

func change_master_vol():
	main_bar.value = (10 - ((10 - DataResource.dict_settings.audio_master)/8)) * 10

func change_music_vol():
	music_bar.value = (10 - ((10 - DataResource.dict_settings.audio_music)/8)) * 10

func change_sfx_vol():
	sfx_bar.value = (10 - ((10 - DataResource.dict_settings.audio_sfx)/8)) * 10

func _on_MainVolUp_pressed():
	DataFunctions.change_audio_master(8)

func _on_MainVolDown_pressed():
	DataFunctions.change_audio_master(-8)

func _on_MusicVolUp_pressed():
	DataFunctions.change_audio_music(8)

func _on_MusicVolDown_pressed():
	DataFunctions.change_audio_music(-8)

func _on_SFXVolUp_pressed():
	DataFunctions.change_audio_sfx(8)


func _on_SFXVolDown_pressed():
	DataFunctions.change_audio_sfx(-8)

#change this to go back to previously loaded scene
func _on_Back_pressed():
	DataResource.save_rest() # so that the new settings persist on next save file
	emit_signal("release_gui", "settings")


func handle_input(event):
	if is_active_gui and Input.is_action_just_pressed("escape"):
		_on_Back_pressed()


