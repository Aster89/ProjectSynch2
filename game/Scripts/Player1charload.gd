extends Node2D
# TODO: This script could contain other information about Player1 (the same is for Player2charload.gd),
# such as a Player1ActionList, and other char-independent-player-dependend variables...

var CHARS = ResourceLoader.load("res://Scripts/CharClassDefinition.gd")

func _ready():
	randomize()
	var minnchar = 4
	var maxnchar = 8
	var nchar = randi()%(maxnchar+1-minnchar)+minnchar
	for i in range(nchar):
		var s = CHARS.Lancer.new()
		s.TEAM = "P1"
		var positioned = false
		var newpos = null
		while !positioned :
			newpos = Vector2(randi()%10,randi()%20)
			positioned = true
			for kid in self.get_children():
				if newpos == kid.get_grid_pos() :
					positioned = false
		self.add_child(s)
		s.add_to_group("Characters")
		s.set_grid_pos(newpos)
		s.set_ghost_grid_pos(newpos)

	print(nchar," character have been generated")
