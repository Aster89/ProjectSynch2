extends Sprite

var mapsize = {}
var ncol = 20
var nrow = 20
var cellsize = 25
var base_terrain_map = {}
var grid_offset = Vector2(250,100)

func _ready():
	mapsize["width"] = self.get_texture().get_size().width*self.get_scale().x
	mapsize["height"] = self.get_texture().get_size().height*self.get_scale().y
	self.set_pos(grid_offset+Vector2(mapsize["width"]/2,mapsize["height"]/2))
	terrain_map_init()

#===========================================================================================
# Functions for global to grid coordinate conversion and viceversa
#===========================================================================================
func global2grid_coord(pos):
	## Note: pos must be a Vector2 of global coordinates
	return Vector2(int((pos[1]-grid_offset[1])/cellsize),int((pos[0]-grid_offset[0])/cellsize))

func grid2global_coord(grid_pos):
	## Note : this function must be further modified, currently the local position with respect 
	## to the terrain is retrieved, however I am interested in the global position
	#### Note2 : This might not be an issue, the terrain is locked in the global system of coordinates, 
	#### therefore, provided that global coordinates are specified and the grid_offset is set up correctly,
	#### the following call will provide the correct coordinates. The coordinates in the viewport are not the
	#### global coordinates, only the mouse will provide the viewport coordinates but they can be easily converted
	#### through the use of 
	return Vector2((grid_pos[1]+0.5)*cellsize,(grid_pos[0]+0.5)*cellsize)+grid_offset
	
#===========================================================================================
# Check if the input is a tile of the map
#===========================================================================================
func is_available_tile(tile):
	if (tile.x >= 0 and tile.x < ncol and tile.y >= 0 and tile.y <nrow):
		return true
	else:
		return false

#===========================================================================================
# Functions used to initialize and retrieve the terrain map
#===========================================================================================
func terrain_map_init():
	## Note : The map is currently initialized as a uniform matrix of ones, we will want in general
	## to be able to load it from a file so that multiple maps can be easily created and stored
	base_terrain_map = get_node("/root/globals").matrix_init(self.nrow,self.ncol,1)


func get_terrain_map():
	# Note : the map is currently computed modifying the terrain map with the position of all the 
	# children of Player1 and Player2, we might want to have children for the players that are
	# not to be considered an obstacle, consider movable obstacles that are not children of the player nodes
	# One possibility is to get each one of these items that must be considered as members of a group: "Obstacles"
	# so that we can iterate on each one in the same way
	
	# BUG_REPORT 
	# The terrain_map was instantiated as a reference to the base_terrain_map instead of its copy,
	# for now the str2var(var2str()) method has been used to bypass this. This should be changed to a 
	# less sloppy and faster solution
	var terrain_map = {}
	terrain_map = str2var(var2str(base_terrain_map))
	var charfillin = 100
	for char in get_parent().get_node("Player1").get_children():
		terrain_map[char.get_grid_pos()] = charfillin
	for char in get_parent().get_node("Player2").get_children():
		terrain_map[char.get_grid_pos()] = charfillin
	return terrain_map
