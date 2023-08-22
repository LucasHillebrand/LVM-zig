build: build-lvm build-lasm

build-lvm:
	zig cc lvm.zig -o bin/lvm -target x86_64-linux 
	zig cc lvm.zig -o bin/lvm.exe -target x86_64-windows

build-lasm:
	zig cc lasm.zig -o bin/lasm -target x86_64-linux
	zig cc lasm.zig -o bin/lasm.exe -target x86_64-windows

run: build run-prog

run-prog:
	bash -c "if ls main.lasm ;then echo -n "";else ln -s demo/simple.lasm main.lasm;fi"
	bin/lasm main.lasm -o ./bin/demo.lbin
	bin/lvm -f ./bin/demo.lbin -d|less
	
run-lvm: build-lvm
	bin/lvm -d -m 512MB -h

run-lasm: build-lasm
	bin/lasm main.lasm -o ./bin/main.lbin

clean:
	rm bin/*