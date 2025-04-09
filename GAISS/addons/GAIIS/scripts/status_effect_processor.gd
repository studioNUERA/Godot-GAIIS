## The Status Effect Processor is instantiated 
## along with the application of status effects.
## It's purpose is to process the tick-based effects.

class_name StatusEffectProcessor extends Node

signal stack_changed(new_amount : int, processor : StatusEffectProcessor)
signal effect_finished(processor : StatusEffectProcessor)
signal cooldown_started(processor : StatusEffectProcessor)
signal cooldown_finished(processor : StatusEffectProcessor)

var status_effect : StatusEffectResource = null
var attribute_map : EntityAttributeMap = null

var over_time_mods : Array[EntityAttributeModifier]

var current_stack : int = 1
var stack_timers : Dictionary[int,float] = {}

var cooldown : float = 0.0
var cooling_down : bool = false

var tick_counter : int = 1

## 
func init_effect(_effect : StatusEffectResource, _map : EntityAttributeMap) -> void:
	#if !_effect or !_map:	return
	status_effect = _effect
	attribute_map = _map
	activate()

## 
func activate() -> void:
	GlobalTickTimer.tick.connect(_on_tick)
	
	if status_effect.attribute_modifiers.keys().size() == 0:
		return
	
	var mods : Dictionary[StatusEffectResource.APPLY_TYPES,EntityModifierCollection] = status_effect.attribute_modifiers
	for key in mods.keys():
		match key:
			0: # Over-Time
				for _m : EntityAttributeModifier in mods[key].modifiers:
					over_time_mods.append(_m)
			1: # Initial
				for _m : EntityAttributeModifier in mods[key].modifiers:
					var att_to_mod = _m.attribute_to_mod
					attribute_map.apply_modifier(att_to_mod, _m)
	stack_timers[0] = status_effect.effect_duration


func _physics_process(delta: float) -> void:
	if !cooling_down:
		if stack_timers.size() > 0:
			for key in stack_timers.keys():
				stack_timers[key] -= delta
				if stack_timers[key] <= 0.0:
					stack_timers.erase(key)
					take_from_stack()
		else:
			if status_effect is AffixStatusEffect:
				status_effect.effect_on_cooldown = true
				cooldown = status_effect.effect_cooldown_duration
				cooling_down = true
				cooldown_started.emit(self)
			else:
				effect_finished.emit(self)
				queue_free()
	
	if status_effect is AffixStatusEffect and status_effect.effect_on_cooldown:
		if cooldown > 0.0:
			cooldown -= delta
		else:
			cooldown_finished.emit(self)
			queue_free()


## 
func add_to_stack() -> void:
	current_stack += 1
	stack_timers[stack_timers.keys().size()] = status_effect.effect_duration
	
	var mods : Dictionary[StatusEffectResource.APPLY_TYPES,EntityModifierCollection] = status_effect.attribute_modifiers
	for key in mods.keys():
		if key == 1: #Initial
			for _m : EntityAttributeModifier in mods[key].modifiers:
				var att_to_mod = _m.attribute_to_mod
				attribute_map.apply_modifier(att_to_mod, _m)
	
	stack_changed.emit(current_stack, self)

## 
func take_from_stack() -> void:
	current_stack -= 1
	
	var mods : Dictionary[StatusEffectResource.APPLY_TYPES,EntityModifierCollection] = status_effect.attribute_modifiers
	for key in mods.keys():
		if key == 1: #Initial
			for _m : EntityAttributeModifier in mods[key].modifiers:
				var att_to_mod = _m.attribute_to_mod
				attribute_map.remove_modifier(att_to_mod, _m)
	
	stack_changed.emit(current_stack, self)

## 
func wipe_stack() -> void:
	for i in range(current_stack):
		take_from_stack()
	effect_finished.emit(self)
	queue_free()

## 
func _on_tick():
	for mod in over_time_mods:
		if status_effect.tick_delay > 0:
			if tick_counter < status_effect.tick_delay:
				tick_counter += 1
				print(tick_counter)
				continue
		
		var new_amount : float = mod.modifier_amount * current_stack
		var _m : EntityAttributeModifier = mod.duplicate()
		_m.modifier_amount = new_amount
		attribute_map.apply_modifier(
			attribute_map.get_attribute_name(_m.attribute_to_mod.attribute_name),
			_m
		)
		tick_counter = 1
		print(tick_counter)
