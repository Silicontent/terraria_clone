extends TileMap

export(int) var world_x = 200
export(int) var world_y = 200
export(int) var surf_y = 20
export(int) var ug_y = 180

var noise: OpenSimplexNoise = OpenSimplexNoise.new()

var snap_x = 8
var snap_y = 8

onready var selector: Sprite = $Selector
onready var mouse_light: Light2D = $Selector/Light2D


# WORLD ELEVATION GENERATION -----------------------------
# Surface functions
func generate_surface():
	set_noise_prop(0, 5, 0.1, 1.43)
	
	for x in world_x:
		for y in surf_y:
			var tile_id = generate_surf_id(noise.get_noise_2d(x, y))
			if tile_id != -1:
				set_cell(x, y, tile_id)
	
	for x in world_x:
		set_cell(x, 0, 3)

func generate_surf_id(noise_level: float):
	var tile_to_gen = -1
	var rand_num = randi() % 100 + 1
	
	if rand_num <= 95:
		tile_to_gen = 0
	elif rand_num >= 96:
		tile_to_gen = 1
	
	return tile_to_gen


# Underground functions
func generate_underground():
	set_noise_prop(0, 5, 0.588, 2.43)
	
	for x in world_x:
		for y in ug_y:
			var tile_id = generate_ug_id(noise.get_noise_2d(x, y))
			if tile_id != -1:
				set_cell(x, surf_y+y, tile_id)

func generate_ug_id(noise_level: float):
	# uses random numbers to mix stone and mud around the world
	var tile_to_gen = -1
	var rand_num = randi() % 100 + 1
	
	if rand_num <= 60:
		tile_to_gen = 0
	elif rand_num >= 61 and rand_num != 100:
		tile_to_gen = 1
	elif rand_num == 100:  # small chance of natural wood
		tile_to_gen = 2
	
	# adds air into the world for caves, returns value to generate_level()
	if noise_level <= -0.1:
		return -1
	else:
		return tile_to_gen


# World functions
func generate_level():
	generate_surface()
	generate_underground()

func clear_level():
	for x in world_x:
		for y in world_y:
			set_cell(x, y, -1)

func set_noise_prop(oct: int, per: int, pers: float, lac: float):
	randomize()
	noise.seed = randi()
	noise.octaves = oct
	noise.period = per
	noise.persistence = pers
	noise.lacunarity = lac


# SIGNALS
func _on_GenLevel_pressed():
	clear_level()
	generate_level()


# BREAKING / PLACING
func _on_Player_mine():
	var tile : Vector2 = world_to_map(selector.mouse_pos * 8) # gets the tile we clicked on
	var tile_id = get_cellv(tile) # returns the ID of that cell
	
	var new_id = -1
	
	if(tile_id != -1): # we clicked on a mud block
		new_id = -1
	set_cellv(tile, new_id)


func _on_Player_place():
	var tile: Vector2 = world_to_map(selector.mouse_pos * 8)
	set_cellv(tile, 2)


# OTHER FUNCTIONS
func _ready() -> void:
	generate_level()
