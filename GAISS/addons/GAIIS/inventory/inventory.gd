## The [b]Inventory[/b] node handles the storing, 
## adding and removing of items - as well as applying 
## the modifiers along with them.
## This node is [b][i]required[/i][/b] in order to 
## work along with the item system.
@icon("res://addons/GAIIS/icons/inventory_node_icon.svg")
class_name InventoryObject extends Node

## Emitted when an item is added to the inventory. Either new
## or stacking on existing.
signal item_added(_item : ItemResource)
## Emitted when an item is removed from the inventory.
## This counts for a stack being reduced, or completely wiped.
signal item_removed(_item : ItemResource)
## Only emitted if the newly aqquired item is an equipment item.
signal equipment_item_added(_item : ItemResource)

@export_group("Required", "r_")
## The entities attribute map.
@export var r_attribute_map : EntityAttributeMap

## Array of items.
@export var inventory_items : Array[ItemResource]
## Current equipment item.
@export var equipment_item : EquipmentItemResource


###### DEBUG ######
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		add_item(load("res://addons/GAIIS/example/items/ac_item_batwing.tres"))
###### DEBUG ######


func _enter_tree() -> void:
	if !r_attribute_map:
		push_error("No Attribute Map found: ", self.name)


## Returns item resource by name from inventory.
## Does not return equipment items.
func get_item_name(_name : StringName) -> ItemResource:
	for item in inventory_items:
		if item.item_name == _name:
			return item
	
	return null

## Returns true if the item is found in the inventory.
func has_item(_item : ItemResource) -> bool:
	if inventory_items.has(_item):
		return true
	return false

## Looks for the item in the inventory before adding a new one.
## If the item exists already, check for the stack size and +1 to its stack.
## Items with max stacks of 0 can infinitly stack, otherwise attributes stop 
## being recalculated.
func add_item(_item : ItemResource) -> void:
	var found : ItemResource = get_item_name(_item.item_name)
	if found:
		#If the item can be stacked, calculate the modifiers.
		if found.item_can_stack:
			if found.item_max_stack <= 1:
				calculate_modifiers(found.attribute_modifiers)
			else:
				if found.item_can_stack and found.item_current_stack < found.item_max_stack:
					calculate_modifiers(found.attribute_modifiers)
				else:
					return
		found.item_current_stack += 1
		emit_signal("item_added", found)
		return
	
	# EQUIPMENT #
	# Check if the new item is an equipment item. 
	if _item is EquipmentItemResource:
		# If the inventory already holds the equipment item, return.
		if equipment_item:
			if _item.item_name == equipment_item.item_name:
				return
		
		# Unique copy for my own sanity
		var _i : ItemResource = _item.duplicate()
		if equipment_item:
			#TODO: Switch equipment logic
			pass
		else:
			equipment_item = _i
		emit_signal("equipment_item_added", _i)
		return
	#EQUIPMENT
	
	# Making a unique copy of the new item.
	var _i : ItemResource = _item.duplicate()
	inventory_items.append(_i)
	if _i.item_rarity != _i.ItemRarities.Equipment:
		calculate_modifiers(_i.attribute_modifiers)
	emit_signal("item_added", _i)

## TODO
func remove_item() -> void:
	pass

## Takes an array of EntityAttributeModifiers,
## loops through them and applies them via the EntityAttributeMap.
func calculate_modifiers(modifiers : Array[EntityAttributeModifier]) -> void:
	if modifiers.size() == 0:
		return
	for mod in modifiers:
		r_attribute_map.apply_modifier(
			r_attribute_map.get_attribute_name(mod.attribute_to_mod.attribute_name),
			mod
		)
