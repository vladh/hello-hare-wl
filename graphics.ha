use fmt;
use fs;
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

def COLOR_BG: vec::color = (0.02, 0.02, 0.02, 1.0);

fn init_graphics(state: *state) void = {
	init_fonts(state);
	init_images(state);
	init_grid(state);
	init_and_run_wayland(state);
};

fn init_grid(state: *state) void = {
	// NOTE: This is very slow
	// let COLOR_SCREEN: vec::style = vec::lineargradient(
	// 	(0.00, 0.00, 0.00, 1.0): vec::color,
	// 	(0.1, 0.1, 0.1, 1.0): vec::color,
	// 	(0.0, 0.0),
	// 	(state.width: f32, 100.0),
	// );
	let COLOR_SCREEN: vec::color = (0.1, 0.1, 0.1, 1.0);
	let COLOR_DIGIT: vec::color = (0.2, 0.2, 0.2, 1.0);
	let COLOR_DIGIT_HOVER: vec::color = (0.3, 0.3, 0.3, 1.0);
	let COLOR_OP: vec::color = (0.1, 0.1, 0.7, 1.0);
	let COLOR_OP_HOVER: vec::color = (0.2, 0.2, 0.8, 1.0);
	let COLOR_OP2: vec::color = (0.5, 0.5, 0.5, 1.0);
	let COLOR_OP2_HOVER: vec::color = (0.6, 0.6, 0.6, 1.0);

	state.grid = grid {
		sz = (state.width: u32, state.height: u32),
		cols = alloc([
			1: grid_sizing_grow,
			1: grid_sizing_grow,
			1: grid_sizing_grow,
			1: grid_sizing_grow,
		]),
		rows = alloc([
			80: grid_sizing_fixed,
			200: grid_sizing_fixed,
			1: grid_sizing_grow,
			1: grid_sizing_grow,
			1: grid_sizing_grow,
			1: grid_sizing_grow,
			1: grid_sizing_grow,
		]),
		gap = 10,
		items = alloc([
			grid_item {
				content = widget_button {
					text = "HAREへようこそ!",
					style = COLOR_BG,
					style_hover = COLOR_BG,
					align = align::LEFT | align::VCENTER,
				},
				pos = (0, 0),
				span = (3, 0),
				...
			},
			grid_item {
				content = widget_button {
					text = "69420",
					style = COLOR_SCREEN,
					style_hover = COLOR_SCREEN,
					align = align::LEFT | align::VCENTER,
				},
				pos = (0, 1),
				span = (3, 0),
				...
			},
			grid_item {
				content = widget_button {
					text = "C",
					style = COLOR_OP2,
					style_hover = COLOR_OP2_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_c,
				pos = (0, 2),
				...
			},
			grid_item {
				content = widget_button {
					text = "±",
					style = COLOR_OP2,
					style_hover = COLOR_OP2_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_plusminus,
				pos = (1, 2),
				...
			},
			grid_item {
				content = widget_button {
					text = "%",
					style = COLOR_OP2,
					style_hover = COLOR_OP2_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_rem,
				pos = (2, 2),
				...
			},
			grid_item {
				content = widget_button {
					text = "÷",
					style = COLOR_OP,
					style_hover = COLOR_OP_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_div,
				pos = (3, 2),
				...
			},
			grid_item {
				content = widget_button {
					text = "7",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_7,
				pos = (0, 3),
				...
			},
			grid_item {
				content = widget_button {
					text = "8",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_8,
				pos = (1, 3),
				...
			},
			grid_item {
				content = widget_button {
					text = "9",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_9,
				pos = (2, 3),
				...
			},
			grid_item {
				content = widget_button {
					text = "×",
					style = COLOR_OP,
					style_hover = COLOR_OP_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_mul,
				pos = (3, 3),
				...
			},
			grid_item {
				content = widget_button {
					text = "4",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_4,
				pos = (0, 4),
				...
			},
			grid_item {
				content = widget_button {
					text = "5",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_5,
				pos = (1, 4),
				...
			},
			grid_item {
				content = widget_button {
					text = "6",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_6,
				pos = (2, 4),
				...
			},
			grid_item {
				content = widget_button {
					text = "-",
					style = COLOR_OP,
					style_hover = COLOR_OP_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_sub,
				pos = (3, 4),
				...
			},
			grid_item {
				content = widget_button {
					text = "1",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_1,
				pos = (0, 5),
				...
			},
			grid_item {
				content = widget_button {
					text = "2",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_2,
				pos = (1, 5),
				...
			},
			grid_item {
				content = widget_button {
					text = "3",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_3,
				pos = (2, 5),
				...
			},
			grid_item {
				content = widget_button {
					text = "＋",
					style = COLOR_OP,
					style_hover = COLOR_OP_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_add,
				pos = (3, 5),
				...
			},
			grid_item {
				content = widget_button {
					text = "0",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_0,
				pos = (0, 6),
				span = (1, 0),
				...
			},
			grid_item {
				content = widget_button {
					text = ".",
					style = COLOR_DIGIT,
					style_hover = COLOR_DIGIT_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_dot,
				pos = (2, 6),
				...
			},
			grid_item {
				content = widget_button {
					text = "=",
					style = COLOR_OP,
					style_hover = COLOR_OP_HOVER,
					align = align::HCENTER | align::VCENTER,
				},
				handler = &handle_eq,
				pos = (3, 6),
				...
			},
		]),
		...
	};
	state.grid_metrics = grid_calc_metrics(&state.grid);
	state.grid_item_metrics = grid_calc_item_metrics(&state.grid, &state.grid_metrics);
};

fn init_images(state: *state) void = {
	state.mascot = load_image("mascot.qoi");
	invert_rgb(&state.mascot);
	set_harriet_alpha(&state.mascot);
	state.mascot_rect.w = state.mascot.width: f64;
	state.mascot_rect.h = state.mascot.height: f64;

	state.compass = load_image("compass.qoi");
	state.compass_rect.w = state.compass.width: f64;
	state.compass_rect.h = state.compass.height: f64;
};

// Inverts the RGB values in a given ARGB [[buffer]].
fn invert_rgb(b: *pixbuf::buffer) void = {
	let data: []u8 = pixbuf::buffer_data(b);
	for (let i = 0z; i < len(data); i += 4) {
		data[i + 0] = ~data[i + 0];
		data[i + 1] = ~data[i + 1];
		data[i + 2] = ~data[i + 2];
	};
};

// Sets the alpha values in a given ARGB [[buffer]].
fn set_alpha(b: *pixbuf::buffer, a: u8) void = {
	let data: []u8 = pixbuf::buffer_data(b);
	for (let i = 0z; i < len(data); i += 4) {
		data[i + 3] = a;
	};
};

fn set_harriet_alpha(b: *pixbuf::buffer) void = {
	let data: []u8 = pixbuf::buffer_data(b);
	for (let i = 0z; i < len(data); i += 4) {
		if (data[i] == 0xff) {
			data[i + 3] = 0x80;
		} else {
			data[i + 3] = 0x00;
		};
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
	vec::clear(&painter, COLOR_BG);

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
	}, pixbuf::blendmode::ALPHA);

	// squibble
	// const style = vec::lineargradient(
	// 	vec::RED,
	// 	vec::BLUE,
	// 	(220.0, 220.0),
	// 	(220.0 + 128.0, 220.0 + 128.0),
	// );
	// vec::fill_rect(&painter, &style, &state.squibble_rect);

	// text
	// draw_text(state, (20, 40 + state.text_y_offset),
	// 	"roses are red,\nviolets are blue...\n\n僕は元気でいるよ\n心配ごともすくないよ\nただ一つ今も思い出すよ");
		// "😊");

	// compass
	// pixbuf::composite(&state.buffer.pixbuf, &pixbuf::rect {
	// 	x = state.compass_rect.x: size,
	// 	y = state.compass_rect.y: size,
	// 	w = state.compass_rect.w: size,
	// 	h = state.compass_rect.h: size,
	// }, &state.compass, &pixbuf::rect {
	// 	x = 0,
	// 	y = 0,
	// 	w = state.compass.width,
	// 	h = state.compass.height,
	// }, pixbuf::blendmode::ALPHA);
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
	const state = user: *state;
	state.mouse_x = surface_x;
	state.mouse_y = surface_y;
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
		grid_handle_click(
			state, state.mouse_x, state.mouse_y, state.grid_item_metrics);
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
