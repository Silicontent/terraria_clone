extends Control

onready var hearts: TextureProgress = $HealthBar
onready var mana: TextureProgress = $ManaBar


func _on_Player_update_stats(h, m):
	hearts.value = h
	mana.value = m
	hearts.hint_tooltip = str(h)
	mana.hint_tooltip = str(m)
