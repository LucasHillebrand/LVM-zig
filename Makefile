build:
	zig cc lvm.zig -o bin/lvm -target x86_64-linux

build-libs:
	zig cc lvm.zig -shared -o lib/lvm.so
	zig cc lvm.zig -shared -o lib/lvm.dll -target x86_64-windows
	
run: build
	bin/lvm test