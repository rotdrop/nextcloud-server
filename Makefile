NPMFLAGS = --legacy-peer-deps

all: clean dev-setup build-js-production

# Dev env management
dev-setup: clean npm-init

npm-init:
	npm $(NPMFLAGS) ci  

npm-update:
	npm $(NPMFLAGS) update

# Building
build-js:
	npm $(NPMFLAGS) run dev

build-js-production:
	npm $(NPMFLAGS) run build

watch-js:
	npm run watch

# Linting
lint-fix:
	npm run lint:fix

lint-fix-watch:
	npm run lint:fix-watch

# Cleaning
clean:
	rm -rf dist

clean-git: clean
	git checkout -- dist
