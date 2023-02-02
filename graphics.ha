use fmt;
use fs;
use ft = freetype2;
use image::qoi;
use io;
use log;
use math;
use net;
use os;
use pixbuf;
use strings;
use vec;
use wayland::client;
use wayland::wl;
use wayland::xdg;

def FONT_PATH: str = "/usr/share/fonts/noto-cjk/NotoSerifCJK-Regular.ttc";
// def FONT_PATH: str = "/usr/share/fonts/noto/NotoColorEmoji.ttf";
def FONT_SIZE: u32 = 24;
def LINE_HEIGHT: f32 = 2.0;
let CHARS: []u32 = [
	// Basic Latin
	0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b,
	0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,
	0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x41, 0x42, 0x43,
	0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f,
	0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b,
	0x5c, 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
	0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73,
	0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e,
	// Hiragana
	0x3041, 0x3042, 0x3043, 0x3044, 0x3045, 0x3046, 0x3047, 0x3048, 0x3049,
	0x304a, 0x304b, 0x304c, 0x304d, 0x304e, 0x304f, 0x3050, 0x3051, 0x3052,
	0x3053, 0x3054, 0x3055, 0x3056, 0x3057, 0x3058, 0x3059, 0x305a, 0x305b,
	0x305c, 0x305d, 0x305e, 0x305f, 0x3060, 0x3061, 0x3062, 0x3063, 0x3064,
	0x3065, 0x3066, 0x3067, 0x3068, 0x3069, 0x306a, 0x306b, 0x306c, 0x306d,
	0x306e, 0x306f, 0x3070, 0x3071, 0x3072, 0x3073, 0x3074, 0x3075, 0x3076,
	0x3077, 0x3078, 0x3079, 0x307a, 0x307b, 0x307c, 0x307d, 0x307e, 0x307f,
	0x3080, 0x3081, 0x3082, 0x3083, 0x3084, 0x3085, 0x3086, 0x3087, 0x3088,
	0x3089, 0x308a, 0x308b, 0x308c, 0x308d, 0x308e, 0x308f, 0x3090, 0x3091,
	0x3092, 0x3093, 0x3094, 0x3095, 0x3096, 0x3099, 0x309a, 0x309b, 0x309c,
	0x309d, 0x309e, 0x309f,
	// Some kanji
	0x50d5,
	0x5143,
	0x6c17,
	0x5fc3,
	0x914d,
	0x4e00,
	0x4eca,
	0x601d,
	0x51fa,
	// Some emoji
	// 0x1f60a,
];

fn init_graphics(state: *state) void = {
	init_fonts(state);
	init_images(state);
	init_grid(state);
	init_and_run_wayland(state);
};

fn init_grid(state: *state) void = {
	state.grid = grid {
		sz = (state.width: u32, state.height: u32),
		cols = alloc([
			100: grid_sizing_fixed,
			1: grid_sizing_grow,
			1: grid_sizing_grow,
		]),
		rows = alloc([
			100: grid_sizing_fixed,
			1: grid_sizing_grow,
			1: grid_sizing_grow,
		]),
		gap = 5,
		items = alloc([
			grid_item {
				content = widget_button {
					text = "hello",
					style = (0.0, 0.0, 1.0, 1.0): vec::color,
				},
				pos = (0, 0),
				...
			},
			grid_item {
				content = widget_button {
					text = "there",
					style = (1.0, 0.0, 0.0, 1.0): vec::color,
				},
				pos = (1, 0),
				...
			},
			grid_item {
				content = widget_button {
					text = "how",
					style = (0.5, 0.5, 1.0, 1.0): vec::color,
				},
				pos = (2, 0),
				...
			},
			grid_item {
				content = widget_button {
					text = "are",
					style = (0.5, 0.0, 0.5, 1.0): vec::color,
				},
				pos = (0, 1),
				...
			},
			grid_item {
				content = widget_button {
					text = "you",
					style = (1.0, 0.5, 0.0, 1.0): vec::color,
				},
				pos = (1, 1),
				span = (1, 0),
				...
			},
			grid_item {
				content = widget_button {
					text = "doing",
					style = (0.0, 0.5, 0.5, 1.0): vec::color,
				},
				pos = (0, 2),
				...
			},
			grid_item {
				content = widget_button {
					text = "today",
					style = (1.0, 0.0, 1.0, 1.0): vec::color,
				},
				pos = (1, 2),
				...
			},
			grid_item {
				content = widget_button {
					text = "?",
					style = (0.5, 0.5, 1.0, 1.0): vec::color,
				},
				pos = (2, 2),
				...
			},
		]),
		...
	};
	state.grid_metrics = grid_calc_metrics(&state.grid);
	state.grid_item_metrics = grid_calc_item_metrics(&state.grid, &state.grid_metrics);
};

