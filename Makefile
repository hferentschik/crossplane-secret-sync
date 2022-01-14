# Make does not offer a recursive wildcard function, so here's one:
rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

REPO_NAME = crossplane-secret-sync
REPO_OWNER = hferentschik
BUILD_DIR := $(CURDIR)/build

REV := $(shell git rev-parse --short HEAD 2> /dev/null || echo 'unknown')
VERSION ?= $(shell echo "$$(git for-each-ref refs/tags/ --count=1 --sort=-version:refname --format='%(refname:short)' 2>/dev/null)-dev-$(REV)" | sed 's/^v//')

CHART_RELEASER = $(BUILD_DIR)/bin/cr
CHART_RELEASER_VERSION = 1.3.0
CR_TOKEN = $(GH_TOKEN)

CHART_DIR = ./charts
CHART_PACKAGE_DIR = $(BUILD_DIR)/charts

.PHONY: help
help: ## Prints this help
	@grep -E '^[^.]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-40s\033[0m %s\n", $$1, $$2}'

$(BUILD_DIR): ## Creates the output directory for all build related outputs
	@test -f $(BUILD_DIR)/bin || mkdir -p $(BUILD_DIR)/bin

.PHONY: clean
clean: ## Deletes the build output directory
	rm -rf $(BUILD_DIR)

.PHONY: helm-lint
helm-lint: ## Lints the Helm chart
	helm lint $(CHART_DIR)/$(REPO_NAME)

.PHONY: helm-package
helm-package: helm-lint ## Packages the Previews Helm Chart into BUILD_DIR
	helm dependency build $(CHART_DIR)/$(REPO_NAME)
	helm package $(CHART_DIR)/$(REPO_NAME) --app-version=${VERSION} --version=${VERSION} --destination $(CHART_PACKAGE_DIR)

.PHONY: helm-index
helm-index: $(CHART_RELEASER) ## Updates the chart
	git checkout gh-pages
	$(CHART_RELEASER) index -i ./index.yaml -r environments -o cloudbees -p $(CHART_PACKAGE_DIR) -c https://cloudbees.github.io/environments/ --token $(CR_TOKEN) --release-name-template v$(VERSION)
	git add index.yaml
	git commit -m "release $(VERSION)"
	git push origin gh-pages
	git checkout master

.PHONY: helm-release
helm-release: $(CHART_RELEASER) helm-package ## Releases the Previews Helm chart with helm-releaser to
	@$(CHART_RELEASER) upload -r $(REPO_NAME) -o $(REPO_OWNER) -p $(CHART_PACKAGE_DIR) --token $(CR_TOKEN) --release-name-template v$(VERSION)

$(CHART_RELEASER): $(BUILD_DIR) ## Find or download cr if necessary
	@{ \
	set -e ;\
	TMP_DIR=$$(mktemp -d) ;\
	target=$$(uname | tr '[:upper:]' '[:lower:]') ;\
	curl -SL https://github.com/helm/chart-releaser/releases/download/v$(CHART_RELEASER_VERSION)/chart-releaser_$(CHART_RELEASER_VERSION)_$${target}_amd64.tar.gz | tar -C $$TMP_DIR -xzf - ;\
	cp $$TMP_DIR/cr $(CHART_RELEASER) ;\
	rm -rf $$TMP_DIR ;\
	}
