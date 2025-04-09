@icon("res://addons/GAIIS/icons/status_effects.svg")

## Base class of all status effects.
## Use this Resource if not creating an Affix Buff.

class_name StatusEffectResource extends Resource

@export_group("Effect")
# Buffs/Debuffs are a flat change in an attributes values
# while Affixes are a type of buff that also provide some 
# weapon/character altering logic.
enum EFFECT_TYPES {
	## Flat increase in an attribute's value.
	Buff,
	## A buff + weapon/character logic.
	Affix,
	## Flat decrease in an attribute's value.
	Debuff
}
@export var effect_type : EFFECT_TYPES = EFFECT_TYPES.Buff
@export var effect_name : StringName = ""
@export var effect_display_name : String = ""
@export_multiline var effect_description : String = ""
@export var effect_icon : Texture

enum APPLY_TYPES {
	OverTime,
	Initial
}
## Since nested dictionary types are not supported:
## The values of dictionary keys MUST be of type EntityAttributeModifier
@export var attribute_modifiers : Dictionary[APPLY_TYPES, EntityModifierCollection]

## Can the effect be applied multiple times to the same entity?
@export var effect_can_stack : bool = true

@export_group("Lifetime")
## How long the effect lasts on the entity.
@export var effect_duration : float = 10.0

## The amount of ticks before the status effect
## happens.[br]
## Ex. A value of 5 = 1.0 second. A tick is 0.2 seconds:
## 0.2 * 5 = 1.0[br]
## Ex. Value = 15.0 (0.2 * 15 = 3.0s)
@export var tick_delay : int = 0
