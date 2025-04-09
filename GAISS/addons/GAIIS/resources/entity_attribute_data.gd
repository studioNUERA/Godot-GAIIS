class_name EntityAttributeData extends Resource

@export var attribute : EntityAttribute

@export_group("Default Values")
@export var min_value : float = 0.0
## Only relevant if [code]has_max = true[/code] 
## on the [EntityAttribute] itself.
@export var max_value : float = 0.0
@export var current_value : float = 0.0
