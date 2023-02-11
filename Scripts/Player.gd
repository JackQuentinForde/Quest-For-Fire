extends KinematicBody2D

onready var _animation_player = $AnimationPlayer
onready var _fire = get_node("../Fire2")

const GRAVITY = 600
const GROUND_ACCEL = 5
const AIR_ACCEL = 2.5
const WALK_SPEED = 50
const JUMP_VELOCITY = 100
const MAX_JUMP_TIME = 0.15
const JUMP_GRACE_PERIOD = 0.045
const MAX_FIRE_DIST = 160

enum {
	IDLE,
	RUN, 
	JUMP,
	FALL
}

var right
var left
var jump

var velocity = Vector2()
var jumpTime = 0
var fallTime = 0

var state
var anim
var new_anim

var lookDirection = Vector2(1, 0)

var holdingTorch = false

func _ready():
	change_state(IDLE)

func _process(delta):
	get_input()
	jump_logic(delta)
	move()
	determine_state()
	animate()

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))

func change_state(new_state):
	state = new_state
	match state:
		IDLE:
			if (holdingTorch):
				new_anim = 'idle_torch'
			else:
				new_anim = 'idle'
		RUN:
			if (holdingTorch):
				new_anim = 'run_torch'
			else:
				new_anim = 'run'
		JUMP:
			if (holdingTorch):
				new_anim = 'jump_torch'
			else:
				new_anim = 'jump'
		FALL:
			if (holdingTorch):
				new_anim = 'fall_torch'
			else:
				new_anim = 'fall'

func get_input():
	right = Input.is_action_pressed('player_right')
	left = Input.is_action_pressed('player_left')
	jump = Input.is_action_pressed('player_jump')
				
func jump_logic(var delta):
	if (jump):
		if (jumpTime < MAX_JUMP_TIME):
			velocity.y = -JUMP_VELOCITY
			jumpTime += delta
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
		
		lookDirection = Vector2(1, 0)
		
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
		
		lookDirection = Vector2(-1, 0)
		
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
	
	
