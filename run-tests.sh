#!/bin/bash

HWAF_PKGROOT=git@github.com:mana-fwk
#HWAF_PKGROOT=`pwd`/..
DESTDIR=`pwd`/install-area
OUTDIR=`pwd`/__build__
#OUTDIR=__build__
HWAF_OS=`uname | tr 'A-Z' 'a-z'`
HWAF_VERS=`date +%Y%m%d`
echo "::: running hwaf-tests-mprojs..."

/bin/rm -rf \
    usr-test local-install install-area proj-?-*.tar.gz __build__ proj-? \
    || exit 1

echo ""
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "::: building proj-a..."
hwaf init proj-a || exit 1
pushd proj-a || exit 1
hwaf setup || exit 1
for pkg in pkg-settings pkg-aa pkg-ab pkg-ac; do
    hwaf co $HWAF_PKGROOT/hwaf-tests-$pkg $pkg || exit 1
done

hwaf configure \
    --prefix=/opt/sw/hwaf-tests-mprojs/proj-a/${HWAF_VERS} \
    --relocate-from=/opt/sw/hwaf-tests-mprojs \
    --project-version=${HWAF_VERS} \
    --destdir=${DESTDIR} \
    --out=${OUTDIR} \
    build \
    install \
    bdist \
    || exit 1
tar ztvf proj-a-x86_64-${HWAF_OS}-gcc-opt-${HWAF_VERS}.tar.gz || exit 1
hwaf run python -c 'import pkgaa' || exit 1
hwaf run python \
    -c 'import sys, os; sys.stdout.write("%s\n" % os.environ["JOBOPTPATH"])' \
    || exit 1
popd || exit 1

echo ""
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "::: building proj-b..."
hwaf init proj-b || exit 1
pushd proj-b || exit 1
hwaf setup -p=${DESTDIR}/opt/sw/hwaf-tests-mprojs/proj-a/${HWAF_VERS} || exit 1
hwaf co $HWAF_PKGROOT/hwaf-tests-pkg-ba pkg-ba || exit 1

hwaf configure \
    --prefix=/opt/sw/hwaf-tests-mprojs/proj-b/${HWAF_VERS} \
    --relocate-from=/opt/sw/hwaf-tests-mprojs \
    --project-version=${HWAF_VERS} \
    --destdir=${DESTDIR} \
    --out=${OUTDIR} \
    build \
    install \
    bdist \
    || exit 1
tar ztvf proj-b-x86_64-${HWAF_OS}-gcc-opt-${HWAF_VERS}.tar.gz || exit 1
hwaf run app-pkg-ba || exit 1
hwaf run python -c 'import sys; sys.stdout.write("%s\n"%sys.path)' || exit 1
hwaf run python -c 'import pkgba' || exit 1
hwaf run python \
    -c 'import sys, os; sys.stdout.write("%s\n" % os.environ["JOBOPTPATH"])' \
    || exit 1
popd || exit 1

echo ""
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "::: building proj-c..."
hwaf init proj-c || exit 1
pushd proj-c || exit 1
hwaf setup \
    -p=${DESTDIR}/opt/sw/hwaf-tests-mprojs/proj-b/${HWAF_VERS} \
    || exit 1
hwaf co $HWAF_PKGROOT/hwaf-tests-pkg-ca pkg-ca || exit 1

hwaf configure \
    --prefix=/opt/sw/hwaf-tests-mprojs/proj-c/${HWAF_VERS} \
    --relocate-from=/opt/sw/hwaf-tests-mprojs \
    --project-version=${HWAF_VERS} \
    --destdir=${DESTDIR} \
    --out=${OUTDIR} \
    build \
    install \
    bdist \
    || exit 1
tar ztvf proj-c-x86_64-${HWAF_OS}-gcc-opt-${HWAF_VERS}.tar.gz || exit 1
hwaf run app-pkg-ca || exit 1
hwaf run python -c 'import pkgca' || exit 1
hwaf run python \
    -c 'import sys, os; sys.stdout.write("%s\n" % os.environ["JOBOPTPATH"])' \
    || exit 1
popd || exit 1

echo ""
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "::: testing tar-balls..."
/bin/rm -rf install-area || exit 1
mkdir local-install || exit 1
for pkg in `ls -1 proj-?/proj-?-*-${HWAF_VERS}.tar.gz`; do
    tar -C ./local-install -zxf $pkg || exit 1
done
/bin/rm -rf proj-? || exit 1

hwaf init usr-test || exit 1
pushd usr-test || exit 1
hwaf setup \
    -p ../local-install/opt/sw/hwaf-tests-mprojs/proj-c/${HWAF_VERS} \
    || exit 1

hwaf co $HWAF_PKGROOT/hwaf-tests-pkg-aa pkg-aa || exit 1
hwaf configure build install \
    --project-version=${HWAF_VERS} \
    || exit 1
hwaf run python -c 'import pkgaa' || exit 1
hwaf run python -c 'import pkgba' || exit 1
hwaf run python -c 'import pkgca' || exit 1
hwaf run python \
    -c 'import sys, os; sys.stdout.write("%s\n" % os.environ["JOBOPTPATH"])' \
    || exit 1
hwaf run app-pkg-ba || exit 1
hwaf run app-pkg-ca || exit 1
popd || exit 1

echo "::: running hwaf-tests-mprojs... [done]"
## EOF ##

