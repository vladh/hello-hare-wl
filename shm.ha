use io;
use log;
use pixbuf;
use rt;
use wayland::wl;

type shm_buffer = struct {
	fd: io::file,
	shm_pool: *wl::shm_pool,
	buffer: *wl::buffer,
	pixbuf: pixbuf::buffer,
};

fn shm_buffer_create(
	shm: *wl::shm,
	width: size,
	height: size,
	stride: size,
) shm_buffer = {
	const sz = height * stride;
	const fd = rt::memfd_create("wl_shm", rt::MFD_CLOEXEC)!;
	rt::ftruncate(fd, sz)!;

	const buf = io::mmap(null, sz, io::prot::READ | io::prot::WRITE,
		io::mflags::SHARED, fd, 0)!: *[*]u8;
	const shm_pool = wl::shm_create_pool(shm, fd, sz: i32);
	const buffer = wl::shm_pool_create_buffer(shm_pool,
		0, width: i32, height: i32, stride: i32,
		wl::wl_shm_format::ARGB8888);

	const pixbuf = pixbuf::newbuffer_static(
		pixbuf::format::A8R8G8B8, width, height, stride,
		buf[..stride * height]);

	return shm_buffer {
		fd = fd,
		shm_pool = shm_pool,
		buffer = buffer,
		pixbuf = pixbuf,
	};
};
