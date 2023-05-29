# This target is executed whenever we just type `make`
.DEFAULT_GOAL = help
FILE=VERSION
VERSION=`cat $(FILE)`

install-pip-tools:
	pip install -U pip
	pip install --upgrade pip-tools

install: install-pip-tools
	pip install  -r requirements.txt

echo-version:
	$(call ndef,VERSION)
	@echo $(VERSION)

fetch-tags:
	git fetch --tags

changelog: install
	cz changelog --unreleased-version $(VERSION)

# this will update the version, changelog, tag and commit
bump: fetch-tags install
	cz bump

bump-minor: fetch-tags install
	cz bump --increment MINOR

bump-major: fetch-tags install
	cz bump --increment MAJOR

bump-patch: fetch-tags install
	cz bump --increment PATCH

bump-alpha: fetch-tags install
	cz changelog
	cz bump --prerelease alpha
