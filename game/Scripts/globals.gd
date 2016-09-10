extends Node

# trying message and description
var currentTurn = 1

func matrix_init(nrow,ncol,fill):
	var M = {}
	for i in range(nrow):
		for j in range(ncol):
			M[Vector2(i,j)] = fill
	M[Vector2(10,10)] = 2
	return M

func get_current_turn():
	return currentTurn
