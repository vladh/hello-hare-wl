use fmt;
use vec;

type widget_button = struct {
	text: str,
	style: vec::style,
};
type drawable = (widget_button | void);

type grid_sizing_fixed = u64;
type grid_sizing_grow = u64;
type grid_sizing = (grid_sizing_fixed | grid_sizing_grow);

type grid_item_metrics = struct {
	rect: vec::rect,
};

type grid_item = struct {
	content: drawable,
	pos: uvec,
	// This is the span _in addition to_ the default 1x1 size
	span: uvec,
};

type cell_metrics = struct {
	origin: u64,
	sz: u64,
};

type grid_metrics = struct {
	cols: []cell_metrics,
	rows: []cell_metrics,
};

type grid = struct {
	origin: uvec,
	sz: uvec,
	cols: []grid_sizing,
	rows: []grid_sizing,
	items: []grid_item,
	gap: u64,
};

fn grid_calc_dim_metrics(
	sizings: []grid_sizing,
	max_size: u64,
) []cell_metrics = {
	let res: []cell_metrics = [];
	let curr_pos = 0u64;
	let total_fixed = 0u64;
	let total_grow = 0u64;
	for (let i = 0z; i < len(sizings); i += 1) {
		if (sizings[i] is grid_sizing_fixed) {
			total_fixed += sizings[i]: grid_sizing_fixed: u64;
		} else if (sizings[i] is grid_sizing_grow) {
			total_grow += sizings[i]: grid_sizing_grow: u64;
		} else {
			abort("don't know this grid sizing");
		};
	};
	const nonfixed = max_size - total_fixed;
	const grow_piece_size = nonfixed / total_grow;

	for (let i = 0z; i < len(sizings); i += 1) {
		let sz = 0u64;
		if (sizings[i] is grid_sizing_fixed) {
			sz = sizings[i]: grid_sizing_fixed: u64;
		} else if (sizings[i] is grid_sizing_grow) {
			const sizing = sizings[i]: grid_sizing_grow: u64;
			sz = (sizing * grow_piece_size);
		} else {
			abort("don't know this grid sizing");
		};
		append(res, cell_metrics {
			origin = curr_pos,
			sz = sz,
		});
		curr_pos = curr_pos + sz;
	};

	return res;
};

fn grid_calc_metrics(
	grid: *grid,
) grid_metrics = {
	return grid_metrics {
		cols = grid_calc_dim_metrics(grid.cols, grid.sz.0),
		rows = grid_calc_dim_metrics(grid.rows, grid.sz.1),
		...
	};
};

fn grid_calc_item_metrics(
	grid: *grid,
	grid_metrics: *grid_metrics,
) []grid_item_metrics = {
	let res: []grid_item_metrics = [];
	for (let i = 0z; i < len(grid.items); i += 1) {
		const item: *grid_item = &grid.items[i];

		const col_from = item.pos.0;
		const col_to = col_from + item.span.0;
		const origin_col = grid_metrics.cols[col_from];
		let col_sz = 0u64;
		for (let col = col_from; col <= col_to; col += 1) {
			col_sz += grid_metrics.cols[col].sz;
		};

		const row_from = item.pos.1;
		const row_to = row_from + item.span.1;
		let row_sz = 0u64;
		const origin_row = grid_metrics.rows[row_from];
		for (let row = row_from; row <= row_to; row += 1) {
			row_sz += grid_metrics.rows[row].sz;
		};

		const item_metrics = grid_item_metrics {
			rect = vec::rect {
				x = origin_col.origin: f32,
				y = origin_row.origin: f32,
				w = col_sz: f32,
				h = row_sz: f32,
			},
		};
		append(res, item_metrics);
	};
	return res;
};

fn grid_draw_item(
	state: *state,
	item: *grid_item,
	item_metrics: *grid_item_metrics,
) void = {
	match (item.content) {
	case let b: widget_button =>
		draw_button(state, &b, item_metrics.rect);
	case =>
		abort("don't know how to draw this item");
	};
};

fn grid_draw(
	state: *state,
	grid: *grid,
	item_metrics: []grid_item_metrics,
) void = {
	for (let i = 0z; i < len(grid.items); i += 1) {
		grid_draw_item(state, &grid.items[i], &item_metrics[i]);
	};
};
