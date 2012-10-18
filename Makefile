build: index.js components
	@component build

rebuild: index.js components
	rm -fr build
	make build

components:
	@component install

clean:
	rm -fr build components

downloads:
	./downloads/generate.coffee

release:
	cake build
	cake css
	make downloads

all:
	clear
	make clean
	make build

.PHONY: clean, downloads
