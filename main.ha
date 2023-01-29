use endian;
use errors;
use fs;
use io;
use log;
use net;
use os;
use pixbuf;
use wayland::client;
use wayland::wl;
use vec;
use xdg = wayland::xdg_shell;

type state = struct {
	run: bool,

	// Globals
	compositor: nullable *wl::compositor,
	shm: nullable *wl::shm,
	wm_base: nullable *xdg::wm_base,

	// Objects
	surface: nullable *wl::surface,
};

export fn main() void = {
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

	let state = state {
		run = true,
		...
	};

	wl::registry_add_listener(registry, &registry_listener, &state);

	client::roundtrip(conn)!;

	assert(state.compositor != null, "wl_compositor not found");
	assert(state.shm != null, "wl_shm not found");
	assert(state.wm_base != null, "xdg_wm_base not found");

	const width = 640z, height = 480z;
	const stride = size(u32) * width;
	const shm = state.shm as *wl::shm;
	const buffer = shm_buffer_create(shm, width, height, stride);

	const painter = vec::newpainter(&buffer.pixbuf);
	vec::clear(&painter, vec::CORNFLOWERBLUE);

	const style = vec::lineargradient(
		vec::RED,
		vec::BLUE,
		(200.0, 128.0),
		(200.0 + 128.0, 128.0 + 128.0),
	);
	vec::fill_rect(&painter, &style, &vec::rect {
		x = 200.0,
		y = 128.0,
		w = 128.0,
		h = 128.0,
	});

	const compositor = state.compositor as *wl::compositor;
	const surface = wl::compositor_create_surface(compositor);
	state.surface = surface;

	const wm_base = state.wm_base as *xdg::wm_base;
	const xdg_surface = xdg::wm_base_get_xdg_surface(wm_base, surface);
	xdg::surface_add_listener(xdg_surface, &xdg_surface_listener, &state);

	const xdg_toplevel = xdg::surface_get_toplevel(xdg_surface);
	xdg::toplevel_add_listener(xdg_toplevel, &xdg_toplevel_listener, &state);
	xdg::toplevel_set_title(xdg_toplevel, "hare-wayland demo");

	wl::surface_commit(surface);
	client::roundtrip(conn)!;

	wl::surface_attach(surface, buffer.buffer, 0, 0);
	wl::surface_commit(surface);

	for (state.run) client::dispatch(conn)!;
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
