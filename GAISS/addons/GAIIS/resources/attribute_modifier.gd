class_name EntityAttributeModifier extends Resource

enum ModifierTypes {
	Debuff,
	Buff
}
## Type of modifier.
@export var modifier_type : ModifierTypes = ModifierTypes.Debuff

## Attribute to modify.
@export var attribute_to_mod : EntityAttribute

enum ValueTypes {
	Current = 0,
	Max = 1
}
@export var value_to_alter : ValueTypes = ValueTypes.Current

## Modifier amount.
@export var modifier_amount : float = 0.0

## Tracks original value for the attribute.
var original_value : float = 0.0
