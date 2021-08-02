
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

.PHONY: pkg-rpm-client
pkg-rpm-client:
	./hack/pkg_rpm_client.sh

.PHONY: pkg-rpm-server
pkg-rpm-server:
	./hack/pkg_rpm_server.sh

.PHONY: pkg-deb-client
pkg-deb-client:
	./hack/pkg_deb_client.sh

.PHONY: pkg-deb-server
pkg-deb-server:
	./hack/pkg_deb_server.sh

.PHONY: build-image
build-image:
	@echo Build image
	./hack/build_image.sh

.PHONY: verify
verify: verify-patch

.PHONY: verify-patch
verify-patch: 
	./hack/verify_patch.sh

.PHONY: verify-patch-format
verify-patch-format: 
	./hack/verify_patch_format.sh

.PHONY: verify-build
verify-build: 
	./hack/verify_build.sh

.PHONY: verify-build-client
verify-build-client: 
	./hack/verify_build_client.sh

.PHONY: verify-build-server
verify-build-server: 
	./hack/verify_build_server.sh

.PHONY: verify-pkg-rpm-client
verify-pkg-rpm-client:
	./hack/verify_pkg_rpm_client.sh

.PHONY: verify-pkg-rpm-server
verify-pkg-rpm-server:
	./hack/verify_pkg_rpm_server.sh

.PHONY: verify-pkg-deb-client
verify-pkg-deb-client:
	./hack/verify_pkg_deb_client.sh

.PHONY: verify-pkg-deb-server
verify-pkg-deb-server:
	./hack/verify_pkg_deb_server.sh

.PHONY: verify-build-image
verify-build-image: 
	./hack/verify_build_image.sh

.PHONY: gen-verify-workflows
gen-verify-workflows:
	./hack/gen_verify_workflows.sh > .github/workflows/verify.yml

.PHONY: push-image
push-image:
	./hack/image_tag.sh && ./hack/image_push.sh && ./hack/image_manifest_push.sh

.PHONY: format-all-patch
format-all-patch:
	./hack/format_all_patch.sh

.PHONY: test
test:
	./hack/test.sh

.PHONY: test-cmd
test-cmd:
	./hack/install_etcd.sh
	./hack/test_cmd.sh

.PHONY: test-integration
test-integration:
	./hack/install_etcd.sh
	./hack/test_integration.sh

.PHONY: test-e2e
test-e2e:
	./hack/test_e2e.sh

.PHONY: test-e2e-node
test-e2e-node:
	./hack/test_e2e_node.sh
