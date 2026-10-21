.PHONY: validate lint test audit

validate: lint test audit

lint:
	shellcheck scripts/*.sh test/*.sh
	actionlint

test:
	test/audit-pins.test.sh
	test/audit-permissions.test.sh

audit:
	scripts/audit-pins.sh
	scripts/audit-permissions.sh
