extends Node

var currentTurn = 1

func matrix_init(nrow,ncol,fill):
	var M = {}
	for i in range(nrow):
		for j in range(ncol):
			M[Vector2(i,j)]=fill
	return M

func get_current_turn():
	return currentTurn
