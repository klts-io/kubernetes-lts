
v%:
	@echo Checkout to $@
	./hack/checkout.sh $@

dependent:
	pip3 install yq
	./hack/git_init_workdir.sh

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

.PHONY: verify-build
verify-build: 
	./hack/verify_build.sh

.PHONY: verify-build-client
verify-build-client: 
	./hack/verify_build_client.sh

.PHONY: verify-build-server
verify-build-server: 
	./hack/verify_build_server.sh

.PHONY: verify-build-image
verify-build-image: 
	./hack/verify_build_image.sh

.PHONY: gen-verify-build-workflows
gen-verify-build-workflows:
	./hack/gen_verify_build.sh > .github/workflows/verify-build.yml

.PHONY: push-image
push-image:
	./hack/image_tag.sh && ./hack/image_push.sh
