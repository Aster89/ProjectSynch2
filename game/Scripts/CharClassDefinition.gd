# Class for the generic character, which is extended to define actual
# classes of character, such as Lancer, Archer, ...
class Character:

	extends Node2D

	#var CHAR_STATES = ["IDLE", "ACTIVE"] # TODO: should contain the state SELECTABLE
	var CHAR_STATES = ["IDLE", "ACTIVE", "DISABLED"]
	var CHAR_STATE # TODO: maybe could be renamed simply as STATE
	var ALIVE

	var TERRAIN
	var GRID_POS
	var GHOST_GRID_POS

	var TEAM
	var CLASS_TYPE
	var TEXTURE
	var AVAIL_ACTIONS
	var WEIGHT = 1
	var AP
	var HP
	var MP
	var MAX_AP
	var MAX_HP
	var MAX_MP


	func _init():
		# associate sprites
		ALIVE = true
		var sprite = Sprite.new()
		sprite.set_name("Sprite")
		self.add_child(sprite)

		var sprite = Sprite.new()
		sprite.set_name("Ghost_Sprite")
		self.add_child(sprite)

		# define possible states and set current state to inactive
		CHAR_STATE = "IDLE"


	func _ready():
		# get the terrain node from the tree
		TERRAIN = get_tree().get_root().get_node("World/Terrain")

		# initialize AP, HP and MP at their maximum values
		AP = MAX_AP
		HP = MAX_HP
		MP = MAX_MP


	func change_state(newstate):
		# check that newstate is in the list of possible states
		if (CHAR_STATES.find(newstate)>-1):
			self.on_state_exit(self.CHAR_STATE)

			# print("Changing state of ",self.get_name()," from ",self.CHAR_STATE," to ",newstate)
			CHAR_STATE = newstate

			self.on_state_enter(newstate)
		else:
			print("Error in state handling, state ",newstate," does not exist.")
			self.get_tree().quit()


	func on_state_enter(newstate):
		# Method to be called when the FSM enters in a new state
		#if (newstate == "ACTIVE"):
		#	self.get_node("Sprite").set_texture(TEXTURE)

		if (newstate == "IDLE"):
			self.reset_status()
		#	self.get_node("Sprite").set_texture(TEXTURE)
		pass


	func on_state_exit(oldstate):
		pass


#=========================================================================================
# MANAGE STATUS
#=========================================================================================
	func get_grid_pos():
		return GRID_POS

	func get_ghost_grid_pos():
		return GHOST_GRID_POS

	func set_grid_pos(new_pos):
		GRID_POS = new_pos
		self.set_pos(TERRAIN.grid2global_coord(GRID_POS))

	func set_ghost_grid_pos(new_pos):
		GHOST_GRID_POS = new_pos
		get_node("Ghost_Sprite").set_global_pos(TERRAIN.grid2global_coord(GHOST_GRID_POS))


	func get_HP():
		return HP
	
	func modify_HP(HPmod):
		HP += HPmod

	func get_AP():
		return AP

	func reduce_AP(fatigue):
		AP -= fatigue

	func reset_status():
		AP = MAX_AP