fn init_fonts(state: *state) void = {
	state.font_atlas = pixbuf::newbuffer(pixbuf::format::A8R8G8B8,
		500, 500, 500 * 4);

	let library: ft::FT_Library = null;
	ft::FT_Init_FreeType(&library);

	let face: ft::FT_Face = null;
	const status = ft::FT_New_Face(library, FONT_PATH, 0, &face);
	if (status != 0) {
		fmt::fatal("could not load face: (path {}) (status {})",
			FONT_PATH, status: int);
	};
	defer ft::FT_Done_Face(face);

	ft::FT_Set_Pixel_Sizes(face, 0, FONT_SIZE);

	if (ft::FT_Is_Scalable(face)) {
		fmt::fatal("face is not scalable");
	};

	let face_rec: *ft::FT_FaceRec = face: *ft::FT_FaceRec;
	state.font = font {
		height = face_rec.height,
		ascender = face_rec.ascender,
		line_height = LINE_HEIGHT,
	};

	const next_tex_pos: uvec = (0, 0);
	for (let i = 0z; i < len(CHARS); i += 1) {
		const c: u32 = CHARS[i];
		add_char_to_font_atlas(state, face, &next_tex_pos, c);
	};

};

fn add_char_to_font_atlas(
	state: *state,
	face: ft::FT_Face,
	next_tex_pos: *uvec,
	c: u32,
) void = {
	let slot: ft::FT_GlyphSlot = (face: *ft::FT_FaceRec).glyph;
	let glyph: *ft::FT_GlyphSlotRec = slot: *ft::FT_GlyphSlotRec;
	const glyph_idx = ft::FT_Get_Char_Index(face, c);
	const status = ft::FT_Load_Glyph(face, glyph_idx,
		ft::FT_Load_Flag::FT_LOAD_COLOR);
	if (status != 0) {
		fmt::println("could not load char")!;
	};
	const status = ft::FT_Render_Glyph(slot,
		ft::FT_Render_Mode::FT_RENDER_MODE_LCD);
	if (status != 0) {
		fmt::println("could not render char")!;
	};
	assert(glyph.bitmap.pitch >= 0);

	const depth = 3u32;
	const width_in_px = glyph.bitmap.width / depth;
	const buffer_size = glyph.bitmap.pitch: u32 * glyph.bitmap.rows;
	let buffer: []u8 = (glyph.bitmap.buffer: *[*]u8)[..buffer_size];
	const glyph_pixbuf = pixbuf::newbuffer_static(pixbuf::format::R8G8B8,
		width_in_px, glyph.bitmap.rows, glyph.bitmap.pitch: size, buffer);

	let tex_pos = *next_tex_pos;
	const glyph_end: uvec = (
		tex_pos.0 + glyph_pixbuf.width: u64,
		tex_pos.1 + glyph_pixbuf.height: u64,
	);
	if (glyph_end.0 > state.font_atlas.width: u64) {
		// We ran off the right edge, move to the next row
		tex_pos.0 = 0;
		tex_pos.1 += state.font_atlas_row_max_y;
		state.font_atlas_row_max_y = 0;
	};
	if (glyph_end.1 > state.font_atlas.height: u64) {
		// We ran off the bottom edge, not much to do other than start
		// overwriting
		tex_pos = (0, 0);
	};

	pixbuf::copy(&state.font_atlas, &pixbuf::rect {
		x = tex_pos.0: u32,
		y = tex_pos.1: u32,
		w = glyph_pixbuf.width,
		h = glyph_pixbuf.height,
	}, &glyph_pixbuf, &pixbuf::rect {
		x = 0,
		y = 0,
		w = glyph_pixbuf.width,
		h = glyph_pixbuf.height,
	});

	let font_char: font_char = font_char { ... };
	font_char.c = c;
	font_char.sz = (glyph_pixbuf.width, glyph.bitmap.rows);
	font_char.bearing = (glyph.bitmap_left, glyph.bitmap_top);
	font_char.advance = (glyph.advance.x, glyph.advance.y);
	font_char.tex_coords = tex_pos;
	append(state.font_chars, font_char);

	if (font_char.sz.1 > state.font_atlas_row_max_y) {
		state.font_atlas_row_max_y = font_char.sz.1;
	};

	*next_tex_pos = tex_pos;
	next_tex_pos.0 += font_char.sz.0;
};

fn init_images(state: *state) void = {
	state.mascot = load_image("mascot.qoi");
	invert_rgb(&state.mascot);
	state.mascot_rect.w = state.mascot.width: f64;
	state.mascot_rect.h = state.mascot.height: f64;

	state.compass = load_image("compass.qoi");
	state.compass_rect.w = state.compass.width: f64;
	state.compass_rect.h = state.compass.height: f64;
};

