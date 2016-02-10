# - Try to find LibClingo

#find_path(LIBCLINGO_INCLUDE_DIR NAMES clingocontrol PATHS "${CLINGO_BUILDDIR}/libclingo/clingo")
#find_library(LIBCLINGO_LIBRARY NAMES libclingo PATHS "${CLINGO_BUILDDIR}/build/release")

#workaround:
set(LIBCLINGO_LIBRARY "${CLINGO_BUILDDIR}/build/release/libclingo.so")
set(LIBCLINGO_INCLUDE_DIR "${CLINGO_BUILDDIR}/libclingo/")

set(LIBCLINGO_LIBRARIES ${LIBCLINGO_LIBRARY} )
set(LIBCLINGO_INCLUDE_DIRS ${LIBCLINGO_INCLUDE_DIR} )
LIST(APPEND LIBCLINGO_INCLUDE_DIRS "${CLINGO_BUILDDIR}/libgringo" "${CLINGO_BUILDDIR}/libclasp" "${CLINGO_BUILDDIR}/libprogram_opts")

#message (${LIBCLINGO_LIBRARIES})
#message (${LIBCLINGO_INCLUDE_DIRS})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set LIBCLINGO_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(LibClingo  DEFAULT_MSG
                                  LIBCLINGO_LIBRARY LIBCLINGO_INCLUDE_DIR)

mark_as_advanced(LIBCLINGO_INCLUDE_DIR LIBCLINGO_LIBRARY )
