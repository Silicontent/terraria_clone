extends CanvasLayer

onready var hearts: TextureProgress = $HealthBar
onready var mana: TextureProgress = $ManaBar


func _on_Player_update_stats(h, m):
	hearts.value = h
	mana.value = m
	$TempHealth.text = str(h)
	$TempMana.text = str(m)
