extends Node

@onready var input: AudioStreamPlayer = $Input
@export var output :AudioStreamPlayer3D

var idx : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback

func _ready():
	output.play()
	playback = output.get_stream_playback()
	#tool
	#input.stream = AudioStreamMicrophone.new()
	#input.play()
	#idx = AudioServer.get_bus_index("VoiceIn")
	#effect = AudioServer.get_bus_effect(idx, 0)

func _on_owner_updated():
	# we only want to initalize the mic for the peer using it
	if (is_multiplayer_authority()):
		input.stream = AudioStreamMicrophone.new()
		input.play()
		idx = AudioServer.get_bus_index("VoiceIn")
		effect = AudioServer.get_bus_effect(idx, 0)
		# replace 0 with whatever index the capture effect is

func _process(delta: float) -> void:
	if (not is_multiplayer_authority()): return
	if Settings.voice_type == Settings.VoiceType.OFF: return
	input.volume_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("VoiceIn"))
	if Settings.voice_type == Settings.VoiceType.PUSH_TO_TALK and not Input.is_action_pressed("PushToTalk"): return
	if (effect.can_get_buffer(256) && playback.can_push_buffer(256)):
		#fill_buffer()
		send_data.rpc(effect.get_buffer(256))
		#send_data(effect.get_buffer(512))
	effect.clear_buffer()

# if not "call_remote," then the player will hear their own voice
# also don't try and do "unreliable_ordered." didn't work from my experience
@rpc("any_peer", "call_remote", "reliable")
func send_data(data : PackedVector2Array):
	for i in range(0,256):
		playback.push_frame(data[i])
	#playback.push_buffer(data)
