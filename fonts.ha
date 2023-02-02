use fmt;
use ft = freetype2;
use pixbuf;

def FONT_PATH: str = "/usr/share/fonts/TTF/IBMPlexSansJP-Regular.ttf";
// def FONT_PATH: str = "/usr/share/fonts/noto/NotoColorEmoji.ttf";
def FONT_SIZE: u32 = 38;
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
	// Math stuff
	0x00f7,
	0x00d7,
	0x00b1,
	0xff0b,
	0xff0d,
];

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