// Inverts the RGB values in a given ARGB [[buffer]].
fn invert_rgb(b: *pixbuf::buffer) void = {
	let data: []u8 = pixbuf::buffer_data(b);
	for (let i = 0z; i < len(data) - 4; i += 1) {
		data[i + 1] = ~data[i + 1];
		data[i + 2] = ~data[i + 2];
		data[i + 3] = ~data[i + 3];
	};
};

fn load_image(path: str) pixbuf::buffer = {
	const file = os::open(path)!;
	defer io::close(file)!;

	const (head, dec) = qoi::newreader(file)!;
	const img = pixbuf::newbuffer(pixbuf::format::A8R8G8B8,
		head.width, head.height, head.width * 4);
	let data = pixbuf::buffer_data(&img);
	io::readall(&dec, data)!;

	return img;
};

fn init_and_run_wayland(state: *state) void = {
	const conn = match (client::connect("")) {
	case let d: *wl::display =>
		yield d;
	case let err: net::error =>
		log::fatal("Error connecting to Wayland", net::strerror(err));
	case let err: fs::error =>
		log::fatal("Error connecting to Wayland:", fs::strerror(err));
	};
	defer client::disconnect(conn)!;

	const registry = wl::display_get_registry(conn);
	defer client::delete_object(conn, registry.object.id);

	wl::registry_add_listener(registry, &registry_listener, state);
	client::roundtrip(conn)!;

	assert(state.compositor != null, "wl_compositor not found");
	assert(state.shm != null, "wl_shm not found");
	assert(state.wm_base != null, "xdg_wm_base not found");

	const stride = size(u32) * state.width;
	const shm = state.shm as *wl::shm;
	const buffer = shm_buffer_create(shm, state.width, state.height, stride);
	state.buffer = buffer;

	const compositor = state.compositor as *wl::compositor;
	const surface = wl::compositor_create_surface(compositor);
	state.surface = surface;

	const callback: *wl::callback = wl::surface_frame(surface);
	wl::callback_add_listener(callback, &frame_listener, state);

	const wm_base = state.wm_base as *xdg::wm_base;
	const xdg_surface = xdg::wm_base_get_xdg_surface(wm_base, surface);
	xdg::surface_add_listener(xdg_surface, &xdg_surface_listener, state);

	const xdg_toplevel = xdg::surface_get_toplevel(xdg_surface);
	xdg::toplevel_add_listener(xdg_toplevel, &xdg_toplevel_listener, state);
	xdg::toplevel_set_title(xdg_toplevel, "hare-wayland demo");
	xdg::toplevel_set_app_id(xdg_toplevel, "haretest");
	state.toplevel = xdg_toplevel;

	wl::surface_commit(surface);
	client::roundtrip(conn)!;

	wl::surface_attach(surface, buffer.buffer, 0, 0);
	wl::surface_commit(surface);

	for (state.run) {
		client::dispatch(conn)!;
	};
};

fn draw(state: *state) void = {
	// clear
	const painter = vec::newpainter(&state.buffer.pixbuf);
	vec::clear(&painter, vec::MIDNIGHTBLUE);

	// grid
	grid_draw(state, &state.grid, state.grid_item_metrics);

	// atlas
	// pixbuf::composite(&state.buffer.pixbuf, &pixbuf::rect {
	// 	x = 0,
	// 	y = 0,
	// 	w = state.font_atlas.width,
	// 	h = state.font_atlas.height,
	// }, &state.font_atlas, &pixbuf::rect {
	// 	x = 0,
	// 	y = 0,
	// 	w = state.font_atlas.width,
	// 	h = state.font_atlas.height,
	// }, pixbuf::blendmode::ADD);

	// mascot
	pixbuf::composite(&state.buffer.pixbuf, &pixbuf::rect {
		x = state.mascot_rect.x: size,
		y = state.mascot_rect.y: size,
		w = state.mascot_rect.w: size,
		h = state.mascot_rect.h: size,
	}, &state.mascot, &pixbuf::rect {
		x = 0,
		y = 0,
		w = state.mascot.width,
		h = state.mascot.height,
	}, pixbuf::blendmode::SUBTRACT);

	// squibble
	const style = vec::lineargradient(
		vec::RED,
		vec::BLUE,
		(220.0, 220.0),
		(220.0 + 128.0, 220.0 + 128.0),
	);
	vec::fill_rect(&painter, &style, &state.squibble_rect);

	// text
	draw_text(state, (20, 40 + state.text_y_offset),
		"roses are red,\nviolets are blue...\n\n僕は元気でいるよ\n心配ごともすくないよ\nただ一つ今も思い出すよ");
		// "😊");

	// compass
	pixbuf::composite(&state.buffer.pixbuf, &pixbuf::rect {
		x = state.compass_rect.x: size,
		y = state.compass_rect.y: size,
		w = state.compass_rect.w: size,
		h = state.compass_rect.h: size,
	}, &state.compass, &pixbuf::rect {
		x = 0,
		y = 0,
		w = state.compass.width,
		h = state.compass.height,
	}, pixbuf::blendmode::ALPHA);
};

