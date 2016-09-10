extends VBoxContainer

onready var ActDef = get_node("/root/ActionClassDefinition")

func _on_Move_pressed():
	var action = ActDef.MoveAction.new(get_node("/root/World").ACTIVE_CHAR)
	#action.setup(get_node("/root/World").ACTIVE_CHAR)

func _on_Action_pressed():
	get_parent().menu_load("ActionMenu")

func _on_End_Turn_pressed():
	get_node("/root/World").change_state("Action_Execution")
