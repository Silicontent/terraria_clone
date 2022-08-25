# This movement code is from https://kidscancode.org/godot_recipes/2d/platform_character/

extends KinematicBody2D

signal mine
signal place

const GRAV := 1000
const ACC := 0.15
const FRIC := 0.35

var start_pos = Vector2(462, -169)
var speed := 100
var jump_speed := -300
var velocity := Vector2.ZERO


func _ready() -> void:
	to_spawn()

func to_spawn():
	global_position = start_pos


func movement():
	var dir = 0
	
	if Input.is_action_pressed("mv_left"):
		dir -= 1
	if Input.is_action_pressed("mv_right"):
		dir += 1
	
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, ACC)
	else:
		velocity.x = lerp(velocity.x, 0, FRIC)


func _physics_process(delta):
	movement()
	
	velocity.y += GRAV * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("mv_jump"):
		if is_on_floor():
			velocity.y = jump_speed
	
	if Input.is_action_just_pressed("mb_right"):
		emit_signal("place")
	if Input.is_action_just_pressed("util_enter"):
		to_spawn()


func _on_GenLevel_pressed():
	to_spawn()


func _on_CopperPickaxe_mine():
	emit_signal("mine")
