ltl:
	moonc ltl.moon
	cp ltl.lua ltl
	cp ltl.lua mtl

clean:
	rm ltl.lua ltl mtl
