extends Node

## Signal emitted that status effects use to apply over-time modifiers.
signal tick()

## Time between ticks in seconds.
const tick_time : float = 0.2

## Global timer used to emit the tick signal.
var tick_timer : Timer = null



func _enter_tree() -> void:
	tick_timer = Timer.new()
	tick_timer.timeout.connect(_on_timer_timeout)
	tick_timer.one_shot = false
	tick_timer.autostart = true
	tick_timer.wait_time = tick_time
	add_child(tick_timer)

func _on_timer_timeout() -> void:
	tick.emit()
