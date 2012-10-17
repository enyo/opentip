build: index.js components
	@component build

rebuild: index.js components
	rm -fr build
	make build

components:
	@component install

clean:
	rm -fr build components

all:
	clear
	make clean
	make build

.PHONY: clean
