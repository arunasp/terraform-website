
PWD = $(shell pwd)
ARGC := $(shell printf $(words $(MAKECMDGOALS)))
MAKE_TARGETS := $(shell $(PWD)/configure.sh help | grep ' - ' | awk '{FS="-"; ORS=" ";print $$1}' | xargs echo)
ARGV := $(wordlist 1,$(ARGC),$(MAKECMDGOALS))

help:	## display this help
			@help=$$($(PWD)/configure.sh help | (printf "\n";grep ' - ') | \
			awk 'BEGIN {printf "\nUsage:\n%-6smake \033[36m<target> <component> <target arguments>\033[0m\n\nTargets:\n", ""}; \
			{FS="-";{printf "\033[36m%-16s\033[0m %s\n", $$1, $$2;}; \
			for(i=3; i<=NF; i++) printf "%s",$$i (i==NF?ORS:OFS)} END {print ""}'); \
			printf "$${help}\n\n"

configure:
			@cd $(PWD)
			@$(PWD)/configure.sh $(ARGV)

$(MAKE_TARGETS): configure


%:
			@:

.PHONY: %:
.DEFAULT_GOAL:=help
.PHONY: $(MAKE_TARGETS) website
.DEFAULT_GOAL:=help
