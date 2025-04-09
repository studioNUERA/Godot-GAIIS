## The core of the attribute system.
## This node is required on any entity that utilizes attributes,
## status effects, or modifiers.
@icon("res://addons/GAIIS/icons/attribute_map_icon.svg")
class_name EntityAttributeMap extends Node

## Emitted when [code]EntityAttributeMap[/code] is initialized.
signal map_initialized(_attributes : Array[EntityAttributeData])
## Emitted when a [code]EntityAttribute[/code] changes its value.
signal attribute_changed(_attribute : EntityAttribute, _new_value : float)
## Emitted when a [code]EntityAttributeModifier[/code] is applied
## to the [code]EntityAttributeMap[/code].
signal modifier_applied(_attribute : EntityAttribute, _modifier : EntityAttributeModifier)
## Emitted when a [code]EntityAttributeModifier[/code] is removed 
## from the [code]EntityAttributeMap[/code]
signal modifier_removed(_attribute : EntityAttribute, _modifier : EntityAttributeModifier)
## Emitted when a [code]StatusEffectResource[/code] is applied 
## to the [code]EntityAttributeMap[/code].
signal status_effect_applied(_effect : StatusEffectResource, _processor : StatusEffectProcessor)
## Emitted when a [code]StatusEffectResource[/code] is 
## removed from the [code]EntityAttributeMap[/code]
signal status_effect_removed

## [b]Required[/b][br]
## [code]AttributeMapConfiguration[/code] object used to store 
## and process changes in [code]EntityAttributeResource[/code]'s.
@export var map_config : AttributeMapConfiguration

@export_group("Status Effects", "se_")
## Where the proccessors will be placed upon initialization.
@export var se_processor_holder : Node
## The script that will be instanced with the status effect.
## Handles VFX processing and modifier calculation.
var se_processor_script : Script = preload("res://addons/GAIIS/scripts/status_effect_processor.gd")


## Initialize all attributes in the list.
## This takes the default values on [b]EntityAttributeData[/b]
## objects and applies them to the [b]EntityAttributeResource[/b].
func init_attributes() -> void:
	for att : EntityAttributeData in map_config.attributes:
		att.attribute = att.attribute.duplicate()
		att.attribute.min_value = att.min_value
		att.attribute.max_value = att.max_value
		att.attribute.current_value = att.current_value
	emit_signal("map_initialized", map_config.attributes)

func _enter_tree() -> void:
	# Initialize the attribute map.
	init_attributes()

## Returns an attribute by name. Returns null if not found.
func get_attribute_name(_name : StringName) -> EntityAttribute:
	for att in map_config.attributes:
		if att.attribute.attribute_name == _name:
			return att.attribute
	
	return null

## Returns the current value of a given attribute.
func get_attribute_value(_attribute : EntityAttribute) -> float:
	var att = get_attribute_name(_attribute.attribute_name)
	if att:
		return att.current_value
	return -1.0


func reduce_attribute_value(_attribute : EntityAttribute, _amount : float, _value_to_alter : int = 0) -> void:
	var att = get_attribute_name(_attribute.attribute_name)
	
	match _value_to_alter:
		0: # CURRENT VALUE
			if (att.current_value - _amount) < att.min_value:
				att.current_value = 0
			else:
				att.current_value -= _amount
			emit_signal("attribute_changed", att, att.current_value)
		1: # MAX VALUE 
			if (att.max_value - _amount) > 0:
				att.max_value -= _amount
				if att.current_value > att.max_value:
					att.current_value = att.max_value
			else:
				att.max_value = 0
				att.current_value = 0
			emit_signal("attribute_changed", att, att.max_value)


func increase_attribute_value(_attribute : EntityAttribute, _amount : float, _value_to_alter : int = 0) -> void:
	var att = get_attribute_name(_attribute.attribute_name)
	
	match _value_to_alter:
		0: # CURRENT VALUE
			if att.has_max:
				if (att.current_value + _amount) > att.max_value:
					att.current_value = att.max_value
			else:
				att.current_value += _amount
			emit_signal("attribute_changed", att, att.current_value)
		1: # MAX VALUE
			att.max_value += _amount
			emit_signal("attribute_changed", att, att.max_value)


## Apply a modifier to an attribute.
func apply_modifier(_attribute : EntityAttribute, _modifier : EntityAttributeModifier):
	var att = get_attribute_name(_attribute.attribute_name)
	if att:
		match _modifier.modifier_type:
			EntityAttributeModifier.ModifierTypes.Debuff:
				reduce_attribute_value(_attribute, _modifier.modifier_amount)
			EntityAttributeModifier.ModifierTypes.Buff:
				increase_attribute_value(_attribute, _modifier.modifier_amount)
		emit_signal("modifier_applied", _attribute, _modifier)

## Remove a modifier from an attribute.
## If [b]_calculate[/b] = true, recalculate the attributes values.
## Recalculate if modifiers only have temporary effects.
func remove_modifier(_attribute : EntityAttribute, _modifier : EntityAttributeModifier, _calculate : bool = true):
	var att = get_attribute_name(_attribute.attribute_name)
	if att:
		if _calculate:
			match _modifier.modifier_type:
				EntityAttributeModifier.ModifierTypes.Debuff:
					increase_attribute_value(_attribute, _modifier.modifier_amount)
				
				EntityAttributeModifier.ModifierTypes.Buff:
					reduce_attribute_value(_attribute, _modifier.modifier_amount)
		emit_signal("modifier_removed", _attribute, _modifier)


## Check for an active status effect. Returns null if none found.
func get_active_status_effect(_effect : StatusEffectResource) -> StatusEffectProcessor:
	if !_effect: return
	
	for se_proc : StatusEffectProcessor in se_processor_holder.get_children():
		if _effect.effect_name == se_proc.status_effect.effect_name:
			return se_proc
	return null

## Apply a status effect.
## If the effect exists, and can stack, the stack will increase
## and the status_effect_processor will calculate the values.
## If it does not exist, create a new node with the status effect attached.
func apply_status_effect(_effect : StatusEffectResource) -> void:
	if !_effect: return
	
	var found : StatusEffectProcessor = get_active_status_effect(_effect)
	if found:
		if _effect.effect_can_stack:
			found.add_to_stack()
			emit_signal("status_effect_applied", _effect, found)
		return
	
	# If it's a new effect, create a new processor
	var _node = Node.new()
	_node.set_script(se_processor_script)
	_node.name = "se_" + _effect.effect_name
	_node.init_effect(_effect.duplicate(), self)
	se_processor_holder.add_child(_node) if se_processor_holder else add_child(_node)
	emit_signal("status_effect_applied", _effect, _node)

## Removes a status effect along with it's stack. 
## Removes initial modifiers along with it.
func remove_status_effect(_effect : StatusEffectResource) -> void:
	var found : StatusEffectProcessor = get_active_status_effect(_effect)
	if found:
		found.wipe_stack()
	emit_signal("status_effect_removed")


### Signals ### 
