extends Node


const CONFIG_PATH = "res://config/config.cfg"
var config = ConfigFile.new()


func _ready() -> void:
	load_keys()


func save_keys() -> void:
	for action in InputMap.get_actions():
		# skip builtin
		if action.begins_with("ui_"):
			continue
		
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			var event = events[0]
			if event is InputEventKey:
				var key = event.physical_keycode if event.physical_keycode != 0 else event.keycode
				config.set_value("keys", action, key)
	
	config.save(CONFIG_PATH)


func load_keys() -> void:
	if config.load(CONFIG_PATH) != OK:
		save_keys()
		return
	
	for action in config.get_section_keys("keys"):
		var keycode = config.get_value("keys", action)
		rebind_key(action, keycode)


func rebind_key(action: String, keycode: int) -> void:
	InputMap.action_erase_events(action)

	var event = InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)


func get_key(action: String) -> int:
	var events = InputMap.action_get_events(action)
	if events.size() > 0 and events[0] is InputEventKey:
		var event = events[0]
		return event.physical_keycode if event.physical_keycode != 0 else event.keycode
	return 0
