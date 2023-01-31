use math;
use vec;

fn do_dvd(
	rect: *vec::rect,
	dir: *f64,
	dt: u32,
	viewport: *vec::rect,
	speed: f64,
) void = {
	const new_rect = *rect;
	new_rect.x += dt: f64 * 0.2 * speed * math::sinf64(*dir);
	new_rect.y += dt: f64 * 0.2 * speed * math::cosf64(*dir);
	const xcontains = xcontains_rect_rect(viewport, &new_rect);
	const ycontains = ycontains_rect_rect(viewport, &new_rect);
	if (xcontains && ycontains) {
		*rect = new_rect;
	} else {
		if (!xcontains) {
			*dir = 2.0 * math::PI - *dir;
		} else {
			*dir = 1.0 * math::PI - *dir;
		};
	};
};

fn update(state: *state, time: u32) void = {
	if (state.last_time == 0) {
		state.last_time = time;
	};
	state.dt = time - state.last_time;
	state.last_time = time;
	const viewport = vec::rect {
		x = 0.0,
		y = 0.0,
		w = state.width: f64,
		h = state.height: f64,
	};

	do_dvd(&state.squibble_rect, &state.squibble_dir, state.dt, &viewport, 1.0);
	do_dvd(&state.mascot_rect, &state.mascot_dir, state.dt, &viewport, 2.0);
};
