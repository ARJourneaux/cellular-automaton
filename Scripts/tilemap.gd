extends TileMapLayer

const WHITE := Vector2i(3,0)
const BLACK := Vector2i(0,0)

# Position is the top left of the center tile, tile map is 15x15 and each tile is 15x15 pixels
const TILE_SIZE := 15
var TOP_LEFT := Vector2i(position.x - 7*TILE_SIZE , position.y - 7*TILE_SIZE)
var BOTTOM_RIGHT := Vector2i(position.x + 8*TILE_SIZE , position.y + 8*TILE_SIZE)

var blocked := true

func _input(event: InputEvent) -> void:
	if !blocked:
		if event is InputEventMouseMotion or event is InputEventMouseButton:
			if event.button_mask != 0:
				_clicked(event.position, event.button_mask)

func _clicked(mouse_pos : Vector2i, button_clicked) -> void:
	# Checks mouse is in tilemap
	if (mouse_pos.x > TOP_LEFT.x and mouse_pos.x < BOTTOM_RIGHT.x and mouse_pos.y > TOP_LEFT.y and mouse_pos.y < BOTTOM_RIGHT.y):
		# Middle tile is 0,0
		var cell_pos := Vector2i((mouse_pos.x - TOP_LEFT.x) / TILE_SIZE - 7, (mouse_pos.y - TOP_LEFT.y) / TILE_SIZE - 7)
		
		# Don't change middle tile
		if cell_pos == Vector2i(0,0): return
		
		if button_clicked == MOUSE_BUTTON_LEFT:
			set_cell(cell_pos, 0, WHITE)
		if button_clicked == MOUSE_BUTTON_RIGHT:
			set_cell(cell_pos, 0, BLACK)

func _save_shader() -> void:
	# dont save unless its a new shader
	if !blocked:
		ShaderCreator.create(get_used_cells_by_id(0, WHITE))

func new_neighbourhood() -> void:
	_clear_board()
	blocked = false

func change_neighbourhood(neigbourhood_num : int) -> void:
	# dont allow drawing on saved neighbourhoods
	blocked = true
	
	_clear_board()
	
	# fill neighbourhood positions
	for pos : Vector2 in ShaderCreator.get_neighbourhood(neigbourhood_num):
		set_cell(pos, 0, WHITE)

func _clear_board() -> void:
	clear()
	for i in range(-7,8):
		for j in range(-7,8):
			set_cell(Vector2(i,j), 0, BLACK)
	erase_cell(Vector2(0,0))
