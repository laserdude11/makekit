#!/bin/sh

. "${MK_HOME}/mk.sh" || exit 1
mk_import

_mk_args

_object="$1"
_source="$2"

EXTRA_CPPFLAGS="-I${MK_STAGE_DIR}${MK_INCLUDE_DIR} -DHAVE_CONFIG_H"

for _dir in ${INCLUDEDIRS}
do
    EXTRA_CPPFLAGS="$EXTRA_CPPFLAGS -I${MK_SOURCE_DIR}${MK_SUBDIR}/$_dir -I${MK_OBJECT_DIR}${MK_SUBDIR}/$_dir"
done

MK_LOG_DOMAIN="compile"

mk_log "${_source#${MK_SOURCE_DIR}/}"
_mk_try mkdir -p "`dirname "$_object"`" "${MK_ROOT_DIR}/.MetaKitDeps"
_mk_try gcc \
    ${MK_CPPFLAGS} ${CPPFLAGS} ${EXTRA_CPPFLAGS} \
    ${MK_CFLAGS} ${CFLAGS} \
    -MMD -MP -MF "${MK_ROOT_DIR}/.MetaKitDeps/`echo ${_object%.o} | tr / _`.dep" \
    -o "$_object" \
    -c "$_source"
