
v%:
	@echo Checkout to $@
	./hack/checkout.sh $@

dependent:
	pip3 install yq

.PHONY: build-client
build-client:
	@echo Build client
	./hack/build_client.sh

.PHONY: build-server
build-server:
	@echo Build server
	./hack/build_server.sh

.PHONY: build-image
build-image:
	@echo Build image
	./hack/build_image.sh

.PHONY: verify
verify: verify-patch

.PHONY: verify-patch
verify-patch: 
	./hack/verify_patch.sh