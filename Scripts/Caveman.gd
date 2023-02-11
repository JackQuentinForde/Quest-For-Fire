extends KinematicBody2D

onready var _animation_player = $AnimationPlayer
onready var _player = get_node("../Player")

const GRAVITY = 600
const GROUND_ACCEL = 5
const AIR_ACCEL = 2.5
const WALK_SPEED = 50
const JUMP_VELOCITY = 100
const MAX_JUMP_TIME = 0.15
const MAX_WALK_TIME = 0.25
const MAX_WAIT_TIME = 1
const MAX_DIST_TO_PLAYER = 11
const JUMP_GRACE_PERIOD = 0.045

enum {
	IDLE,
	RUN, 
	JUMP,
	FALL
}

var right
var left
var lastDirection
var jump

var velocity = Vector2()
var moveTime = 0
var waitTime = 0
var jumpTime = 0
var fallTime = 0

var state
var anim
var new_anim

var following = false

func _ready():
	change_state(IDLE)
	
func _process(delta):
	ai_logic(delta)
	jump_logic(delta)
	move()
	determine_state()
	animate()
	
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
func ai_logic(var delta):
	following = _player.holdingTorch
	
	if (!following):
		idle_logic(delta)
	else:
		follow_logic()

func idle_logic(var delta):
	if (waitTime < MAX_WAIT_TIME):
		waitTime += delta
	elif (!left and !right):
		if (lastDirection == "l"):
			left = true
		else:
			right = true
	else:
		moveTime += delta
			
		if (is_on_wall()):
			left = !left
			right = !right
			
		if (moveTime >= MAX_WALK_TIME):
			moveTime = 0
			waitTime = 0
			if (left):
				lastDirection = "l"
			else:
				lastDirection = "r"
			left = false
			right = false

func follow_logic():
	var playerPos = _player.get_position()
	var distToPlayer = position.distance_to(playerPos)
	if (distToPlayer >= MAX_DIST_TO_PLAYER):
		if (position.x > playerPos.x):
			left = true
			right = false
		else:
			right = true
			left = false
			
		if (is_on_wall()):
			jump = true
			if (is_on_floor()):
				jumpTime = 0
	else:
		left = false
		right = false

func jump_logic(var delta):
	if (jump):
		if (jumpTime < MAX_JUMP_TIME):
			velocity.y = -JUMP_VELOCITY
			jumpTime += delta
		else:
			jump = false
	elif (!jump and !is_on_floor()):
		if (fallTime < JUMP_GRACE_PERIOD):
			fallTime += delta
		else:
			jumpTime = MAX_JUMP_TIME
	else:
		jumpTime = 0
		fallTime = 0
		
func move():
	var accel
			
	if (state == JUMP):
		accel = AIR_ACCEL
	else:
		accel = GROUND_ACCEL
	
	if (right and !left):
		if (velocity.x < WALK_SPEED):
			velocity.x += accel
			if (velocity.x > WALK_SPEED):
				velocity.x = WALK_SPEED
		elif (velocity.x > WALK_SPEED):
			velocity.x -= accel
			if (velocity.x < WALK_SPEED):
				velocity.x = WALK_SPEED
			
		get_node("Sprite").flip_h = false
			
	elif (left and !right):
		if (velocity.x > -WALK_SPEED):
			velocity.x -= accel
			if (velocity.x < -WALK_SPEED):
				velocity.x = -WALK_SPEED
		elif (velocity.x < -WALK_SPEED):
			velocity.x += accel
			if (velocity.x > -WALK_SPEED):
				velocity.x = -WALK_SPEED
			
		get_node("Sprite").flip_h = true
			
	else:
		if (velocity.x > 0):
			velocity.x -= accel
			if (velocity.x < 0):
				velocity.x = 0
		elif (velocity.x < 0):
			velocity.x += accel
			if (velocity.x > 0):
				velocity.x = 0
				
func determine_state():
	if (!is_on_floor()):
		if (velocity.y < 0):
			change_state(JUMP)
		else:
			change_state(FALL)
	else:
		if (velocity.x != 0):
			change_state(RUN)
		else:
			change_state(IDLE)
				
func animate():
	if (new_anim != anim):
		anim = new_anim
		_animation_player.stop()
		
	if !_animation_player.is_playing():	
		_animation_player.play(anim)
	
func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			new_anim = 'idle'
		RUN:
			new_anim = 'run'
		JUMP:
			new_anim = 'jump'
		FALL:
			new_anim = 'fall'
