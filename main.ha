use glm;
use vec;
use pixbuf;
use wayland::client;
use wayland::wl;
use wayland::xdg;

type state = struct {
	// Engine
	run: bool,
	last_time: u32,
	dt: u32,

	// Graphics
	compositor: nullable *wl::compositor,
	shm: nullable *wl::shm,
	wm_base: nullable *xdg::wm_base,
	seat: nullable *wl::seat,
	surface: nullable *wl::surface,
	toplevel: nullable *xdg::toplevel,
	buffer: shm_buffer,
	width: size,
	height: size,

	// Assets
	mascot: pixbuf::buffer,

	// Scene
	squibble_rect: vec::rect,
	squibble_dir: f64,
	mascot_rect: vec::rect,
	mascot_dir: f64,
};

export fn main() void = {
	let state = state {
		run = true,
		squibble_dir = glm::rad(30.0),
		squibble_rect = vec::rect {
			x = 0.0,
			y = 0.0,
			w = 128.0,
			h = 128.0,
		},
		mascot_dir = glm::rad(-73.0),
		mascot_rect = vec::rect {
			x = 50.0,
			y = 180.0,
			w = 0.0,
			h = 0.0,
		},
		width = 640z,
		height = 480z,
		...
	};
	init_graphics(&state);
};

