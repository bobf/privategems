.PHONY: test
test:
	bundle exec rspec
	bundle exec rubocop
	bundle exec strong_versions

.PHONY: build
build:
	docker build . --tag privategems/privategems

.PHONY: push
push:
	docker push privategems/privategems

# Development server
.PHONY: server
server: export GEMINABOX_DATA_PATH ?= /tmp/geminabox/
server: export GEMINABOX_USERS_PATH ?= /tmp/geminabox_users.yml
server: export SECRET_KEY_BASE := not-so-secret
server: export RACK_ENV := development
server:
	cp spec/fixtures/users.yml ${GEMINABOX_USERS_PATH}
	bundle exec rackup config.ru

# Test pushing a gem to local server
.PHONY: gem-push
gem-push:
	gem push development/demo/demo-0.1.0.gem
