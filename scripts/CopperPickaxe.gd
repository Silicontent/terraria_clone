extends Area2D

signal mine
onready var anim_player = $AnimationPlayer
var can_swing = true


func _ready() -> void:
	hide()


func _physics_process(delta):
	if Input.is_action_pressed("mb_left") and can_swing:
		show()
		anim_player.play("swing")
		can_swing = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "swing":
		hide()
		emit_signal("mine")
		anim_player.play("RESET")
		can_swing = true
