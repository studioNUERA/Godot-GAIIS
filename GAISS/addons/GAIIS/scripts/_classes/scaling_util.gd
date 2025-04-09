class_name ScalingUtil


static func hyperbolic(base_value : float, stack : int, coefficient : float) -> float:
	if stack <= 1:
		return 0.0
	return base_value * (1.0 - (1.0 / (1.0 + coefficient * (stack - 1))))

static func linear(base_value : float, per_stack_amount : float, stack : int) -> float:
	return base_value + per_stack_amount * (stack - 1)
