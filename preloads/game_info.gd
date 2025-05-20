extends Node

var killer_players = []
var surviver_players = []
var spectator_players = []

func role(id):
	if killer_players.has(id): return "Killer"
	elif surviver_players.has(id): return "Survivor"
	elif spectator_players.has(id): return "Spectator"
	else: return null

#Lazy lol
func server_update():
	update_all.rpc(killer_players,surviver_players,spectator_players)

@rpc("authority","call_remote","reliable")
func update_all(ki,su,sp):
	killer_players = ki
	surviver_players = su
	spectator_players = sp
