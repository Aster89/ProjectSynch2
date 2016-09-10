extends Node

func createaction(ActionName,Char):
	if (ActionName == "Standard Attack"):
		return StandardAttack.new(Char)
	elif(ActionName == "Sweep"):
		return Sweep.new(Char)
	elif(ActionName == "Pierce"):
		return Pierce.new(Char)
	elif(ActionName == "HammerDown"):
		return HammerDown.new(Char)
	else:
		print(str("Error action ", ActionName, " is not defined"))

#===========================================================================================
# ACTION CLASS DEFINITION
#===========================================================================================
class Action:

	extends Node

	var ROOT
	var WORLD
	var Player
	var Target
	var ExecTurn
	var Sender
	var AP_cost
	var HP_cost
	var MP_cost
	
	func _init(Char):
		# get a reference to the root node
		ROOT = Char.get_tree().get_root()
		WORLD = Char.get_tree().get_root().get_node("World")
		# define the sender as the char that generated this action
		Sender = Char
		# bond the player to the action he chooses
		Player = WORLD.ACTIVE_PLAYER
		ExecTurn = 0 # TODO: this should be moved/modified in the specific action
	
	func accept_reply(reply):
		print(str("ERR: No accept_reply method is defined for selected action."))
	
	func send_action():
		ROOT.get_node("World/MessageManager").add_action(self)

		Sender.reduce_AP(AP_cost) # this should be moved elsewhere

		#Get back to main menu and allow selection of another action
		ROOT.get_node("World/HUD/MenuSystem").reset()
		ROOT.get_node("World/HUD/MenuSystem").menu_generate()
		ROOT.get_node("World/HUD/MenuSystem").menu_load("MainMenu")

		ROOT.get_node("World").change_state("Action_Select")
		
	func execute():
		print(str("ERR: No execute method is defined for selected action "))

#===========================================================================================
# MOVE ACTION CLASS DEFINITION
#===========================================================================================
class MoveAction:
	extends Action
	
	var global_selectable_area
	var AoE
	var AoE_rotate
	var temp
	
	func _init(Char).(Char):
		AoE_rotate = false
		AoE = Vector2Array()
		AoE.push_back(Vector2(0,0))
		ExecTurn = ROOT.get_node("globals").get_current_turn()
		temp = Sender.get_walkable_area()
		global_selectable_area = temp.cell
		ROOT.get_node("World/HUD").set_target_request(self)

	func accept_reply(reply):
	
		Target = reply
		ROOT.get_node("World/MessageManager").add_action(self)
		for i in range(global_selectable_area.size()):
			if (global_selectable_area[i] == reply):
				AP_cost = temp.AP_cost[i]
		HP_cost = 0 # moving costs action points only, but...
		MP_cost = 0 # ... we could harvest magic blackberries!
		Sender.reduce_AP(AP_cost)
		#Sender.reduce_HP(HP_cost)
		#Sender.reduce_MP(MP_cost)
		print("sender AP reduced by ", AP_cost)
		Sender.set_ghost_grid_pos(Target)
		Sender.get_node("Ghost_Sprite").show()
		ROOT.get_node("World/HUD/MenuSystem").reset()
		ROOT.get_node("World/HUD/MenuSystem").menu_generate()
		ROOT.get_node("World/HUD/MenuSystem").menu_load("MainMenu")
		ROOT.get_node("World/HUD/MenuSystem").MenuList["MainMenu"].get_child(0).set_disabled(true)
		ROOT.get_node("World").change_state("Action_Select")

	func execute():
		if (Sender.ALIVE):
			print("Moving ", Sender.get_name(), " from cell ", Sender.get_grid_pos(), " to cell", Target)
			Sender.set_grid_pos(Target)
			Sender.set_ghost_grid_pos(Target)


#===========================================================================================
# AttackAction template definition
#===========================================================================================
class AttackAction:

	extends Action
	
	var Damage
	var relative_selectable_area
	var global_selectable_area
	var AoE_start
	var AoE
	var AoE_rotate
	
	func _init(Char).(Char):
		AoE_rotate = false
		global_selectable_area = []
	
	func setup():
		comp_global_selectable_area()
		ExecTurn += ROOT.get_node("globals").get_current_turn()
		ROOT.get_node("World/HUD").set_target_request(self)
	
	func comp_global_selectable_area():
		for reltile in relative_selectable_area:
			var globtile =  Sender.get_ghost_grid_pos() + reltile
			if ROOT.get_node("World/Terrain").is_available_tile(globtile):
				global_selectable_area.append(globtile)
				
	func AoE_update(testreply):
		if (AoE_rotate):
			AoE = Vector2Array()
			for i in range(AoE_start.size()):
				var tmp = AoE_start[i].rotated(Vector2(0,1).angle_to(testreply-Sender.get_ghost_grid_pos()))
				if ROOT.get_node("World/Terrain").is_available_tile(tmp+testreply):
					AoE.push_back(tmp)

#-------------------------------------------------------------------------------------------

class SimpleAttackAction:

	extends AttackAction
	
	func _init(Char).(Char):
		pass
	
	func accept_reply(reply):
		Target = Vector2Array()
		for tile in AoE:
			Target.push_back(tile+reply)
		send_action()

	func execute():
		if (Sender.ALIVE):
			for char in ROOT.get_tree().get_nodes_in_group("Characters"):
				for tile in Target:
					if tile == char.get_grid_pos():
						print(str(char.get_name()," has been attacked"))
						print(str("starting HP at ",char.get_HP()))
						char.modify_HP(-Damage)
						print(str("Now HP at ",char.get_HP()))
						if (char.HP <= 0):
							char.ALIVE = false
							print("char ", char, " is dead")


#-------------------------------------------------------------------------------------------

class StandardAttack:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		Damage = 1
		AP_cost = 1
		AoE = Vector2Array([Vector2(0,0)])
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])

#-------------------------------------------------------------------------------------------

class Sweep:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		Damage = 1
		AP_cost = 3
		AoE_rotate = true
		AoE_start = Vector2Array([Vector2(0,0),Vector2(-1,-1),Vector2(1,-1)])
		AoE = AoE_start
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])

#-------------------------------------------------------------------------------------------

class Pierce:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		Damage = 2
		AP_cost = 3
		AoE_rotate = true
		AoE_start = Vector2Array([Vector2(0,0),Vector2(0,1),Vector2(0,2)])
		AoE = AoE_start
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])

#-------------------------------------------------------------------------------------------

class HammerDown:
	extends SimpleAttackAction
	
	func _init(Char).(Char):
		Damage = 4
		AP_cost = 3
		AoE_rotate = true
		AoE_start = Vector2Array([Vector2(0,0),Vector2(0,1),Vector2(0,2),Vector2(-1,1),Vector2(1,1)])
		AoE = AoE_start
		relative_selectable_area = Vector2Array([Vector2(0,1),Vector2(0,-1),Vector2(1,0),Vector2(-1,0)])
