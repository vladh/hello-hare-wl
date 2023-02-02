use fmt;
use pixbuf;
use strings;
use vec;

fn draw_button(state: *state, button: *widget_button, rect: vec::rect) void = {
	const painter = vec::newpainter(&state.buffer.pixbuf);
	const style = vec::lineargradient(
		vec::RED,
		vec::BLUE,
		(220.0, 220.0),
		(220.0 + 128.0, 220.0 + 128.0),
	);
	vec::fill_rect(&painter, &button.style, &rect);
	draw_text(state, (rect.x: i32, rect.y: i32): ivec, button.text);
};

fn draw_text(state: *state, start_pos: ivec, text: str) void = {
	let curr_pos = start_pos;
	let runes = strings::runes(text);
	const font_height = font_unit_to_px(state.font.height);
	const font_line_advance =
		(font_height: f32 * state.font.line_height): i16;
	for (let i = 0z; i < len(runes); i += 1) {
		const c: u32 = runes[i]: u32;
		if (c == '\n': u32) {
			curr_pos.0 = start_pos.0;
			curr_pos.1 += font_line_advance;
			continue;
		};
		const font_char = match (get_font_char(state.font_chars, c)) {
		case let f: *font_char =>
			yield f;
		case void =>
			fmt::fatalf("could not find char {}", c);
		};
		const char_pos: ivec = (
			curr_pos.0 + font_char.bearing.0,
			curr_pos.1 + font_height - font_char.bearing.1,
		);
		if (char_pos.0 < 0) {
			char_pos.0 = 0;
		};
		if (char_pos.1 < 0) {
			char_pos.1 = 0;
		};
		pixbuf::composite(&state.buffer.pixbuf, &pixbuf::rect {
			x = char_pos.0: u64,
			y = char_pos.1: u64,
			w = font_char.sz.0,
			h = font_char.sz.1,
		}, &state.font_atlas, &pixbuf::rect {
			x = font_char.tex_coords.0,
			y = font_char.tex_coords.1,
			w = font_char.sz.0,
			h = font_char.sz.1,
		}, pixbuf::blendmode::ADD);
		curr_pos.0 = curr_pos.0 + frac_px_to_px(font_char.advance.0);
		curr_pos.1 = curr_pos.1 + frac_px_to_px(font_char.advance.1);
	};
};

fn get_font_char(font_chars: []font_char, c: u32) (*font_char | void) = {
	for (let i = 0z; i < len(font_chars); i += 1) {
		if (font_chars[i].c == c) {
			return &font_chars[i];
		};
	};
	return void;
};

fn frac_px_to_px(n: i64) i64 = {
	return n >> 6;
};

fn font_unit_to_px(n: i64) i64 = {
	// NOTE: We should be dividing by units_per_em here...probably?
	// This is because we expect height etc. to be in "font units".
	// But treating these metrics as "fractional pixels" seems to work,
	// whereas division by units_per_em doesn't.
	// Check this in more detail.
	return n >> 6;
};
