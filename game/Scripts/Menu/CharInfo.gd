extends Label

onready var TERRAIN = get_tree().get_root().get_node("World/Terrain")

func _ready():
	set_process(true)
	pass

func _process(delta):
	var mouse_pos = TERRAIN.global2grid_coord(get_global_mouse_pos())
	var cellsize = get_tree().get_root().get_node("World/Terrain").cellsize
	var found = false
	for char in get_tree().get_nodes_in_group("Characters"):
		if (mouse_pos == char.get_grid_pos()):
			var AP = char.get_AP()
			var HP = char.get_HP()
			var MP = char.get_MP()
			var MAX_AP = char.get_MAX_AP()
			var MAX_HP = char.get_MAX_HP()
			var MAX_MP = char.get_MAX_MP()
			self.set_text(str(" mouse: ",mouse_pos," char: ",char,"AP: ",AP,"/",MAX_AP,", ","HP: ",HP,"/",MAX_HP,", ","MP: ",MP,"/",MAX_MP))
			found = true
	if (not found):
		self.set_text(str("mouse: ",mouse_pos))
