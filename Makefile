# This target is executed whenever we just type `make`
.DEFAULT_GOAL = help
FILE=VERSION
VERSION=`cat $(FILE)`
ENV_FILE=.env

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

changelog: setup-dev-env
	cz changelog --unreleased-version $(VERSION)

# this will update the version, changelog, tag and commit
bump: fetch-tags setup-dev-env
	cz bump

bump-minor: fetch-tags setup-dev-env
	cz bump --increment MINOR

bump-major: fetch-tags setup-dev-env
	cz bump --increment MAJOR

bump-patch: fetch-tags setup-dev-env
	cz bump --increment PATCH
