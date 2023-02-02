use fmt;
use pixbuf;
use strings;
use vec;

fn draw_button(
	state: *state,
	button: *widget_button,
	rect: vec::rect,
	hover: bool,
) void = {
	const y_offset = 5;
	const painter = vec::newpainter(&state.buffer.pixbuf);

	const text_dimensions = get_text_dimensions(
		state, (rect.x: i32, rect.y: i32): ivec, button.text);

	const text_rect: ivec = (
		rect.x: i64 + state.grid.gap: i64,
		rect.y: i64 + state.grid.gap: i64 + y_offset,
	);
	const centered_rect = rect_align_center(rect, text_dimensions);
	if (button.align & align::HCENTER != 0) {
		text_rect.0 = centered_rect.x: i64;
	};
	if (button.align & align::VCENTER != 0) {
		text_rect.1 = centered_rect.y: i64;
	};
	// TODO: All the other [[align]] options

	if (hover) {
		vec::fill_rect(&painter, &button.style_hover, &rect);
	} else {
		vec::fill_rect(&painter, &button.style, &rect);
	};

	// TODO: Why do we need to do this? Looks weird otherwise.
	text_rect.1 += y_offset;

	draw_text(state, text_rect, button.text);
};

fn draw_text(state: *state, start_pos: ivec, text: str) void = {
	// NOTE: When changing this code, remember that the text positioning
	// logic needs to be replicated in `get_text_dimensions()`!
	let curr_pos = start_pos;
	let runes = strings::runes(text);
	const font_height = font_unit_to_px(state.font.height);
	const font_line_advance =
		(font_height: f32 * state.font.line_height): i16;
	const ascender = font_unit_to_px(state.font.ascender);
	start_pos.1 -= font_height - ascender;

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

fn get_text_dimensions(state: *state, start_pos: ivec, text: str) vec::rect = {
	let max_pos: ivec = (0, 0);
	let curr_pos = start_pos;
	let runes = strings::runes(text);
	const font_height = font_unit_to_px(state.font.height);
	const font_line_advance =
		(font_height: f32 * state.font.line_height): i16;
	const ascender = font_unit_to_px(state.font.ascender);
	start_pos.1 -= font_height - ascender;

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
		const char_end: ivec = (
			char_pos.0 + font_char.sz.0: i64,
			char_pos.1 + font_char.sz.1: i64,
		);
		if (char_end.0 > max_pos.0) {
			max_pos.0 = char_end.0;
		};
		if (char_end.1 > max_pos.1) {
			max_pos.1 = char_end.1;
		};
		curr_pos.0 = curr_pos.0 + frac_px_to_px(font_char.advance.0);
		curr_pos.1 = curr_pos.1 + frac_px_to_px(font_char.advance.1);
	};
	return vec::rect {
		x = start_pos.0: f32,
		y = start_pos.1: f32,
		w = max_pos.0: f32 - start_pos.0: f32,
		h = max_pos.1: f32 - start_pos.1: f32,
	};
};

fn rect_align_center(parent: vec::rect, child: vec::rect) vec::rect = {
	return vec::rect {
		x = parent.x + parent.w / 2.0 - child.w / 2.0,
		y = parent.y + parent.h / 2.0 - child.h / 2.0,
		w = child.w,
		h = child.h,
	};
};
