extends CanvasLayer

onready var coords_lbl = $Coords


func _on_Player_broadcast_coords(coords):
	coords_lbl.text = coords
