use math;
use vec;

fn update(state: *state, time: u32) void = {
	if (state.last_time == 0) {
		state.last_time = time;
	};
	state.dt = time - state.last_time;
	state.last_time = time;

	const new_squibble_rect = state.squibble_rect;
	new_squibble_rect.x += state.dt: f64 * 0.2 * math::sinf64(state.squibble_dir);
	new_squibble_rect.y += state.dt: f64 * 0.2 * math::cosf64(state.squibble_dir);
	const viewport = vec::rect {
		x = 0.0,
		y = 0.0,
		w = state.width: f64,
		h = state.height: f64,
	};
	const xcontains = xcontains_rect_rect(&viewport, &new_squibble_rect);
	const ycontains = ycontains_rect_rect(&viewport, &new_squibble_rect);
	if (xcontains && ycontains) {
		state.squibble_rect = new_squibble_rect;
	} else {
		if (!xcontains) {
			state.squibble_dir = 2.0 * math::PI - state.squibble_dir;
		} else {
			state.squibble_dir = 1.0 * math::PI - state.squibble_dir;
		};
	};

	const new_mascot_rect = state.mascot_rect;
	new_mascot_rect.x += state.dt: f64 * 0.2 * math::sinf64(state.mascot_dir);
	new_mascot_rect.y += state.dt: f64 * 0.2 * math::cosf64(state.mascot_dir);
	const viewport = vec::rect {
		x = 0.0,
		y = 0.0,
		w = state.width: f64,
		h = state.height: f64,
	};
	const xcontains = xcontains_rect_rect(&viewport, &new_mascot_rect);
	const ycontains = ycontains_rect_rect(&viewport, &new_mascot_rect);
	if (xcontains && ycontains) {
		state.mascot_rect = new_mascot_rect;
	} else {
		if (!xcontains) {
			state.mascot_dir = 2.0 * math::PI - state.mascot_dir;
		} else {
			state.mascot_dir = 1.0 * math::PI - state.mascot_dir;
		};
	};
};
