# Mighty Agents sites. Needs Hugo (extended) and Wrangler.
SITES := www toad faur

.PHONY: dev build deploy $(SITES)

dev:            ## www :1313, toad :1314, faur :1315
	(cd sites/www && hugo server --port 1313) & (cd sites/toad && hugo server --port 1314) & (cd sites/faur && hugo server --port 1315) & wait

build:
	@for s in $(SITES); do (cd sites/$$s && hugo --gc --minify --cleanDestinationDir) || exit 1; done

deploy: build
	@for s in $(SITES) www-redirect; do (cd sites/$$s && wrangler deploy) || exit 1; done
