extends Node

# --- Constants ---
const PORT = 9999              # Game connection port
const LAN_PORT = 9991          # Server browser discovery port
const DEFAULT_IP = "localhost" # Localhost
const BROADCAST_ADDRESS = "127.255.255.255"

# --- Local Player State ---
var player_name: String = "Commander" # Set this from Menu UI before hosting/joining
var server_name: String = "RTS Match"    # Set this from Menu UI before hosting
var local_faction: int = -1            # Assigned by server (0-9). -1 is NPC/Neutral.

# --- Global Match State ---
var players = {}  # { "peer_id": {"name": "str", "faction": int} }
var alliances = [] # 2D Array: alliances[faction_index] = [list_of_allied_indices]

var server_settings = {
	"starting_resources": 500,
	"unit_cap": 50,
	"map_seed": 12345,
	"game_speed": 1.0
}

# --- Networking Tools ---
var udp_socket := PacketPeerUDP.new()
var broadcast_timer: Timer

func _ready():
	# Connect Network Signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connection_success)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	# Setup LAN Discovery Timer
	broadcast_timer = Timer.new()
	broadcast_timer.wait_time = 2.0 
	broadcast_timer.timeout.connect(_broadcast_presence)
	add_child(broadcast_timer)
	
	_reset_alliances()

func _reset_alliances():
	alliances = []
	for i in range(10): 
		alliances.append([])

# --- HOSTING & JOINING ---

func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 10) # 10 player max
	if error != OK:
		print("Failed to host: ", error)
		return
	
	multiplayer.multiplayer_peer = peer
	
	# Host setup: Always faction 0, Peer ID 1
	local_faction = 0
	players["1"] = {"name": player_name, "faction": 0}
	
	# Start LAN discovery
	udp_socket.set_broadcast_enabled(true)
	udp_socket.set_dest_address(BROADCAST_ADDRESS, LAN_PORT)
	broadcast_timer.start()
	
	load_game()

func join_game(address: String):
	stop_listening() # Stop browsing once we join
	if address.is_empty(): address = DEFAULT_IP
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error != OK:
		print("Failed to join: ", error)
		return
		
	multiplayer.multiplayer_peer = peer

# --- HANDSHAKE & SYNC ---

func _on_connection_success():
	# CLIENT: As soon as we connect, send our actual name to host
	register_player.rpc_id(1, player_name)
	load_game()

@rpc("any_peer", "call_remote", "reliable")
func register_player(chosen_name: String):
	# SERVER: Received a name from a client
	if multiplayer.is_server():
		var id = multiplayer.get_remote_sender_id()
		var assigned_faction = _get_next_available_faction()
		
		players[str(id)] = {"name": chosen_name, "faction": assigned_faction}
		
		# Update everyone with the new player list and alliances
		_sync_global_state()

func _on_peer_connected(id: int):
	# SERVER: Send gameplay settings to the specific new peer
	if multiplayer.is_server():
		sync_settings.rpc_id(id, JSON.stringify(server_settings))

func _sync_global_state():
	# SERVER: Push full player/alliance state to all connected peers
	update_all_clients.rpc(JSON.stringify(players), JSON.stringify(alliances))

@rpc("authority", "call_local", "reliable")
func update_all_clients(p_json: String, a_json: String):
	# ALL PEERS: Parse the updated state
	players = JSON.parse_string(p_json)
	alliances = JSON.parse_string(a_json)
	
	# Update local_faction based on unique network ID
	var my_id = str(multiplayer.get_unique_id())
	if players.has(my_id):
		local_faction = players[my_id]["faction"]

@rpc("authority", "call_remote", "reliable")
func sync_settings(s_json: String):
	# CLIENTS: Update local server_settings from host
	server_settings = JSON.parse_string(s_json)

# --- ALLIANCE LOGIC ---

func is_allied(faction_a: int, faction_b: int) -> bool:
	if faction_a == faction_b: return true
	if faction_a == -1 or faction_b == -1: return false # NPCs neutral
	return faction_b in alliances[faction_a]

func set_alliance(faction_a: int, faction_b: int, allied: bool):
	# Only the server can change diplomatic states
	if not multiplayer.is_server() or faction_a < 0 or faction_b < 0: return
	
	if allied:
		if not faction_b in alliances[faction_a]: alliances[faction_a].append(faction_b)
		if not faction_a in alliances[faction_b]: alliances[faction_b].append(faction_a)
	else:
		alliances[faction_a].erase(faction_b)
		alliances[faction_b].erase(faction_a)
	
	_sync_global_state()

# --- DISCONNECTION HANDLING ---

func _on_peer_disconnected(id: int):
	if multiplayer.is_server():
		players.erase(str(id))
		_sync_global_state()

func _on_server_disconnected():
	# Host left, kill the game
	_cleanup_and_exit()

func _on_connection_failed():
	_cleanup_and_exit()

func _cleanup_and_exit():
	multiplayer.multiplayer_peer = null
	players.clear()
	_reset_alliances()
	local_faction = -1
	broadcast_timer.stop()
	get_tree().change_scene_to_file("res://scenes/main_scenes/menu.tscn")

# --- LAN DISCOVERY ---

func _broadcast_presence():
	var info = {"name": server_name, "port": PORT, "count": players.size()}
	var packet = JSON.stringify(info).to_utf8_buffer()
	udp_socket.put_packet(packet)
	
	# ADDITIONAL STEP FOR ROBUSTNESS: 
	# Specifically target localhost (127.0.0.1) as well
	udp_socket.set_dest_address("127.0.0.1", LAN_PORT)
	udp_socket.put_packet(packet)
	
	# Reset destination back to broadcast for next loop
	udp_socket.set_dest_address(BROADCAST_ADDRESS, LAN_PORT)

func start_listening():
	if not udp_socket.is_bound():
		udp_socket.bind(LAN_PORT)

func stop_listening():
	udp_socket.close()

func get_discovered_servers() -> Array:
	var servers = []
	while udp_socket.get_available_packet_count() > 0:
		var data = JSON.parse_string(udp_socket.get_packet().get_string_from_utf8())
		if data:
			data["ip"] = udp_socket.get_packet_ip()
			servers.append(data)
	return servers

# --- HELPERS ---

func _get_next_available_faction() -> int:
	var used = []
	for p in players.values(): used.append(p["faction"])
	for i in range(10):
		if i not in used: return i
	return -1

func load_game():
	get_tree().change_scene_to_file("res://scenes/main_scenes/game.tscn")
