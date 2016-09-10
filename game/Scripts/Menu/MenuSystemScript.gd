extends Control

onready var MenuList = { "MainMenu" : get_node("ActionSelectionMainMenu"),
	"ActionMenu" : get_node("ActionMenu")}
onready var currentMenu = MenuList.MainMenu
onready var currentmenupath = Array(["MainMenu"])


func _ready():
	pass

func menu_hide():
	currentMenu.hide()

func reset():
	currentMenu.hide()
	for child in MenuList.ActionMenu.get_children():
		child.free()

func menu_generate():
	MenuList.ActionMenu.menu_generate(get_tree().get_root().get_node("World").ACTIVE_CHAR)

func menu_load(menuname):
	currentMenu.hide()
	currentMenu = MenuList[menuname]
	#if (menuname == "ActionMenu"):
	#	MenuList.ActionMenu.menu_update()
	currentMenu.show()
	if currentmenupath[currentmenupath.size()-1]!=menuname:
		currentmenupath.append(menuname)