const registry_listener = wl::registry_listener {
	global = &registry_global,
	...
};

fn registry_global(
	user: nullable *void,
	reg: *wl::registry,
	name: u32,
	iface: str,
	version: u32,
) void = {
	let state = user: *state;
	switch (iface) {
	case "wl_compositor" =>
		const compositor = wl::registry_bind(reg, name,
			&wl::compositor_interface,
			version): *wl::compositor;
		state.compositor = compositor;
	case "wl_shm" =>
		const shm = wl::registry_bind(reg, name,
			&wl::shm_interface, version): *wl::shm;
		state.shm = shm;
	case "wl_seat" =>
		const seat = wl::registry_bind(reg, name,
			&wl::seat_interface, version): *wl::seat;
		wl::seat_add_listener(seat,
			&wl_seat_listener, state);
		state.seat = seat;
	case "xdg_wm_base" =>
		const wm_base = wl::registry_bind(reg, name,
			&xdg::wm_base_interface, version): *xdg::wm_base;
		xdg::wm_base_add_listener(wm_base,
			&xdg_wm_base_listener, null);
		state.wm_base = wm_base;
	case =>
		yield;
	};
};

const xdg_wm_base_listener = xdg::wm_base_listener {
	ping = &xdg_wm_base_ping,
};

fn xdg_wm_base_ping(
	user: nullable *void,
	wm_base: *xdg::wm_base,
	serial: u32,
) void = {
	xdg::wm_base_pong(wm_base, serial);
};

const xdg_surface_listener = xdg::surface_listener {
	configure = &xdg_surface_configure,
};

fn xdg_surface_configure(
	user: nullable *void,
	xdg_surface: *xdg::surface,
	serial: u32,
) void = {
	const state = user: *state;
	const surface = state.surface as *wl::surface;
	xdg::surface_ack_configure(xdg_surface, serial);
	wl::surface_commit(surface);
};

const xdg_toplevel_listener = xdg::toplevel_listener {
	close = &xdg_toplevel_close,
	...
};

fn xdg_toplevel_close(
	user: nullable *void,
	xdg_toplevel: *xdg::toplevel,
) void = {
	let state = user: *state;
	state.run = false;
};

const wl_seat_listener = wl::seat_listener {
	capabilities = &wl_seat_capabilities,
	...
};

fn wl_seat_capabilities(
	user: nullable *void,
	seat: *wl::seat,
	caps: u32,
) void = {
	if (caps & wl::wl_seat_capability::POINTER != 0) {
		const ptr = wl::seat_get_pointer(seat);
		wl::pointer_add_listener(ptr, &wl_pointer_listener, user);
	};
};

const wl_pointer_listener = wl::pointer_listener {
	motion = &wl_pointer_motion,
	button = &wl_pointer_button,
	...
};

fn wl_pointer_motion(
	user: nullable *void,
	pointer: *wl::pointer,
	time: u32,
	surface_x: f64,
	surface_y: f64,
) void = {
	// log::printfln("pointer motion {},{}", surface_x, surface_y);
	void;
};

fn wl_pointer_button(
	user: nullable *void,
	pointer: *wl::pointer,
	serial: u32,
	time: u32,
	button: u32,
	bstate: u32,
) void = {
	const state = user: *state;
	if (bstate == wl::wl_pointer_button_state::PRESSED) {
		const seat = state.seat as *wl::seat;
		const toplevel = state.toplevel as *xdg::toplevel;
	};
};

const frame_listener = wl::callback_listener {
	done = &frame_handle_done,
	...
};

fn frame_handle_done(
	user: nullable *void,
	callback: *wl::callback,
	time: u32
) void = {
	const state = user: *state;

	// TODO
	// wl::callback_destroy(callback);

	draw(state);
	update(state, time);

	const callback: *wl::callback = wl::surface_frame(state.surface as *wl::surface);
	wl::callback_add_listener(callback, &frame_listener, state);

	// TODO: https://git.sr.ht/~bl4ckb0ne/gojira/tree/master/item/buffer.c#L122
	const s: *wl::surface = state.surface as *wl::surface;
	wl::surface_attach(s, state.buffer.buffer, 0, 0);
	wl::surface_damage_buffer(s, 0, 0, 6969, 6969);
	wl::surface_commit(s);
};
