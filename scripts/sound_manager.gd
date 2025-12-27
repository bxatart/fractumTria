extends Node

#Música
var MUSIC = {
	"level1": preload("res://assets/audio/music/greenLevelMusic.wav"),
	"level2": preload("res://assets/audio/music/orangeLevelMusic.wav"),
	"level3": preload("res://assets/audio/music/purpleLevelMusic.wav"),
	"finalLevel": preload("res://assets/audio/music/finalLevelMusic.wav"),
	"intro": preload("res://assets/audio/music/gameIntro.wav"),
	"introAnim": preload("res://assets/audio/music/introAnimMusic.wav"),
	"levelSelect": preload("res://assets/audio/music/levelSelectMusic.wav"),
	"gameOver": preload("res://assets/audio/music/gameOverMusic.wav"),
	"end": preload("res://assets/audio/music/endingMusic.wav"),
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
	"playerFalling": preload("res://assets/audio/sfx/playerFalling.wav"),
	"shot": preload("res://assets/audio/sfx/shooting.wav"),
	"endLevel": preload("res://assets/audio/sfx/endLevel.wav"),
	"checkpoint": preload("res://assets/audio/sfx/checkpoint.wav"),
	"enemyDamage": preload("res://assets/audio/sfx/enemyDamage.wav"),
	"enemyDeath": preload("res://assets/audio/sfx/enemyDeath.wav"),
	"enemyChangeColor": preload("res://assets/audio/sfx/finalEnemyChangeColor.wav"),
	"enemySpawn": preload("res://assets/audio/sfx/finalEnemySpawn.wav"),
	"finalEnemyDeath": preload("res://assets/audio/sfx/finalEnemyDeath.wav"),
	"wave": preload("res://assets/audio/sfx/wave.wav"),
	"shieldOff": preload("res://assets/audio/sfx/shieldOff.wav"),
}
#Guarda el nom de la música
var current_music_name = ""
var musicPlayer: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	musicPlayer = $musicPlayer
	musicPlayer.process_mode = Node.PROCESS_MODE_INHERIT

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

func playSfx(name: String) -> AudioStreamPlayer:
	#Si no es troba l'efecte de so
	if not SFX.has(name):
		print("No s'ha trobat l'efecte al SoundManager")
		return null
	#Crea un reproductor d'àudio temporal
	var p = AudioStreamPlayer.new()
	#Sona encara que estigui el joc en pausa
	p.process_mode = Node.PROCESS_MODE_ALWAYS
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
	return p

func playEnemySfx(name: StringName, pos: Vector2) -> AudioStreamPlayer2D:
	#Si no es troba l'efecte de so
	if not SFX.has(name):
		print("No s'ha trobat l'efecte al SoundManager")
		return null
	#Crea un reproductor d'àudio temporal
	var p = AudioStreamPlayer2D.new()
	#Sona encara que estigui el joc en pausa
	p.process_mode = Node.PROCESS_MODE_ALWAYS
	#Carrega l'efecte de so
	p.stream = SFX[name]
	#Assigna bus d'àudio
	p.bus = "Sfx"
	p.global_position = pos
	#Afegeix el reproductor com a fill del soundManager
	add_child(p)
	#Reprodueix el so
	p.play()
	#Elimina el reproductor quan el so hagi acabat
	p.finished.connect(func():
		p.queue_free()
	)
	return p

#Parar la música
func stopMusic() -> void:
	musicPlayer.stop()
	current_music_name = ""

func pauseMusic() -> void:
	musicPlayer.stream_paused = true

func resumeMusic() -> void:
	musicPlayer.stream_paused = false
