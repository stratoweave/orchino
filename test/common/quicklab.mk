build-otron-image:
	docker build -t orchino-otron-base -f ../common/Dockerfile.otron .

.PHONY: start
start: build-otron-image
	$(CLAB_BIN) deploy --topo $(TESTENV:orchino-%=%).clab.yml --log-level debug --reconfigure

.PHONY: stop
stop:
	$(CLAB_BIN) destroy --topo $(TESTENV:orchino-%=%).clab.yml --log-level debug

.PHONY: wait $(addprefix wait-,$(ROUTERS_XR))
WAIT?=60
wait: $(addprefix platform-wait-,$(ROUTERS_XR))

.PHONY: copy
copy:
	docker cp ../../out/bin/orchino $(TESTENV)-otron:/orchino
	docker cp netinfra.xml $(TESTENV)-otron:/netinfra.xml

.PHONY: run
run:
	docker exec $(INTERACTIVE) $(TESTENV)-otron /orchino --rts-bt-dbg

ifndef CI
INTERACTIVE=-it
endif

.PHONY: run-and-configure
run-and-configure:
	docker exec $(INTERACTIVE) -e EXIT_ON_DONE=$(CI) $(TESTENV)-otron /orchino netinfra.xml --rts-bt-dbg

.PHONY: configure
configure:
	$(MAKE) send-config-wait FILE="netinfra.xml"

.PHONY: shell
shell:
	docker exec -it $(TESTENV)-otron bash -l

.PHONY: send-config-async
send-config-async:
	curl -X PUT -H "Content-Type: application/yang-data+xml" -H "Async: true" -d @$(FILE) http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/restconf

.PHONY: send-config-wait
send-config-wait:
	curl -X PUT -H "Content-Type: application/yang-data+xml" -d @$(FILE) http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/restconf

.PHONY: get-config0 get-config1 get-config2
get-config0 get-config1 get-config2:
	curl -H "Accept: application/yang-data+xml" http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/layer/$(subst get-config,,$@)

.PHONY: get-config-adata0 get-config-adata1 get-config-adata2
get-config-adata0 get-config-adata1 get-config-adata2:
	@curl -H "Accept: application/yang-data+acton-adata" http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/layer/$(subst get-config-adata,,$@)

# Default headers for XML configuration
HEADERS?=-H "Accept: application/yang-data+xml"

# "target" is the Orchestron's intended configuration, i.e. the configuration
# *we* want on the device. Note how this is not NMDA-speak for "intended
# configuration" of the device itself.
.PHONY: $(addprefix get-target-,$(ROUTERS_XR))
$(addprefix get-target-,$(ROUTERS_XR)):
	@curl $(HEADERS) http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/device/$(subst get-target-,,$@)/target

.PHONY: $(addprefix get-target-adata-,$(ROUTERS_XR))
$(addprefix get-target-adata-,$(ROUTERS_XR)):
	@$(MAKE) HEADERS="-H \"Accept: application/yang-data+acton-adata\"" $(subst adata-,,$@)

# "running" is the currently running configuration on the device, which in
# NMDA-speak is the "intended configuration".
.PHONY: $(addprefix get-running-,$(ROUTERS_XR))
$(addprefix get-running-,$(ROUTERS_XR)):
	@curl $(HEADERS) http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/device/$(subst get-running-,,$@)/running

.PHONY: $(addprefix get-running-adata-,$(ROUTERS_XR))
$(addprefix get-running-adata-,$(ROUTERS_XR)):
	@$(MAKE) HEADERS="-H \"Accept: application/yang-data+acton-adata\"" $(subst adata-,,$@)

.PHONY: $(addprefix get-running-diff-,$(ROUTERS_XR))
$(addprefix get-running-diff-,$(ROUTERS_XR)):
	@curl $(HEADERS) http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/device/$(subst get-running-diff-,,$@)/diff

.PHONY: $(addprefix resync-,$(ROUTERS_XR))
$(addprefix resync-,$(ROUTERS_XR)):
	@curl $(HEADERS) http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/device/$(subst resync-,,$@)/resync

.PHONY: delete-config
delete-config:
	curl -X DELETE http://localhost:$(shell docker inspect -f '{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' $(TESTENV)-otron)/restconf/netinfra:netinfra/routers=STO-CORE-1

.PHONY: $(addprefix cli-,$(ROUTERS_XR))
$(addprefix cli-,$(ROUTERS_XR)): cli-%: platform-cli-%

.PHONY: $(addprefix get-dev-config-,$(ROUTERS_XR))
$(addprefix get-dev-config-,$(ROUTERS_XR)):
	docker run $(INTERACTIVE) --rm --network container:$(TESTENV)-otron ghcr.io/notconf/notconf:debug netconf-console2 --host $(@:get-dev-config-%=%) --port 830 --user clab --pass clab@123 --get-config

.PHONY: test
test:
	$(MAKE) test-get-config

.PHONY: test-get-config
test-get-config:
	$(MAKE) $(addprefix get-dev-config-,$(ROUTERS_XR))

.PHONY: save-logs
save-logs: $(addprefix save-logs-,$(ROUTERS_XR))

.PHONY: $(addprefix save-logs-,$(ROUTERS_XR))
$(addprefix save-logs-,$(ROUTERS_XR)):
	mkdir -p logs
	docker logs --timestamps $(TESTENV)-$(@:save-logs-%=%) > logs/$(@:save-logs-%=%)_docker.log 2>&1
	$(MAKE) get-dev-config-$(@:save-logs-%=%) > logs/$(@:save-logs-%=%)_netconf.log || true
