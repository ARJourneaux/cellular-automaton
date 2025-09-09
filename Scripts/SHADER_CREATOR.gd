extends Node

var shader_dir : DirAccess

func _ready() -> void:
	shader_dir = DirAccess.open("user://Shaders")
	add_user_signal("created_new_shader", [])

const FIRST_STRING = "
#version 450
// Taken and modifier from https://github.com/yumcyaWiz/glsl-compute-shader-sandbox/blob/main/sandbox/life-game/shaders/update-cells.comp
layout(local_size_x = 15, local_size_y = 15) in;

layout(set = 0, binding = 0, rgba32f) uniform image2D cells_in;
layout(set = 0, binding = 1, rgba32f) uniform image2D cells_out;

uint updateCell(ivec2 cell_idx) {
  float current_status = imageLoad(cells_in, cell_idx).x;

  float alive_cells = 0.0;

"

const SECOND_STRING = "

  return uint(current_status < 0.5 && alive_cells > 2.5 && alive_cells < 3.5) + uint(current_status >= 0.5 && alive_cells > 1.5 && alive_cells < 3.5);
}

void main() {
  ivec2 gidx = ivec2(gl_GlobalInvocationID.xy);
  uint next_status = updateCell(gidx);
  imageStore(cells_out, gidx, uvec4(uvec3(next_status), 1));
}
"

func shader_exists(shader_num : int) -> bool:
	return shader_dir.file_exists("user://Shaders/shader" + str(shader_num) + ".txt")

func neighbourhood_exists(neighbourhood_num : int) -> bool:
	return shader_dir.file_exists("user://Shaders/neighbourhood" + str(neighbourhood_num) + ".txt")

func get_shaders() -> PackedStringArray:
	var new_shader_dir = DirAccess.open("user://Shaders")
	# there should be a shader file and neighbourhood for each shader
	# TODO improve this
	var file_number : int = new_shader_dir.get_files().size() / 2
	
	var shader_arr := PackedStringArray()
	shader_arr.resize(file_number)
	
	for i in file_number:
		shader_arr[i] = "shader" + str(i+1)
	
	return shader_arr

func get_neighbourhood(neighbourhood_num : int) -> PackedVector2Array:
	var neighbourhood_file_path := "user://Shaders/neighbourhood" + str(neighbourhood_num) + ".txt"
	var neighbourhood_file := FileAccess.open(neighbourhood_file_path, FileAccess.READ)
	
	var res := PackedVector2Array()
	
	while !neighbourhood_file.eof_reached():
		var coords : String = neighbourhood_file.get_line()
		if !coords.is_empty():
			res.append(str_to_var("Vector2" + coords))
	
	neighbourhood_file.close()
	
	return res

func create(pos_arr : Array[Vector2i]) -> void:
	# there should be a shader file and neighbourhood for each shader
	# TODO improve this
	var new_file_number : int = (shader_dir.get_files().size() / 2) + 1
	
	var shader_file_path := "user://Shaders/shader" + str(new_file_number) + ".txt"
	var shader_file := FileAccess.open(shader_file_path, FileAccess.WRITE)
	
	var neighbourhood_file_path := "user://Shaders/neighbourhood" + str(new_file_number) + ".txt"
	var neighbourhood_file := FileAccess.open(neighbourhood_file_path, FileAccess.WRITE)
	
	var CENTER_STRING := ""
	for pos in pos_arr:
		CENTER_STRING += "  alive_cells += imageLoad(cells_in, cell_idx + ivec2" + str(pos) + ").x;\n"
		neighbourhood_file.store_line(str(pos))
	
	shader_file.store_line(FIRST_STRING + CENTER_STRING + SECOND_STRING)
	
	shader_file.close()
	neighbourhood_file.close()
	
	emit_signal("created_new_shader")
