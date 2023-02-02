use glm;
use vec;
use pixbuf;
use wayland::client;
use wayland::wl;
use wayland::xdg;

type ivec = (i64, i64);
type uvec = (u64, u64);

type font = struct {
	height: i16,
	line_height: f32,
};

type font_char = struct {
	c: u32,
	sz: uvec,
	bearing: ivec,
	advance: ivec,
	tex_coords: uvec,
};

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
	compass: pixbuf::buffer,
	font: font,
	font_atlas: pixbuf::buffer,
	font_atlas_nextpos: ivec,
	font_atlas_row_max_y: u64,
	font_chars: []font_char,

	// Scene
	squibble_rect: vec::rect,
	squibble_dir: f64,
	mascot_rect: vec::rect,
	mascot_dir: f64,
	compass_rect: vec::rect,
	compass_dir: f64,
	text_y_offset: i32,
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
		compass_dir = glm::rad(-12.0),
		compass_rect = vec::rect {
			x = 150.0,
			y = 20.0,
			w = 0.0,
			h = 0.0,
		},
		width = 500z,
		height = 700z,
		...
	};
	init_graphics(&state);
};
