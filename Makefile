WEAVER_CONTAINER=otel/weaver:v0.13.2
GITHUB_REPO := AndreReise/weaver-dotnet-example
LATEST_RELEASED_VERSION := $(shell git ls-remote --tags https://github.com/${GITHUB_REPO}.git | cut -f 2 | sort --reverse | head -n 1 | tr '/' ' ' | cut -d ' ' -f 3 | $(SED) 's/v//g')

generate-csharp:
	mkdir -p $(PWD)/Source/Application/Telemetry
	docker run --rm \
		--mount 'type=bind,source=$(PWD)/Contracts/Telemetry,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/Weaver/Templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/Source/Application/Telemetry,target=/home/weaver/target' \
		${WEAVER_CONTAINER} registry generate \
		--registry=/home/weaver/source \
		csharp \
		--future \
		/home/weaver/target

generate-specification:
	mkdir -p $(PWD)/Documentation
	docker run  --rm \
		--mount 'type=bind,source=$(PWD)/Contracts/Telemetry,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/Weaver/Templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/Documentation,target=/home/weaver/target' \
		${WEAVER_CONTAINER} registry generate \
		--registry=/home/weaver/source \
		markdown \
		--future \
		/home/weaver/target

validate:
	docker run --rm \
		--mount 'type=bind,source=$(PWD)/Contracts/Telemetry,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/Weaver/Templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/Weaver/Policies,target=/home/weaver/policies' \
		${WEAVER_CONTAINER} registry check \
		--registry=/home/weaver/source \
		-p policies/ \
		--future \

regression:
	docker run --rm \
		--mount 'type=bind,source=$(PWD)/Contracts/Telemetry,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/Weaver/Templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/Weaver/Policies,target=/home/weaver/policies' \
		${WEAVER_CONTAINER} registry check \
        --baseline-registry=https://github.com/${GITHUB_REPO}/archive/refs/tags/v$(LATEST_RELEASED_VERSION).zip[Contracts/Telemetry] \
		--registry=/home/weaver/source \
		-p policies/ \
		--future \

diff:
	docker run --rm \
		$(DOCKER_USER_IS_HOST_USER_ARG) \
		--mount 'type=bind,source=$(PWD)/Contracts/Telemetry,target=/home/weaver/source,readonly' \
		--mount 'type=bind,source=$(PWD)/Weaver/Templates,target=/home/weaver/templates,readonly' \
		--mount 'type=bind,source=$(PWD)/Weaver/Policies,target=/home/weaver/policies' \
		${WEAVER_CONTAINER} registry diff \
        --baseline-registry=https://github.com/${GITHUB_REPO}/archive/refs/tags/v$(LATEST_RELEASED_VERSION).zip[Contracts/Telemetry] \
        --diff-format ansi \
		--registry=/home/weaver/source \
		--future \
