#!/bin/sh

. ../jenkins-common.sh
IMAGE_SUFFIX="${IMAGE_SUFFIX:-master}"
docker_images_require \
	"osmo-stp-$IMAGE_SUFFIX" \
	"osmo-hnbgw-$IMAGE_SUFFIX" \
	"ttcn3-hnbgw-test"

set_clean_up_trap
set -e

VOL_BASE_DIR_PFCP="$VOL_BASE_DIR/with-pfcp"
clean_up() {
	# append ':with-pfcp' to the classnames,
	# e.g. "classname='HNBGW_Tests'" => "classname='HNBGW_Tests:with-pfcp'"
	# so the with-pfcp test cases would not interfere without pfcp ones in Jenkins
	sed -i "s/classname='\([^']\+\)'/classname='\1:with-pfcp'/g" \
		$VOL_BASE_DIR_PFCP/hnbgw-tester/junit-xml-with-pfcp-*.log
}

network_create

run_tests() {
	base_dir="$1"
	tests_cfg="$2"
	stp_cfg="$3"
	hnbgw_cfg="$4"

	mkdir $base_dir/hnbgw-tester
	mkdir $base_dir/hnbgw-tester/unix
	cp "$tests_cfg" $base_dir/hnbgw-tester/
	write_mp_osmo_repo "$base_dir/hnbgw-tester/HNBGW_Tests.cfg"
	# Can be removed once a new release osmo-hnbgw > 1.4.0 is avilable:
	if ! image_suffix_is_master; then
		sed -i 's/HNBGW_Tests.mp_validate_talloc_asn1 := true/HNBGW_Tests.mp_validate_talloc_asn1 := false/g' "$base_dir/hnbgw-tester/HNBGW_Tests.cfg"
	fi

	mkdir $base_dir/stp
	cp "$stp_cfg" $base_dir/stp/osmo-stp.cfg

	mkdir $base_dir/hnbgw
	mkdir $base_dir/hnbgw/unix
	cp "$hnbgw_cfg" $base_dir/hnbgw/osmo-hnbgw.cfg

	mkdir $base_dir/unix

	network_replace_subnet_in_configs

	echo Starting container with STP
	docker run	--rm \
			$(docker_network_params $SUBNET 200) \
			--ulimit core=-1 \
			-v $base_dir/stp:/data \
			--name ${BUILD_TAG}-stp -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-stp-$IMAGE_SUFFIX

	echo Starting container with HNBGW
	docker run	--rm \
			$(docker_network_params $SUBNET 20) \
			--ulimit core=-1 \
			-v $base_dir/hnbgw:/data \
			-v $base_dir/unix:/data/unix \
			--name ${BUILD_TAG}-hnbgw -d \
			$DOCKER_ARGS \
			$REPO_USER/osmo-hnbgw-$IMAGE_SUFFIX

	echo Starting container with HNBGW testsuite
	docker run	--rm \
			$(docker_network_params $SUBNET 203) \
			--ulimit core=-1 \
			-e "TTCN3_PCAP_PATH=/data" \
			-v $base_dir/hnbgw-tester:/data \
			-v $base_dir/unix:/data/unix \
			--name ${BUILD_TAG}-ttcn3-hnbgw-test \
			$DOCKER_ARGS \
			$REPO_USER/ttcn3-hnbgw-test

	echo Stopping containers
	docker_kill_wait ${BUILD_TAG}-hnbgw
	docker_kill_wait ${BUILD_TAG}-stp
}

osmo_stp_cfg="osmo-stp.cfg"
osmo_hnbgw_cfg="osmo-hnbgw.cfg"
osmo_hnbgw_with_pfcp_cfg="with-pfcp/osmo-hnbgw.cfg"

if image_suffix_is_latest; then
	osmo_stp_cfg="osmo-stp-legacy.cfg"
	osmo_hnbgw_cfg="osmo-hnbgw-legacy.cfg"
	osmo_hnbgw_with_pfcp_cfg="with-pfcp/osmo-hnbgw-legacy.cfg"
fi

echo Testing without PFCP
run_tests "$VOL_BASE_DIR" "HNBGW_Tests.cfg" $osmo_stp_cfg $osmo_hnbgw_cfg

echo Testing with PFCP
mkdir "$VOL_BASE_DIR_PFCP"
run_tests "$VOL_BASE_DIR_PFCP" "with-pfcp/HNBGW_Tests.cfg" $osmo_stp_cfg $osmo_hnbgw_with_pfcp_cfg
