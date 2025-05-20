extends PlayerDetector
class_name StandInteract

signal is_pressed()
signal is_held()
signal is_released()

func _ready():
	super()
	player_entered.connect(on_player_entered)
	player_exited.connect(on_player_exited)

func on_player_entered(player):
	player.interactor.add_interact(self)

func on_player_exited(player):
	player.interactor.remove_interact(self)

@rpc("any_peer","call_local","reliable")
func pressed():
	is_pressed.emit()

@rpc("any_peer","call_local","reliable")
func held():
	is_held.emit()

@rpc("any_peer","call_local","reliable")
func released():
	is_released.emit()
