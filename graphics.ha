use fmt;
use fs;
use ft = freetype2;
use image::qoi;
use io;
use log;
use net;
use os;
use pixbuf;
use vec;
use wayland::client;
use wayland::wl;
use wayland::xdg;

def FONT_PATH: str = "/usr/share/fonts/noto-cjk/NotoSerifCJK-Regular.ttc";
def FONT_SIZE: u32 = 64;

fn init_graphics(state: *state) void = {
	init_fonts(state);
	init_images(state);
	init_and_run_wayland(state);
};

fn init_fonts(state: *state) void = {
	let library: ft::FT_Library = null;
	ft::FT_Init_FreeType(&library);

	let face: ft::FT_Face = null;
	const status = ft::FT_New_Face(library, FONT_PATH, 0, &face);
	if (status != 0) {
		fmt::printfln("could not load face: (path {}) (status {})",
			FONT_PATH, status: int)!;
	};

	ft::FT_Set_Pixel_Sizes(face, 0, FONT_SIZE);

	if (ft::FT_Is_Scalable(face)) {
		fmt::printfln("face is not scalable")!;
	};

	const c = 'E': u64;
	const c_rune = 'E';

	let glyph: *ft::FT_GlyphSlotRec =
		((face: *ft::FT_FaceRec).glyph): *ft::FT_GlyphSlotRec;
	const status = ft::FT_Load_Char(face, c, ft::FT_Load_Flag::FT_LOAD_RENDER);
	if (status != 0) {
		fmt::println("could not load char")!;
	};

	fmt::printfln("char {}\n\twidth {}\n\trows {}\n\tpitch {}\n\tpixel_mode {}",
		c_rune,
		glyph.bitmap.width, glyph.bitmap.rows,
		glyph.bitmap.pitch, glyph.bitmap.pixel_mode)!;

	state.font_atlas = pixbuf::newbuffer(pixbuf::format::A8R8G8B8,
		glyph.bitmap.width, glyph.bitmap.rows);
	let data = pixbuf::buffer_data(&state.font_atlas);
	for (let i = 0z; i < state.font_atlas.height * state.font_atlas.width; i += 4) {
		data[i] = 0xff;
		const val: u8 = *((glyph.bitmap.buffer + i: uintptr): *u8);
		data[i + 1] = val;
		data[i + 2] = val;
		data[i + 3] = val;
	};

	ft::FT_Done_Face(face);
};

fn init_images(state: *state) void = {
	state.mascot = load_image("mascot.qoi");
	state.mascot_rect.w = state.mascot.width: f64;
	state.mascot_rect.h = state.mascot.height: f64;
};

fn load_image(path: str) pixbuf::buffer = {
	const file = os::open(path)!;
	defer io::close(file)!;

	const (head, dec) = qoi::newreader(file)!;
	const mascot = pixbuf::newbuffer(pixbuf::format::A8R8G8B8,
		head.width, head.height);
	let data = pixbuf::buffer_data(&mascot);
	io::readall(&dec, data)!;

	return mascot;
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

fn draw(
	buffer: shm_buffer,
	font_atlas: pixbuf::buffer,
	mascot: pixbuf::buffer,
	squibble_rect: *vec::rect,
	mascot_rect: *vec::rect,
) void = {
	// clear
	const painter = vec::newpainter(&buffer.pixbuf);
	vec::clear(&painter, vec::CORNFLOWERBLUE);

	// text
	pixbuf::copy(&buffer.pixbuf, &pixbuf::rect {
		x = 0,
		y = 0,
		w = font_atlas.width,
		h = font_atlas.height,
	}, &font_atlas, &pixbuf::rect {
		x = 0,
		y = 0,
		w = font_atlas.width,
		h = font_atlas.height,
	});


	// mascot
	pixbuf::copy(&buffer.pixbuf, &pixbuf::rect {
		x = mascot_rect.x: size,
		y = mascot_rect.y: size,
		w = mascot_rect.w: size,
		h = mascot_rect.h: size,
	}, &mascot, &pixbuf::rect {
		x = 0,
		y = 0,
		w = mascot.width,
		h = mascot.height,
	});

	// squibble
	const style = vec::lineargradient(
		vec::RED,
		vec::BLUE,
		(220.0, 220.0),
		(220.0 + 128.0, 220.0 + 128.0),
	);
	vec::fill_rect(&painter, &style, squibble_rect);
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

	draw(state.buffer, state.font_atlas, state.mascot,
		&state.squibble_rect, &state.mascot_rect);
	update(state, time);

	const callback: *wl::callback = wl::surface_frame(state.surface as *wl::surface);
	wl::callback_add_listener(callback, &frame_listener, state);

	// TODO: https://git.sr.ht/~bl4ckb0ne/gojira/tree/master/item/buffer.c#L122
	const s: *wl::surface = state.surface as *wl::surface;
	wl::surface_attach(s, state.buffer.buffer, 0, 0);
	wl::surface_damage_buffer(s, 0, 0, 6969, 6969);
	wl::surface_commit(s);
};