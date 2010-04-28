#!/bin/sh

object="$1"
shift 1

STAGE_LIBDIR="${MK_STAGE_DIR}${MK_LIBDIR}"

COMBINED_LIBDEPS="$LIBDEPS"
COMBINED_LDFLAGS="$LDFLAGS -L${STAGE_LIBDIR}"
COMBINED_LIBDIRS="$LIBDIRS"

case "${MK_OS}" in
    linux)
	COMBINED_LDFLAGS="$COMBINED_LDFLAGS -Wl,-rpath,${MK_LIBDIR} -Wl,-rpath-link,${STAGE_LIBDIR}"
	;;
esac

for _group in ${GROUPS}
do
    unset OBJECTS LIBDEPS LIBDIRS LDFLAGS
    _dirname="`dirname "$_group"`"
    mk_safe_source "${MK_OBJECT_DIR}${MK_SUBDIR}/$_group" || mk_fail "Could not read group $_group"


    GROUP_OBJECTS="$GROUP_OBJECTS ${OBJECTS}"
    COMBINED_LIBDEPS="$COMBINED_LIBDEPS $LIBDEPS"
    COMBINED_LIBDIRS="$COMBINED_LIBDIRS $LIBDIRS"
    COMBINED_LDFLAGS="$COMBINED_LDFLAGS $LDFLAGS"
done

for lib in ${COMBINED_LIBDEPS}
do
    COMBINED_LDFLAGS="$COMBINED_LDFLAGS -l${lib}"
done

MK_MSG_DOMAIN="link"

mk_msg "${object#${MK_STAGE_DIR}}"
mk_mkdir "`dirname "$object"`"
case "$MODE" in
    library)
	_mk_try ${MK_CC} -shared -o "$object" "$@" ${GROUP_OBJECTS} ${MK_LDFLAGS} ${COMBINED_LDFLAGS} -fPIC
	;;
    dso)
	_mk_try ${MK_CC} -shared -o "$object" "$@" ${GROUP_OBJECTS} ${MK_LDFLAGS} ${COMBINED_LDFLAGS} -fPIC
	;;
    program)
	_mk_try ${MK_CC} -o "$object" "$@" ${GROUP_OBJECTS} ${MK_LDFLAGS} ${COMBINED_LDFLAGS}
	;;
esac
