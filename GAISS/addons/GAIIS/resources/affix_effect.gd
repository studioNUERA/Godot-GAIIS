## Affix buffs are buffs [i]only[/i] applied to enemy entity types.
## Theoretically, these could be assigned to a player character,
## but may not be useful in a single-player game. 
## Affixes add logic to the entity in the form of new attacks,
## AoE type effects, etc.

class_name AffixStatusEffect extends StatusEffectResource


## Only required for [b]Affix Buffs[/b].
## The amount of time (seconds) until the effect can be applied again.
@export var effect_cooldown_duration : float = 5.0
var effect_on_cooldown : bool = false
