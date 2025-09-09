extends Node2D

var texture_target : TextureRect
var size_inp : LineEdit
var speed_inp : HSlider
var run_button : Button
var tile_map : TileMapLayer
var save_shader_button : Button
var shader_drop_down : OptionButton

var size : int = 600
var image_format := Image.FORMAT_RGBA8

func _ready() -> void:
	texture_target = $CanvasLayer/TextureRect
	size_inp = $VBoxContainer/Size/size_input
	speed_inp = $VBoxContainer/sim_speed
	run_button = $VBoxContainer/change_running
	tile_map = $TileMapLayer
	save_shader_button = $VBoxContainer/save_shader
	shader_drop_down = $VBoxContainer/shader_dropdown
	
	ShaderCreator.connect("created_new_shader", populate_dropdown)
	
	populate_dropdown(false)
	
	shader_drop_down.select(0)
	
	save_shader_button.disabled = true

func populate_dropdown(new_shader : bool = true) -> void:
	save_shader_button.disabled = true
	
	shader_drop_down.clear()
	var shader_arr : PackedStringArray = ShaderCreator.get_shaders()
	for i in shader_arr.size():
		shader_drop_down.add_item(shader_arr[i])
	shader_drop_down.add_item("New")
	
	_on_shader_dropdown_item_selected(shader_drop_down.item_count-2 if new_shader else 1)

func _generate_new_texture() -> void:
	# dont run shader while generating texture
	run_button.disabled = true
	if texture_target.running:
		_change_run_mode()
	
	var data_array : PackedByteArray = PackedByteArray()
	data_array.resize(size*size*4)
	
	for i in range(0,size*size):
		if (randi() % 2 == 0):
			data_array[i*4] = 0
			data_array[i*4+1] = 0
			data_array[i*4+2] = 0
		else:
			data_array[i*4] = 255
			data_array[i*4+1] = 255
			data_array[i*4+2] = 255
		data_array[i*4+3] = 255;
	
	var image := Image.create_from_data(size, size, false, image_format, data_array)
	texture_target.texture = ImageTexture.create_from_image(image)
	
	texture_target.setup()
	
	run_button.disabled = false

func _new_size(new_text: String) -> void:
	var size_string = new_text
#	TODO only allow integer input
	if size_string.is_valid_int():
		size = size_string.to_int()

func _change_run_mode() -> void:
	texture_target.change_run_mode()
	if run_button.text == "Run":
		run_button.text = "Stop"
	else:
		run_button.text = "Run"

func _on_sim_speed_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Engine.time_scale = speed_inp.value

func _on_shader_dropdown_item_selected(index: int) -> void:
	shader_drop_down.select(index)
	
	# new shader option is selected
	if (index == shader_drop_down.item_count-1):
		save_shader_button.disabled = false
		tile_map.new_neighbourhood()
	
	else:
		save_shader_button.disabled = true
		run_button.disabled = true
		if texture_target.running:
			_change_run_mode()
		
		# Change shader
		if ShaderCreator.shader_exists(index+1):
			texture_target.change_shader(index+1)
		else:
			print("Shader", str(index+1), " does not exist")
		
		# Change neigbourhood
		if ShaderCreator.neighbourhood_exists(index+1):
			tile_map.change_neighbourhood(index+1)
		else:
			print("Neighbourhood", str(index+1), " does not exist")
		
		run_button.disabled = false