#=========================================================================================


	func get_avail_actions():
		return AVAIL_ACTIONS


	func get_walkable_area():
		# initialize the array which is going to contain the walkable cells
		var walkable = {}
		walkable.cell = []
		walkable.AP_cost = []
		# retrieve the terrain map
		var terrain_map = TERRAIN.get_terrain_map()
		# initialize the map of stamina consumption as unwalkable (AP+1)
		var walkmap = get_node("/root/globals").matrix_init(TERRAIN.nrow,TERRAIN.ncol,self.AP+1)
		# move to the current position (not moving) imply no stamina consumption...
		walkmap[get_grid_pos()] = 0
		# ... and add current position to the walkable area
		walkable.cell.append(get_grid_pos())
		walkable.AP_cost.append(0)

		var curind = 0
		var newcoord = Vector2()
		var newval = null

		# Neighbouring cells [North, West, South, East]
		var neighbours = Vector2Array([Vector2(-1,0),Vector2(0,-1),Vector2(1,0),Vector2(0,1)])

		while (curind < walkable.cell.size()): # for each unprocessed cell
			if (walkmap[walkable.cell[curind]] < self.AP): # if not all stamina is consumed to move to that cell
				for neighbour in neighbours: # for each neighbouring cell
					newcoord = walkable.cell[curind] + neighbour # considered as newcoordinate
					if (newcoord.x >= 0 and newcoord.x <= TERRAIN.nrow-1 and newcoord.y >= 0 and newcoord.y <= TERRAIN.ncol-1): # check if it is in the map
						newval = walkmap[walkable.cell[curind]] + terrain_map[newcoord] # and add the stamina consumption of the new cell to the current one
						if (walkmap[newcoord] > newval): # if the current path imply stamina consumption lower than that previously computed
							walkmap[newcoord] = newval   # update the stamina consumption map
							if (newval <= self.AP):  # if the stamina consumption of the current cell is less than char's stamina
								var tobeadded = true # mark the current cell as to be added
								for i in range(curind+1, walkable.cell.size()): # if the current cell...
									if (walkable.cell[i] == newcoord): # ... is in the list already
										tobeadded = false # ... mark it as not to be added
								if tobeadded: # if the current cell has to be added
									walkable.cell.append(newcoord) # add it
									walkable.AP_cost.append(newval)
			curind += 1

		curind = 0
		while (curind < walkable.cell.size()):
			var parsingindex = curind + 1
			while (parsingindex < walkable.cell.size()):
				if (walkable.cell[parsingindex] == walkable.cell[curind]):
					walkable.cell.erase(parsingindex)
					walkable.AP_cost.erase(parsingindex)
				else:
					parsingindex += 1
			curind += 1
		walkable.cell.pop_front()
		return walkable



# Lancer character class
class Lancer:

	extends Character

	func _init():

		CLASS_TYPE = "Lancer"
		AVAIL_ACTIONS = ["Standard Attack","Sweep","Pierce","HammerDown"]
		WEIGHT = WEIGHT + 2
		MAX_HP = 6
		MAX_AP = 5
		MAX_MP = 0


	func _ready():

		if (self.TEAM == "P1"):
			TEXTURE = ResourceLoader.load("res://Textures/Characters/blueplayer_20x20pxl.tex")
		elif (self.TEAM == "P2"):
			TEXTURE = ResourceLoader.load("res://Textures/Characters/redplayer_20x20pxl.tex")

		# set the texture of the Lancer character
		# real texture
		get_node("Sprite").set_texture(TEXTURE)
		# ghost texture
		get_node("Ghost_Sprite").set_texture(TEXTURE)
		get_node("Ghost_Sprite").set_rotd(180)
		get_node("Ghost_Sprite").set_opacity(.5)
		get_node("Ghost_Sprite").hide()




# Archer character class
class Archer:

	extends Character

	func _init():

		CLASS_TYPE = "Archer"
		AVAIL_ACTIONS = ["Shot", "TripleArrow"]

		WEIGHT = WEIGHT + 1
		MAX_HP = 5
		MAX_AP = 4
		MAX_MP = 0


	func _ready():

		if (self.TEAM == "P1"):
			TEXTURE = ResourceLoader.load("res://Textures/Characters/blueplayer_20x20pxl.tex")
		elif (self.TEAM == "P2"):
			TEXTURE = ResourceLoader.load("res://Textures/Characters/redplayer_20x20pxl.tex")

		# set the texture of the Archer character
		# real texture
		get_node("Sprite").set_texture(TEXTURE)
		# ghost texture
		get_node("Ghost_Sprite").set_texture(TEXTURE)
		get_node("Ghost_Sprite").set_rotd(180)
		get_node("Ghost_Sprite").set_opacity(.5)
		get_node("Ghost_Sprite").hide()
