# This movement code is from https://kidscancode.org/godot_recipes/2d/platform_character/

extends KinematicBody2D

signal mine(block_select)
signal place(block_select)
signal update_stats(h, m)

const GRAV := 1000
const ACC := 0.15
const FRIC := 0.35

var start_pos = Vector2(27, -18)
var speed := 100
var velocity := Vector2.ZERO

var jump_speed := -325
var vspeed := 0.0
var grounded := false
var is_jumping := false
var coy_time:= false

var health := 100
var max_health := 100
var mana := 20
var max_mana := 200

onready var sprite: Sprite = $Sprite
onready var block_select: Sprite = $Selector
onready var coy_timer: Timer = $CoyoteTimer


func _ready() -> void:
	to_spawn()
	emit_signal("update_stats", health, mana)

func to_spawn():
	global_position = start_pos


# MOVEMENT ---------------------------------------------------------------
func movement():
	var dir = 0
	
	if Input.is_action_pressed("mv_left"):
		dir -= 1
		sprite.flip_h = true
	if Input.is_action_pressed("mv_right"):
		dir += 1
		sprite.flip_h = false
	
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, ACC)
	else:
		velocity.x = lerp(velocity.x, 0, FRIC)


func vert_movement(delta):
	if(is_on_ceiling()):
		velocity.y = 10
		vspeed = 10
	
	if(grounded == true and !is_on_floor()): # just left the ground
		coy_time = true
		coy_timer.start()
		
	if(is_on_floor()):
		grounded = true
		coy_timer.stop()
		coy_time = false
	else:
		grounded = false

	if(!is_on_floor()):
		vspeed += (GRAV * delta)
	else:
		vspeed = 0
		if(Input.is_action_just_pressed("mv_jump")):
			coy_time = false
			coy_timer.stop()
			vspeed = jump_speed
			
	if(coy_time and Input.is_action_just_pressed("mv_jump")):
		coy_time = false
		coy_timer.stop()
		vspeed = jump_speed

	velocity.y = vspeed


func _physics_process(delta):
	movement()
	vert_movement(delta)
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("mv_jump"):
		if grounded and is_jumping == false:
			velocity.y = jump_speed
			is_jumping = true
			coy_timer.stop()
	
	if Input.is_action_just_pressed("mb_right"):
		emit_signal("place", block_select)
	
	if Input.is_action_just_pressed("util_enter"):
		to_spawn()


# STATS ------------------------------------------------------------------
func change_stats(h: int, m: int):
	health += h
	mana += m
	
	health = clamp(health, 0.0, max_health)
	mana = clamp(mana, 0.0, max_mana)
	
	emit_signal("update_stats", health, mana)


# debug inputs to change stats
func _input(event):
	if event is InputEventKey and event.scancode == KEY_COMMA:
		change_stats(-2, 0)
	if event is InputEventKey and event.scancode == KEY_PERIOD:
		change_stats(2, 0)
	if event is InputEventKey and event.scancode == KEY_SEMICOLON:
		change_stats(0, -2)
	if event is InputEventKey and event.scancode == KEY_APOSTROPHE:
		change_stats(0, 2)


# SIGNALS ----------------------------------------------------------------
func _on_CopperPickaxe_mine():
	emit_signal("mine", block_select)


func _on_CoyoteTimer_timeout():
	coy_time = false
