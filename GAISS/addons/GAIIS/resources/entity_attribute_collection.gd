class_name EntityModifierCollection extends Resource

#
# Unfortunately nested dictionary types are not supported.
# This resource acts as a wrapper so to avoid ambiguity 
# when assigning attributes/modifiers in the inspector. 
#

## Array of [b]EntityAttributeModifier[/b].
@export var modifiers : Array[EntityAttributeModifier]
