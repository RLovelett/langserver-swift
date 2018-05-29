UNAME := $(shell uname)

ifeq ($(UNAME), Linux)
DefaultBuildFlags=
else ifeq ($(UNAME), Darwin)
DefaultBuildFlags=-Xswiftc -target -Xswiftc x86_64-apple-macosx10.12
endif
DebugBuildFlags=$(DefaultBuildFlags)
ReleaseBuildFlags=$(DefaultBuildFlags) -Xswiftc -static-stdlib -c release
INSTALL_PATH?=/usr/local

.PHONY: debug
## Build the package in debug
debug:
	swift build $(DebugBuildFlags)

.PHONY: release
## Build the package in release
release:
	swift build $(ReleaseBuildFlags)

.PHONY: clean
## Clean the package of build information
clean:
	rm -rf .build

.PHONY: install
## Install the release version of the package
install: release
	cp -f .build/release/langserver-swift $(INSTALL_PATH)/bin/langserver-swift

.PHONY: uninstall
## Undo the effects of install
uninstall:
	rm -r $(INSTALL_PATH)/bin/langserver-swift

.PHONY: test
## Build and run the tests
test:
	swift test $(DebugBuildFlags)

.PHONY: xcodeproj
## Generate the Xcode project
xcodeproj:
	swift package generate-xcodeproj --enable-code-coverage --xcconfig-overrides settings.xcconfig

.PHONY: print_target_build_dir
## Print Xcode project's TARGET_BUILD_DIR value to use for debugging purposes
print_target_build_dir: xcodeproj
	xcodebuild -project langserver-swift.xcodeproj -target "LanguageServer" -showBuildSettings | grep "TARGET_BUILD_DIR"

.PHONY: ci
## Operations to run for Continuous Integration
ifeq ($(UNAME), Linux)
ci: tools_versions debug test
else ifeq ($(UNAME), Darwin)
ci: tools_versions debug test release
endif

.PHONY: tools_versions
## Print the tools versions to STDOUT
tools_versions:
	swift --version
	swift build --version

.PHONY: help
# taken from this gist https://gist.github.com/rcmachado/af3db315e31383502660
## Show this help message.
help:
	$(info Usage: make [target...])
	$(info Available targets)
	@awk '/^[a-zA-Z\-\_0-9]+:/ {                    \
		nb = sub( /^## /, "", helpMsg );              \
		if(nb == 0) {                                 \
			helpMsg = $$0;                              \
			nb = sub( /^[^:]*:.* ## /, "", helpMsg );   \
		}                                             \
		if (nb)                                       \
			print  $$1 "\t" helpMsg;                    \
	}                                               \
	{ helpMsg = $$0 }'                              \
	$(MAKEFILE_LIST) | column -ts $$'\t' |          \
	grep --color '^[^ ]*'
