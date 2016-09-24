extends Camera2D

var CAMERA_SPEED = 70
var MIN_REACTIVE_LENGTH = Vector2(50,50)
var MAX_REACTIVE_LENGTH = Vector2(50,50)
onready var MAX_WORLD_SIZE = get_parent().WORLD_SIZE
var CAMERA_SIZE

func _ready():
	self.set_pos(get_viewport_rect().size/2)
	CAMERA_SIZE= get_viewport_rect().size
	MAX_REACTIVE_LENGTH=get_viewport_rect().size-MAX_REACTIVE_LENGTH
	set_process(true)
	set_process_input(true)

func _process(delta):
	var MPOS = get_viewport().get_mouse_pos()
	if (MPOS.x < MIN_REACTIVE_LENGTH.x and MPOS.x > 5):
		var tmppos = get_pos()-Vector2(CAMERA_SPEED*delta,0)
		if (tmppos.x-CAMERA_SIZE.x/2 < 0):
			tmppos.x = CAMERA_SIZE.x/2
		set_pos(tmppos)
	
	if (MPOS.y < MIN_REACTIVE_LENGTH.y):
		var tmppos
		tmppos = get_pos()-Vector2(0,CAMERA_SPEED*delta)
		if ( tmppos.y-CAMERA_SIZE.y/2 < 0):
			tmppos.y = CAMERA_SIZE.y/2
		set_pos(tmppos)
	
	if (MPOS.x > MAX_REACTIVE_LENGTH.x):
		var tmppos
		tmppos = get_pos()+Vector2(CAMERA_SPEED*delta,0)
		if ( tmppos.x+CAMERA_SIZE.x/2 > MAX_WORLD_SIZE.x):
			tmppos.x = MAX_WORLD_SIZE.x-CAMERA_SIZE.x/2
		set_pos(tmppos)
	
	if (MPOS.y > MAX_REACTIVE_LENGTH.y):
		var tmppos = get_pos()+Vector2(0,CAMERA_SPEED*delta)
		if ( tmppos.y+CAMERA_SIZE.y/2 > MAX_WORLD_SIZE.y):
			tmppos.y = MAX_WORLD_SIZE.y-CAMERA_SIZE.y/2
		set_pos(tmppos)

func set_camera(pos):
	if (pos.x-CAMERA_SIZE.x/2 < 0):
		pos.x = CAMERA_SIZE.x/2
	elif(pos.x+CAMERA_SIZE.x/2>MAX_WORLD_SIZE.x):
		pos.x = MAX_WORLD_SIZE.x-CAMERA_SIZE.x/2
	if (pos.y-CAMERA_SIZE.y/2 < 0):
		pos.y = CAMERA_SIZE.y/2
	elif (pos.y+CAMERA_SIZE.y/2>MAX_WORLD_SIZE.y):
		pos.y = MAX_WORLD_SIZE.y-CAMERA_SIZE.y/2
	self.set_pos(pos)
