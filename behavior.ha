use fmt;

fn handle_c(state: *state, item: *grid_item) void = {
	state.sum = 100.0;
};
fn handle_plusminus(state: *state, item: *grid_item) void = {
	state.sum = -state.sum;
};
fn handle_rem(state: *state, item: *grid_item) void = {
	state.sum = 200.0;
};
fn handle_div(state: *state, item: *grid_item) void = {
	state.sum = 300.0;
};
fn handle_mul(state: *state, item: *grid_item) void = {
	state.sum = 400.0;
};
fn handle_sub(state: *state, item: *grid_item) void = {
	state.sum = 500.0;
};
fn handle_add(state: *state, item: *grid_item) void = {
	state.sum = 600.0;
};
fn handle_dot(state: *state, item: *grid_item) void = {
	state.sum = 700.0;
};
fn handle_eq(state: *state, item: *grid_item) void = {
	state.sum = 800.0;
};
fn handle_0(state: *state, item: *grid_item) void = {
	state.sum = 0.0;
};
fn handle_1(state: *state, item: *grid_item) void = {
	state.sum = 1.0;
};
fn handle_2(state: *state, item: *grid_item) void = {
	state.sum = 2.0;
};
fn handle_3(state: *state, item: *grid_item) void = {
	state.sum = 3.0;
};
fn handle_4(state: *state, item: *grid_item) void = {
	state.sum = 4.0;
};
fn handle_5(state: *state, item: *grid_item) void = {
	state.sum = 5.0;
};
fn handle_6(state: *state, item: *grid_item) void = {
	state.sum = 6.0;
};
fn handle_7(state: *state, item: *grid_item) void = {
	state.sum = 7.0;
};
fn handle_8(state: *state, item: *grid_item) void = {
	state.sum = 8.0;
};
fn handle_9(state: *state, item: *grid_item) void = {
	state.sum = 9.0;
};
