use fmt;

type widget_button = struct {
	text: str,
};
type drawable = (widget_button | void);

type grid_sizing_fixed = u64;
type grid_sizing_grow = u64;
type grid_sizing = (grid_sizing_fixed | grid_sizing_grow);

type grid_item_metrics = struct {
	origin: uvec,
	sz: uvec,
};

type grid_item = struct {
	content: drawable,
	pos: uvec,
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
};

fn grid_calc_dim(sizings: []grid_sizing, max_size: u64) []cell_metrics = {
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
			sz = curr_pos + sz,
		});
		curr_pos = curr_pos + sz;
	};

	return res;
};

fn grid_calc(grid: *grid) grid_metrics = {
	return grid_metrics {
		cols = grid_calc_dim(grid.cols, grid.sz.0),
		rows = grid_calc_dim(grid.rows, grid.sz.1),
		...
	};
};

fn grid_calc_items(grid: *grid, grid_metrics: *grid_metrics) []grid_item_metrics = {
	let res: []grid_item_metrics = [];
	for (let i = 0z; i < len(grid.items); i += 1) {
		const item: *grid_item = &grid.items[i];
		const col = grid_metrics.cols[item.pos.0];
		const row = grid_metrics.rows[item.pos.1];
		const item_metrics = grid_item_metrics {
			sz = (col.sz, row.sz),
			origin = (col.origin, row.origin),
		};
		append(res, item_metrics);
	};
	for (let i = 0z; i < len(res); i += 1) {
		fmt::printfln("{}: sz ({}, {}) origin ({}, {})",
			i,
			res[i].sz.0, res[i].sz.1,
			res[i].origin.0, res[i].origin.1)!;
	};
	return res;
};
