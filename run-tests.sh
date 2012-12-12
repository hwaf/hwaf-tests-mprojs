#!/bin/bash

DESTDIR=`pwd`/install-area
OUTDIR=`pwd`/__build__
#OUTDIR=__build__
HWAF_OS=`uname | tr 'A-Z' 'a-z'`

echo "::: running hwaf-tests-mprojs..."

/bin/rm -rf install-area proj-?-*.tar.gz __build__ proj-?

echo "::: building proj-a..."
hwaf init proj-a || exit 1
pushd proj-a || exit 1
hwaf setup || exit 1
for pkg in pkg-settings pkg-aa pkg-ab pkg-ac; do
    hwaf co git@github.com:mana-fwk/hwaf-tests-$pkg $pkg || exit 1
done

hwaf configure \
    --prefix=/opt/sw/hwaf-tests-mprojs/proj-a \
    --destdir=${DESTDIR} \
    --out=${OUTDIR} \
    build \
    install \
    bdist \
    || exit 1
tar ztvf proj-a-x86_64-${HWAF_OS}-gcc-opt-0.0.1.tar.gz || exit 1

popd || exit 1

echo "::: building proj-b..."
hwaf init proj-b || exit 1
pushd proj-b || exit 1
hwaf setup -p=${DESTDIR}/opt/sw/hwaf-tests-mprojs/proj-a || exit 1
hwaf co git@github.com:mana-fwk/hwaf-tests-pkg-ba pkg-ba || exit 1

hwaf configure \
    --prefix=/opt/sw/hwaf-tests-mprojs/proj-b \
    --destdir=${DESTDIR} \
    --out=${OUTDIR} \
    build \
    install \
    bdist \
    || exit 1
tar ztvf proj-b-x86_64-${HWAF_OS}-gcc-opt-0.0.1.tar.gz || exit 1

popd || exit 1

echo "::: building proj-c..."
hwaf init proj-c || exit 1
pushd proj-c || exit 1
hwaf setup -p=${DESTDIR}/opt/sw/hwaf-tests-mprojs/proj-b || exit 1
hwaf co git@github.com:mana-fwk/hwaf-tests-pkg-ca pkg-ca || exit 1

hwaf configure \
    --prefix=/opt/sw/hwaf-tests-mprojs/proj-c \
    --destdir=${DESTDIR} \
    --out=${OUTDIR} \
    build \
    install \
    bdist \
    || exit 1
tar ztvf proj-c-x86_64-${HWAF_OS}-gcc-opt-0.0.1.tar.gz || exit 1

popd || exit 1

echo "::: running hwaf-tests-mprojs... [done]"
## EOF ##

