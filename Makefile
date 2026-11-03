# Mighty Agents sites. Needs Hugo (extended) and Wrangler.
SITES := www toad

.PHONY: dev build deploy $(SITES)

dev:            ## both sites: www on :1313, toad on :1314
	(cd sites/www && hugo server --port 1313) & (cd sites/toad && hugo server --port 1314) & wait

build:
	@for s in $(SITES); do (cd sites/$$s && hugo --gc --minify --cleanDestinationDir) || exit 1; done

deploy: build
	@for s in $(SITES); do (cd sites/$$s && wrangler deploy) || exit 1; done
