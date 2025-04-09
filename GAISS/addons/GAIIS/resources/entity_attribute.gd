class_name EntityAttribute extends Resource

## Unique name for the attribute used for lookup.
@export var attribute_name : StringName = ""

## Enable this for stats like "Health" where 
## a max value is needed.
@export var has_max : bool = false

var min_value : float = 0.0
var current_value : float = 0.0
var max_value : float = 0.0
