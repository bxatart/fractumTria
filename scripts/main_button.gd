extends Button

var speed = 3.0
var pressed_once = false

func _process(delta: float) -> void:
	#Fer que parpellegi
	modulate.a = (sin(Time.get_ticks_msec() / 1000.0 * speed) + 1) / 2

func _pressed() -> void:
	#Evita doble clic
	if pressed_once:
		return
	pressed_once = true
	Sound.playSfx("menuConfirm")
	await get_tree().create_timer(0.2).timeout
	get_parent().start_game()
