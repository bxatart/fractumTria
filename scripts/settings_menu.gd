extends Control

#Senyal per tornar enrere
signal closed

@onready var music_slider: HSlider = %musicSlider
@onready var sfx_slider: HSlider = %sfxSlider
@onready var back_button: Button = %backButton
@onready var lang_option: OptionButton = %langOption

const languages = ["en", "ca", "es"]
#Per evitar emetre senyals mentre s'inicialitzen els valors
var signaling = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().process_frame
	back_button.grab_focus()
	signaling = true
	#Sincronitza amb els valors guardats a la configuració
	sync_from_settings()
	signaling = false

func sync_from_settings() -> void:
	#Volum
	music_slider.value = Settings.music_volume * 100.0
	sfx_slider.value = Settings.sfx_volume * 100.0
	#Idioma
	var idx = languages.find(Settings.language)
	if idx == -1:
		idx = 0
	lang_option.select(idx)

func _on_music_slider_value_changed(value: float) -> void:
	if signaling:
		return
	Settings.set_music_volume(value / 100.0)

func _on_sfx_slider_value_changed(value: float) -> void:
	if signaling:
		return
	Settings.set_sfx_volume(value / 100.0)

func _on_back_button_pressed() -> void:
	Sound.playSfx("menuBack")
	await get_tree().create_timer(0.25).timeout
	emit_signal("closed")
	queue_free()

func _on_lang_option_item_selected(index: int) -> void:
	if signaling:
		return
	var lang = languages[index]
	Settings.set_language(lang)
