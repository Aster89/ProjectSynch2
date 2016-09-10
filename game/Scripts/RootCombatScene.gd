extends Node2D

var ACTIVE_PLAYER
var INACTIVE_PLAYER
var TURN_STATE
var ACTIVE_CHAR = null
var GAME_POSSIBLE_STATES = ["Char_Select","Action_Select","Action_Specifics","Action_Execution"]

onready var TERRAIN = get_node("Terrain")
onready var HUD = get_node("HUD")
onready var MENU =  get_node("HUD/MenuSystem")
onready var CAMERA = get_node("Camera2D")

var WORLD_SIZE = Vector2(1024,740)

func _ready():
	ACTIVE_PLAYER = "Player1"
	INACTIVE_PLAYER = "Player2"
	TURN_STATE = "Char_Select"

func change_state(newstate):

	print("Changing state of TURN_STATE from ",self.TURN_STATE," to ",newstate)
	
	self.on_state_exit(self.TURN_STATE)
	
	#Special cases 
	if (self.TURN_STATE == "Char_Select" and newstate == "Action_Select"):
		MENU.menu_generate()
		MENU.menu_load("MainMenu")
	if (self.TURN_STATE == "Action_Specifics" and newstate == "Action_Select"):
		MENU.menu_load(MENU.currentmenupath[MENU.currentmenupath.size()-1])
	
	self.TURN_STATE = newstate
	
	self.on_state_enter(newstate)


func on_state_exit(state):
	if (state == "Action_Select"):
		MENU.menu_hide()
	if (state == "Action_Specifics"):
		HUD.act_sel_req_reset()
		HUD.set_size(Vector2(1,1))
		HUD.update()

func on_state_enter(state):
	if (state == "Char_Select"):
		for char in get_node(INACTIVE_PLAYER).get_children():
			char.get_node("Ghost_Sprite").hide()
		ACTIVE_CHAR.change_state("IDLE")
		ACTIVE_CHAR = null
		MENU.reset()
		MENU.MenuList["MainMenu"].get_child(0).set_disabled(false)
	if (state == "Action_Select"):
		CAMERA.set_camera(ACTIVE_CHAR.get_pos())
		MENU.set_pos(ACTIVE_CHAR.get_pos())
		if ACTIVE_CHAR.get_AP() == 0:
			change_state("Action_Execution")
	if (state == "Action_Specifics"):
		HUD.set_size(WORLD_SIZE)
	if (state == "Action_Execution"):
		if ACTIVE_PLAYER == "Player1":
			ACTIVE_PLAYER = "Player2"
			INACTIVE_PLAYER = "Player1"
		elif ACTIVE_PLAYER == "Player2":
			get_node("MessageManager").process()
			ACTIVE_PLAYER = "Player1"
			INACTIVE_PLAYER = "Player2"
			get_node("/root/globals").currentTurn += 1
			print("inizio turno #", get_node("/root/globals").currentTurn)
		change_state("Char_Select")

func get_state():
	return TURN_STATE
