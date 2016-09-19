extends Control

onready var ActDef = get_node("/root/ActionClassDefinition")

func menu_generate(active_hero):
	var ACTIVE_CHAR = get_tree().get_root().get_node("World").ACTIVE_CHAR
	var avail_actions = active_hero.get_avail_actions()
	for i in range(avail_actions.size()) :
		var s = Button.new()
		s.set_pos(Vector2(0,i*30))
		s.set_size(Vector2(120,30))
		s.set_text(avail_actions[i])
		s.set_name(avail_actions[i])
		var linked_action = ActDef.createaction(avail_actions[i],ACTIVE_CHAR)
		#linked_action.set_name("action")
		#s.add_child(linked_action)
		s.connect("pressed",linked_action,"setup")
		if (ACTIVE_CHAR.get_AP() < linked_action.AP_cost):
			s.set_disabled(true)
		self.add_child(s)

func menu_update():
	for button in self.get_children():
		if (get_tree().get_root().get_node("World").ACTIVE_CHAR.get_AP() < button.get_node("action").AP_cost):
			button.set_disabled(true)
