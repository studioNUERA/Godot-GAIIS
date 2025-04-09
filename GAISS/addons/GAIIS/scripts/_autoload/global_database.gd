extends Node

const STATUS_EFFECTS_PATH : String = "res://addons/GAIIS/example/status_effects/"
var STATUS_EFFECTS : Array = []

const ITEMS_PATH : String = "res://addons/GAIIS/example/items/"
var ITEMS : Array = []

func _enter_tree():
	STATUS_EFFECTS = load_from(STATUS_EFFECTS_PATH)
	ITEMS = load_from(ITEMS_PATH)

func get_statuseffect_by_name(_name : String) -> StatusEffectResource:
	for se in STATUS_EFFECTS:
		if se.effect_name == _name:
			return se
	return null

func get_item_by_name(_name : String) -> ItemResource:
	for i in ITEMS:
		if i.item_name == _name:
			return i
	return null


func load_from(_path : String) -> Array:
	var res : Array = []
	var dir := DirAccess.open(_path)
	
	if dir == null:
		return res
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var res_path = _path.path_join(file_name)
			var r = ResourceLoader.load(res_path)
			if r:
				res.append(r)
		file_name = dir.get_next()
		
	dir.list_dir_end()
	return res
