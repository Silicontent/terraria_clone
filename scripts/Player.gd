# This movement code is from https://kidscancode.org/godot_recipes/2d/platform_character/

extends KinematicBody2D

signal mine(block_select)
signal place(block_select)
signal update_stats(h, m)

const GRAV := 1000
const ACC := 0.15
const FRIC := 0.35

var start_pos = Vector2(800, -15)
var speed := 100
var fly_speed := 200
var jump_speed := -325
var velocity := Vector2.ZERO

var health := 100
var max_health := 100
var mana := 20
var max_mana := 200

var is_creative := false

onready var sprite: AnimatedSprite = $AnimSprite
onready var block_select: Sprite = $Selector


func _ready() -> void:
	to_spawn()
	emit_signal("update_stats", health, mana)
	$CollisionShape2D.disabled = false
	is_creative = false

func to_spawn():
	global_position = start_pos


# MOVEMENT ---------------------------------------------------------------
func movement():
	var dir = 0
	var k_dir = 0
	
	if Input.is_action_pressed("mv_left"):
		dir -= 1
		sprite.flip_h = true
	if Input.is_action_pressed("mv_right"):
		dir += 1
		sprite.flip_h = false
	
	if is_creative:
		if Input.is_action_pressed("mv_up"):
			k_dir -= 1
		if Input.is_action_pressed("mv_down"):
			k_dir += 1
	
	if dir != 0 or k_dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, ACC)
		if is_creative:
			velocity.y = lerp(velocity.y, k_dir * fly_speed, ACC)
		
		sprite.play("walking")
	else:
		velocity.x = lerp(velocity.x, 0, FRIC)
		if is_creative:
			velocity.y = lerp(velocity.y, 0, FRIC)
		
		sprite.play("idle")


func _physics_process(delta):
	movement()
	
	if is_creative == false:
		velocity.y += GRAV * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("mv_jump"):
		if is_on_floor():
			velocity.y = jump_speed
#			sprite.play("jump")
	
#	if Input.is_action_just_pressed("mb_left"):
#		sprite.play("mine")
	if Input.is_action_just_pressed("mb_right"):
		emit_signal("place", block_select)
	
	if Input.is_action_just_pressed("util_enter"):
		to_spawn()
	if Input.is_action_just_pressed("util_k"):
		is_creative = not(is_creative)
		if is_creative:
			$CollisionShape2D.disabled = true
		else:
			$CollisionShape2D.disabled = false


# STATS ------------------------------------------------------------------
func change_stats(h: int, m: int):
	health += h
	mana += m
	
	health = clamp(health, 0, max_health)
	mana = clamp(mana, 0, max_mana)
	
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
func _on_GenLevel_pressed():
	to_spawn()


func _on_CopperPickaxe_mine():
	emit_signal("mine", block_select)
