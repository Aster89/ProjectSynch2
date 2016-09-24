extends Control

onready var TERRAIN = get_parent().get_node("Terrain")
onready var WORLD = get_parent()
onready var MENU = get_node("MenuSystem")

var ActSelReq = {}

func _ready():
	act_sel_req_reset()
	set_process_unhandled_input(true)
	set_process_input(true)

func _unhandled_input(event):
	if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed()):
		if (WORLD.get_state() == "Char_Select" or WORLD.get_state() == "Action_Select"):
			get_tree().set_input_as_handled()
			var selected_pos = TERRAIN.global2grid_coord(get_global_mouse_pos())
			for Character in WORLD.get_node(WORLD.ACTIVE_PLAYER).get_children():
				if (Character.get_grid_pos() == selected_pos and not Character.CHAR_STATE == "DISABLED"): # TODO: how's "different from"? /=? or ~=?
					if (WORLD.get_state() == "Action_Select"):
						WORLD.change_state("Char_Select")
					Character.change_state("ACTIVE")
					WORLD.ACTIVE_CHAR = Character
					WORLD.change_state("Action_Select")
					# print("the char ", WORLD.ACTIVE_CHAR, " has ", WORLD.ACTIVE_CHAR.HP, " HP(s)")

	if(event.is_action_pressed("ui_cancel")):
		if (WORLD.get_state()=="Action_Select" and MENU.currentMenu == MENU.MenuList["MainMenu"]):
			WORLD.change_state("Char_Select")
			get_tree().set_input_as_handled()
			
		elif (WORLD.get_state()=="Action_Select" and MENU.currentMenu != MENU.MenuList["MainMenu"]):
			MENU.currentmenupath.pop_back()
			MENU.menu_load(MENU.currentmenupath[MENU.currentmenupath.size()-1])
			get_tree().set_input_as_handled()

		elif (WORLD.get_state() == "Action_Specifics"):
			if (ActSelReq.flag == 1):
				WORLD.change_state("Action_Select")
				get_tree().set_input_as_handled()
			elif (ActSelReq.flag == 2):
				ActSelReq.flag -= 1
				ActSelReq.reply = Vector2()
				update()
				get_tree().set_input_as_handled()
		#NEED TO ADD MORE

func _input(event):
	if(event.type == InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed()):
		if (WORLD.get_state() == "Action_Specifics"):
			var selected_pos = TERRAIN.global2grid_coord(get_global_mouse_pos())
			get_tree().set_input_as_handled()
			if (ActSelReq.flag == 1):
				get_tree().set_input_as_handled()
				if (ActSelReq.requesting_action.global_selectable_area.find(selected_pos)>-1):
					ActSelReq.flag = 2
					ActSelReq.reply = selected_pos
					update()
			elif (ActSelReq.flag == 2):
				get_tree().set_input_as_handled()
				if (selected_pos == ActSelReq.reply):
					get_tree().set_input_as_handled()
					ActSelReq.requesting_action.accept_reply(ActSelReq.reply)

func _draw():
	if (WORLD.get_state() == "Action_Specifics"):
		if (ActSelReq.flag > 0):
			var rectsize = Vector2(20,20)
			for tile in ActSelReq.requesting_action.global_selectable_area:
				draw_rect(Rect2(TERRAIN.grid2global_coord(tile)-rectsize/2,rectsize),Color(1,0,0,0.3))
		if (ActSelReq.flag == 2):
			var rectsize = Vector2(30,30)
			if (ActSelReq.requesting_action.AoE_rotate):
				ActSelReq.requesting_action.AoE_update(ActSelReq.reply)
			for tile in ActSelReq.requesting_action.AoE:
				draw_rect(Rect2(TERRAIN.grid2global_coord(tile+ActSelReq.reply)-rectsize/2,rectsize),Color(0,1,1,0.9))

func act_sel_req_reset():
	ActSelReq.flag = 0
	ActSelReq.requesting_action = null
	ActSelReq.reply = Vector2()
	
func set_target_request(action):
	WORLD.change_state("Action_Specifics")
	ActSelReq.flag = 1
	ActSelReq.requesting_action = action
	update()
