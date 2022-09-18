extends TileMap

export(int) var world_x = 300  # 200
export(int) var world_y = 300  # 200
export(int) var surf_y = 20  # 20
export(int) var ug_y = 280  # 180

var noise: OpenSimplexNoise = OpenSimplexNoise.new()

var snap_x = 8
var snap_y = 8


# WORLD ELEVATION GENERATION ---------------------------------------------
func gen_base():
	for x in world_x:
		for y in surf_y:
			var tile_id = 0
			set_cell(x, y, tile_id)
	
	for x in world_x:
		for y in ug_y:
			var tile_id = 1
			set_cell(x, surf_y+y, tile_id)


func gen_splotches():
	set_noise_prop(0, 5.0, 0.588, 2.43)
	
	for x in world_x:
		for y in surf_y:
			var tile_id = gen_splotch_id(noise.get_noise_2d(x, y), 0, 1)
			set_cell(x, y, tile_id)
	
	for x in world_x:
		for y in ug_y:
			var tile_id = gen_splotch_id(noise.get_noise_2d(x, y), 1, 0)
			set_cell(x, surf_y+y, tile_id)

# function for getting ID of tile (used by gen_splotches)
func gen_splotch_id(noise_level: float, splotch_tile: int, main_tile: int):
	if noise_level <= -0.2:
		return main_tile
	else:
		return splotch_tile

# originally "if noise.get_noise_2d(x, y) <= -0.2
func gen_caves():
	noise.seed = randi()
	set_noise_prop(0, 5.0, 0.588, 2.43)
	
	for x in world_x:
		for y in ug_y:
			if noise.get_noise_2d(x, y) <= 0.1:
				set_cell(x, surf_y+y, -1)


func gen_surface():
	set_noise_prop(1, 6.2, 0.486, 2.0)
	
	for x in world_x:
		for y in surf_y-10:
			if noise.get_noise_2d(x, y) <= -0.1:
				set_cell(x, 10+y, -1)
	
	for x in world_x:
		var current_tile = get_cell(x, 0)
		if current_tile != -1:
			set_cell(x, 0, 3)




# WORLD FUNCTIONS --------------------------------------------------------
func generate_level():
	randomize()
	noise.seed = randi()
	
	gen_base()
	gen_splotches()
	gen_caves()
	gen_surface()


func set_noise_prop(oct: int, per: float, pers: float, lac: float):
	noise.octaves = oct
	noise.period = per
	noise.persistence = pers
	noise.lacunarity = lac


# BREAKING / PLACING -----------------------------------------------------
func _on_Player_mine(selector):
	var tile: Vector2 = world_to_map(selector.mouse_pos * 8) # gets the tile we clicked on
	var tile_id = get_cellv(tile) # returns the ID of that cell
	
	var new_id = -1
	
	if tile_id != -1: # we clicked on a mud block
		new_id = -1
	set_cellv(tile, new_id)

func _on_Player_place(selector):
	var tile: Vector2 = world_to_map(selector.mouse_pos * 8)
	set_cellv(tile, 2)


# OTHER FUNCTIONS --------------------------------------------------------
func _ready() -> void:
	generate_level()
