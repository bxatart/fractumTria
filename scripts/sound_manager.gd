extends Node

#Música
var MUSIC = {
	"level1": preload("res://assets/audio/music/greenLevelMusic.wav"),
	"level2": preload("res://assets/audio/music/orangeLevelMusic.wav"),
	"level3": preload("res://assets/audio/music/purpleLevelMusic.wav"),
	"level4": preload("res://assets/audio/music/finalLevelMusic.wav"),
	"intro": preload("res://assets/audio/music/gameIntro.wav"),
	"menu": preload("res://assets/audio/music/levelSelectMusic.wav"),
}

#Efectes
var SFX = {
	"jump": preload("res://assets/audio/sfx/jump.wav"),
	"changeColor": preload("res://assets/audio/sfx/changeColor.wav"),
	"enterLevel": preload("res://assets/audio/sfx/enterLevel.wav"),
	"gameOver": preload("res://assets/audio/sfx/gameOver.wav"),
	"menuBack": preload("res://assets/audio/sfx/menuBack.wav"),
	"menuConfirm": preload("res://assets/audio/sfx/menuConfirm.wav"),
	"menuSelect": preload("res://assets/audio/sfx/menuSelect.wav"),
	"playerHit": preload("res://assets/audio/sfx/playerDamage.wav"),
	"playerDeath": preload("res://assets/audio/sfx/playerDeath.wav"),
	"shot": preload("res://assets/audio/sfx/shooting.wav"),
}
#Guarda el nom de la música
var current_music_name = ""
var musicPlayer: AudioStreamPlayer

func _ready() -> void:
	musicPlayer = $musicPlayer

func playMusic(name: String) -> void:
	#Si no es troba la música
	if not MUSIC.has(name):
		print("No s'ha trobat la música al SoundManager")
		return
	#Si ja està sonant
	if current_music_name == name and musicPlayer.playing:
		return
	#Atura la música que estigui sonant
	musicPlayer.stop()
	#Carrega la música
	musicPlayer.stream = MUSIC[name]
	#Assignar bus d'àudio
	musicPlayer.bus = "Music"
	#Reprodueix música
	musicPlayer.play()
	#Actualitza el nom de la música que sona
	current_music_name = name

func playSfx(name: String) -> void:
	#Si no es troba l'efecte de so
	if not SFX.has(name):
		print("No s'ha trobat l'efecte al SoundManager")
		return
	#Crea un reproductor d'àudio temporal
	var p = AudioStreamPlayer.new()
	#Carrega l'efecte de so
	p.stream = SFX[name]
	#Assigna bus d'àudio
	p.bus = "Sfx"
	#Afegeix el reproductor com a fill del soundManager
	add_child(p)
	#Reprodueix el so
	p.play()
	#Elimina el reproductor quan el so hagi acabat
	p.finished.connect(func():
		p.queue_free()
	)

#Parar la música
func stopMusic() -> void:
	musicPlayer.stop()
	current_music_name = ""
