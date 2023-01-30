use vec;

// Returns whether two rects overlap.
fn collides_rect_rect(r1: *vec::rect, r2: *vec::rect) bool = {
	return r1.x < r2.x + r2.w &&
		r1.x + r1.w > r2.x &&
		r1.y < r2.y + r2.h &&
		r1.h + r1.y > r2.y;
};

// Returns whether child is contained within parent on the x axis.
fn xcontains_rect_rect(parent: *vec::rect, child: *vec::rect) bool = {
	return child.x >= parent.x &&
		child.x + child.w <= parent.x + parent.w;
};

// Returns whether child is contained within parent on the y axis.
fn ycontains_rect_rect(parent: *vec::rect, child: *vec::rect) bool = {
	return child.y >= parent.y &&
		child.y + child.h <= parent.y + parent.h;
};

// Returns whether child is contained within parent.
fn contains_rect_rect(parent: *vec::rect, child: *vec::rect) bool = {
	return xcontains_rect_rect(parent, child) &&
		ycontains_rect_rect(parent, child);
};
