extends AnimatedSprite

onready var _player = get_node("../Player")

const MAX_PLAYER_DIST = 12

var torch

func _process(_delta):
	torch = Input.is_action_pressed('player_torch')
	torch_logic()

func torch_logic():
	if (torch and self.position.distance_to(_player.position) < MAX_PLAYER_DIST):
		if (self.animation.get_basename() == "burn"):
			_player.holdingTorch = true
		elif (_player.holdingTorch):
			self.play("burn")
