#!/bin/bash -e

set -e
cd "$(dirname $0)"

function usage() {
  cat << ENDOFM
bash buildAll.sh [variableFile.json]
    ex: bash buildAll.sh ~/Secrets/packer/cdistest.json
ENDOFM
}

# override by command-line
PACKER_VARIABLES="variables.json"

if [ "$#" != "0" ]; then
  PACKER_VARIABLES=$1
fi

if [ ! -f "${PACKER_VARIABLES}" ]; then
    echo "json file defining variables for packer does not exist: ${PACKER_VARIABLES}"
    echo "check README.md"
    usage
    exit 1
fi


function packer_build_image() {
    #
    # Stole this from the cloud-automation repo.
    # Attempt to build the image file $1 using packer. If this runs into errors,
    # print the error output from packer and exit 1. Otherwise, return the ID of
    # the Amazon Machine Image (AMI) built.
    #
    packer_output="$(packer build --var-file $PACKER_VARIABLES --var-file source.json -machine-readable images/$1)"
    #packer_output=bla
    packer_errors="$(echo "$packer_output" | egrep '^.*,.*,.*,error' | cut -d ',' -f 5-)"
    if [[ -n $packer_errors ]]; then
        echo "packer failed to build image: $1" >&2
        echo -e "$packer_errors" >&2
        exit 1
    fi
    echo "$packer_output" | egrep 'artifact,0,id' | rev | cut -d ',' -f 1 | rev | cut -d ':' -f 2
}


if [ -z "$SOURCE_AMI" ]; then
  if [ ! -f source.json ]; then
    cat > source.json << EOM
{
  "bla":"bla"
}
EOM
  fi

  echo "Building packer base image"
  SOURCE_AMI="$(packer_build_image base_image.json)"
  [ $? == 1 ] && exit 1;
  echo "Base ami is $SOURCE_AMI"
  # Fill in the source_ami packer variable. (Note that the packer variables
  # file can't be read from and redirected to in the same step.)
fi

cat > source.json << EOM
{
  "source_ami":"${SOURCE_AMI}"
}
EOM

if [ -z "$CLIENT_AMI" ]; then
  echo "Building packer client image"
  CLIENT_AMI="$(packer_build_image client.json)"
  [ $? == 1 ] && exit 1;
  echo "Client ami is $CLIENT_AMI"
fi

if [ -z "$PROXY_AMI" ]; then
  echo "Building packer squid image"
  PROXY_AMI="$(packer_build_image squid_image.json)"
  [ $? == 1 ] && exit 1;
  echo "Proxy ami is $PROXY_AMI"
fi


if [ -z "$UBUNTU_BASE" ]; then
  echo "Building packer ubuntu16_base image"
  UBUNTU_BASE="$(packer_build_image ubuntu16_docker.json)"
  [ $? == 1 ] && exit 1;
  echo "ubuntu16_base ami is $UBUNTU_BASE"
  export ub16_source_ami="$UBUNTU_BASE"
fi

if [ -z "$UBUNTU_CLIENT" ]; then
  echo "Building packer ubuntu16_client image"
  UBUNTU_CLIENT="$(packer_build_image ubuntu16_client.json)"
  [ $? == 1 ] && exit 1;
  echo "ubuntu16_client ami is $UBUNTU_CLIENT"
fi

cat > source.json << EOM
{
  "SOURCE_AMI":"${SOURCE_AMI}",
  "CLIENT_AMI":"${CLIENT_AMI}",
  "PROXY_AMI":"${PROXY_AMI}",
  "UBUNTU_BASE":"${UBUNTU_BASE}",
  "UBUNTU_CLIENT":"${UBUNTU_CLIENT}"
}
EOM

