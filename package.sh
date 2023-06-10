#!/bin/bash

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CERTBOT_VERSION=$( awk -F= '$1 == "certbot"{ print $NF; }' "${SCRIPT_DIR}/requirements.txt" )
readonly VENV="certbot/venv"
readonly PYTHON="python3.10"
readonly CERTBOT_ZIP_FILE="certbot-${CERTBOT_VERSION}.zip"
#readonly CERTBOT_SITE_PACKAGES=${VENV}/lib/${PYTHON}/site-packages
readonly CERTBOT_TARGET=certbot/deps

cd "${SCRIPT_DIR}"
rm -rf certbot
mkdir -p ${CERTBOT_TARGET}

${PYTHON} -m venv "${VENV}"
source "${VENV}/bin/activate"

pip3 install \
  --target=${CERTBOT_TARGET} \
  --platform manylinux2014_x86_64 \
  --only-binary=:all: \
  -r requirements.txt

deactivate
rm -rf ${VENV}

pushd ${CERTBOT_TARGET}
    zip -r -q ${SCRIPT_DIR}/certbot/${CERTBOT_ZIP_FILE} . -x "/*__pycache__/*"
popd

#pushd ${CERTBOT_SITE_PACKAGES}
#    zip -r -q ${SCRIPT_DIR}/certbot/${CERTBOT_ZIP_FILE} . -x "/*__pycache__/*"
#popd

zip -g "certbot/${CERTBOT_ZIP_FILE}" main.py
