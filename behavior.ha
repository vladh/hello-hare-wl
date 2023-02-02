use fmt;
use math;

fn handle_c(state: *state, item: *grid_item) void = {
	state.sum = 0.0;
};
fn handle_plusminus(state: *state, item: *grid_item) void = {
	state.sum = -state.sum;
};
fn handle_rem(state: *state, item: *grid_item) void = {
	stash(state);
	state.op = calc_op::REM;
};
fn handle_div(state: *state, item: *grid_item) void = {
	stash(state);
	state.op = calc_op::DIV;
};
fn handle_mul(state: *state, item: *grid_item) void = {
	stash(state);
	state.op = calc_op::MUL;
};
fn handle_sub(state: *state, item: *grid_item) void = {
	stash(state);
	state.op = calc_op::SUB;
};
fn handle_add(state: *state, item: *grid_item) void = {
	stash(state);
	state.op = calc_op::ADD;
};
fn handle_dot(state: *state, item: *grid_item) void = {
	state.dot_count = 0;
	state.dot_on = !state.dot_on;
};
fn handle_eq(state: *state, item: *grid_item) void = {
	switch (state.op) {
	case calc_op::ADD =>
		state.sum = state.cache + state.sum;
	case calc_op::SUB =>
		state.sum = state.cache - state.sum;
	case calc_op::MUL =>
		state.sum = state.cache * state.sum;
	case calc_op::DIV =>
		state.sum = state.cache / state.sum;
	case calc_op::REM =>
		state.sum = math::modf64(state.cache, state.sum);
	case =>
		void;
	};
	state.cache = 0.0;
	state.op = calc_op::NONE;
};
fn handle_0(state: *state, item: *grid_item) void = {
	add_digit(state, 0.0);
};
fn handle_1(state: *state, item: *grid_item) void = {
	add_digit(state, 1.0);
};
fn handle_2(state: *state, item: *grid_item) void = {
	add_digit(state, 2.0);
};
fn handle_3(state: *state, item: *grid_item) void = {
	add_digit(state, 3.0);
};
fn handle_4(state: *state, item: *grid_item) void = {
	add_digit(state, 4.0);
};
fn handle_5(state: *state, item: *grid_item) void = {
	add_digit(state, 5.0);
};
fn handle_6(state: *state, item: *grid_item) void = {
	add_digit(state, 6.0);
};
fn handle_7(state: *state, item: *grid_item) void = {
	add_digit(state, 7.0);
};
fn handle_8(state: *state, item: *grid_item) void = {
	add_digit(state, 8.0);
};
fn handle_9(state: *state, item: *grid_item) void = {
	add_digit(state, 9.0);
};
fn add_digit(state: *state, digit: f64) void = {
	if (state.dot_on) {
		state.dot_count += 1;
		state.sum = state.sum + digit /
			math::powf64(10.0, state.dot_count: f64);
	} else {
		state.sum = state.sum * 10.0 + digit;
	};
};
fn stash(state: *state) void = {
	state.cache = state.sum;
	state.dot_on = false;
	state.dot_count = 0;
	state.sum = 0.0;
};
