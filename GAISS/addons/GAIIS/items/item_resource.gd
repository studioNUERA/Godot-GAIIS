## Base class for Items.
## Use [ActiveItemResource], [PassiveItemResource] or
## [EquipmentItemResource] when making items.

class_name ItemResource extends Resource


## Unique name of the item. Should be all lowercase 
## and have underscores [code]_[/code] in place of spaces.
@export var item_name : StringName = ""
## The name displayed within UI elements.
## This name can have spaces, capitalization and apostrophes.
@export var item_display_name : String = ""
## Item in-game description/summary.
@export_multiline var item_description : String = ""

enum ItemRarities {
	Common,
	Rare,
	Epic,
	Legend,
	Equipment
}
## Item rarity.
@export var item_rarity : ItemRarities = ItemRarities.Common

## Attribute modifiers to be applied to the aqquiring entities attribute map.
@export var attribute_modifiers : Array[EntityAttributeModifier]

## The custom 
@export var item_custom_logic : Script

## If an item can stack, its modifiers
## can be applied more than once.
@export var item_can_stack : bool = false

## if [code] item_can_stack = true [/code] and [code]max_stack <= 1[/code],
## the item can stack infintely.
@export var item_max_stack : int = 1

# The current stack amount for the item. This is taken 
# into account when applying modifiers. 
var item_current_stack : int = 1

enum EffectScaleTypes {
	Linear,
	
	## When an item stacks, it will grant less and less
	## of it's effect value.[br]
	## See the [ScalingUtil] class.
	Hyperbolic
}
@export var effect_scale_type : EffectScaleTypes = EffectScaleTypes.Linear

## Icon for UI display.
@export var item_icon : Texture
