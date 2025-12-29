#Guardar preferències de l'usuari
extends Node

#Senyal per avisar si alguna opció canvia
signal changed

#Ruta on es guardaran les opcions
var save_path = "user://settings.cfg"

#Volum àudio
var music_volume: float = 0.8
var sfx_volume: float = 0.8

#Idioma
var language: String = "en"

func _ready() -> void:
	#Carregar opcions guardades al disc
	load_settings()
	#Aplicar opcions
	apply()

func apply() -> void:
	#Aplicar volum
	apply_audio()
	#Aplicar idioma
	apply_language()
	#Emet senyal canvis
	emit_signal("changed")

func apply_audio() -> void:
	set_bus("Music", music_volume)
	set_bus("Sfx", sfx_volume)

func apply_language() -> void:
	TranslationServer.set_locale(language)

func set_bus(bus_name: String, value: float) -> void:
	#Busca l'índex del bus per nom
	var bus_index = AudioServer.get_bus_index(bus_name)
	#Sortir si el bus no existeix
	if bus_index == -1:
		print("No s'ha trobat el bus d'àudio.")
		return
	value = clamp(value, 0.0, 1.0)
	#Si el volum és quasi 0
	if value <= 0.0001:
		#Silencia el bus
		AudioServer.set_bus_mute(bus_index, true)
		AudioServer.set_bus_volume_linear(bus_index, value)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		AudioServer.set_bus_volume_linear(bus_index, value)

func set_music_volume(v: float) -> void:
	#Assignar nou valor de volum
	music_volume = clampf(v, 0.0, 1.0)
	#Aplicar canvi
	apply()
	#Guardar-ho
	save_settings()

func set_sfx_volume(v: float) -> void:
	#Assignar nou valor de volum
	sfx_volume = clampf(v, 0.0, 1.0)
	#Aplicar canvi
	apply()
	#Guardar-ho
	save_settings()

func set_language(lang: String) -> void:
	language = lang
	apply()
	save_settings()

func save_settings() -> void:
	#Crea el fitxer
	var cfg = ConfigFile.new()
	#Guarda els valors
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.set_value("accessibility", "language", language)
	#Guarda el fitxer
	cfg.save(save_path)

func load_settings() -> void:
	var cfg = ConfigFile.new()
	#Si existeix el fitxer i es pot carregar
	if cfg.load(save_path) == OK:
		#Llegeix el valor
		music_volume = float(cfg.get_value("audio", "music_volume", music_volume))
		sfx_volume = float(cfg.get_value("audio", "sfx_volume", sfx_volume))
		language = str(cfg.get_value("accessibility", "language", language))

func has_save() -> bool:
	return FileAccess.file_exists(save_path)

func delete_settings() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
