extends Node

## Events:[br]
## Used across entities and other game objects.

#EX: emitted when an entity is hit
signal on_entity_hit(_hit_entity, _from_entity)
#EX: emitted when an entity is killed
signal on_entity_death(_dead_entity)
