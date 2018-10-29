# Distributed under the OpenDDS License. See accompanying LICENSE
# file or http://www.opendds.org/license.html for details.

#.rst:
# FindOpenDDS
# -----------
#
# Finds OpenDDS include dirs and libraries
#
# This module defines the following variables::
#
# OPENDDS_FOUND - True if OpenDDS (and all primary dependencies) were found.
# OPENDDS_INCLUDE_DIRS - Primary include directories used by OpenDDS.
# OPENDDS_LIBRARIES - List of all OpenDDS-Imported targets.
# OPENDDS_VERSION - Full OpenDDS version string.
# OPENDDS_VERSION_MAJOR - Major version of OpenDDS.
# OPENDDS_VERSION_MINOR - Minor version of OpenDDS.
# OPENDDS_VERSION_PATCH - Patch version of OpenDDS.
#
# The following imported targets will be defined if the corresponding libraries
# were compiled with OpenDDS (using MPC):
#
#   OpenDDS::OpenDDS - Convenience target which will loop-in most targets required
#                      for a typical OpenDDS scenario:
#                        * OpenDDS::Dcps
#                        * OpenDDS::Multicast
#                        * OpenDDS::Rtps
#                        * OpenDDS::Rtps_Udp
#                        * OpenDDS::InfoRepoDiscovery
#                        * OpenDDS::Shmem
#                        * OpenDDS::Tcp
#                        * OpenDDS::Udp
#
#   OpenDDS::<LIB>   - Target for specific library dependency that was generated by
#                      compiling OpenDDS. These will generally be located in the
#                      $DDS_ROOT/lib directory. For example, OpenDDS_Dcps(d).so/.dll
#                      will be imported as the OpenDDS::Dcps CMake target.
#
#   ACE::ACE         - Target for the core ACE library.
#
#   ACE::<LIB>       - Similar to OpenDDS::<LIB> except typically these sit in the
#                      $ACE_ROOT/lib directory with files like ACE_XML_Utils(d).so/.dll
#                      getting imported as ACE::XML_Utils.
#
#   TAO::TAO         - Target for the core TAO library.
#
#   TAO::<LIB>       - Similar to OpenDDS::<LIB> except typically these sit in the
#                      $ACE_ROOT/lib directory (note: not $TAO_ROOT/lib) with files like
#                      TAO_PortableServer(d).so/.dll getting imported as TAO::PortableServer.
#
# In addition to the imported targets above the following macro will be important
# for adding IDL sources (and other C/C++ sources if desired) to a given target.
#
# OPENDDS_TARGET_SOURCES(target
#   [items...]
#   [<INTERFACE|PUBLIC|PRIVATE> items...]
#   [TAO_IDL_OPTIONS options...]
#   [OPENDDS_IDL_OPTIONS options...])
#
# This macro behaves similarly to target_sources(...) with the following
# differences:
#   1) Items can be either C/C++ sources or IDL sources.
#   2) The scope-qualifier (PUBLIC, PRIVATE, INTERFACE) is not required.
#      When it is omitted, PUBLIC is used by default.
#   3) Command-line options can be supplied to the TAO/OpenDDS IDL compilers
#      using TAO_IDL_OPTIONS and/or OPENDDS_IDL_OPTIONS (if the default be-
#      havior is not suitable).
#
# When IDL sources are supplied, custom commands are generated which will
# be invoked to compile the IDL sources into their component cpp/h files.
#
# A custom command will also be added to generate the required IDL export
# header file (*target*_export.h) to add the required export macros. This
# file is then added as a dependency for the supplied target.
#

cmake_minimum_required(VERSION 3.3.2)

set(_OPENDDS_FIND_MODULE_DIR ${CMAKE_CURRENT_LIST_DIR})

include(${_OPENDDS_FIND_MODULE_DIR}/FindOpenDDS/config.cmake)

set(_OPENDDS_RELATIVE_SOURCE_ROOT "${_OPENDDS_FIND_MODULE_DIR}/../../..")
set(_OPENDDS_RELATIVE_PREFIX_ROOT "${_OPENDDS_FIND_MODULE_DIR}/../../..")

get_filename_component(_OPENDDS_RELATIVE_SOURCE_ROOT
  ${_OPENDDS_RELATIVE_SOURCE_ROOT} ABSOLUTE)

get_filename_component(_OPENDDS_RELATIVE_PREFIX_ROOT
  ${_OPENDDS_RELATIVE_PREFIX_ROOT} ABSOLUTE)

macro(_OPENDDS_RETURN_ERR msg)
  message(FATAL_ERROR "${msg}")
  set(OPENDDS_FOUND "OpenDDS-NOTFOUND")
  return()
endmacro()

if(NOT DEFINED DDS_ROOT)
  if(OPENDDS_USE_PREFIX_PATH)
    set(DDS_ROOT "${_OPENDDS_RELATIVE_PREFIX_ROOT}/share/dds")
    set(OPENDDS_INCLUDE_DIR "${_OPENDDS_RELATIVE_PREFIX_ROOT}/include")
    set(OPENDDS_BIN_DIR "${_OPENDDS_RELATIVE_PREFIX_ROOT}/bin")
    set(OPENDDS_LIB_DIR "${_OPENDDS_RELATIVE_PREFIX_ROOT}/lib")

  else()
    set(DDS_ROOT ${_OPENDDS_RELATIVE_SOURCE_ROOT})
    set(OPENDDS_INCLUDE_DIR "${DDS_ROOT}")
    set(OPENDDS_BIN_DIR "${DDS_ROOT}/bin")
    set(OPENDDS_LIB_DIR "${DDS_ROOT}/lib")
  endif()

else()
  _OPENDDS_RETURN_ERR("DDS_ROOT has already been set")
endif()

if (NOT DEFINED ACE_ROOT)
  if(OPENDDS_USE_PREFIX_PATH)
    set(ACE_ROOT "${_OPENDDS_RELATIVE_PREFIX_ROOT}/share/ace")
    set(ACE_INCLUDE_DIR "${_OPENDDS_RELATIVE_PREFIX_ROOT}/include")
    set(ACE_BIN_DIR "${_OPENDDS_RELATIVE_PREFIX_ROOT}/bin")
    set(ACE_LIB_DIR "${_OPENDDS_RELATIVE_PREFIX_ROOT}/lib")

  elseif(OPENDDS_ACE)
    set(ACE_ROOT ${OPENDDS_ACE})
    set(ACE_INCLUDE_DIR "${ACE_ROOT}")
    set(ACE_BIN_DIR "${ACE_ROOT}/bin")
    set(ACE_LIB_DIR "${ACE_ROOT}/lib")

  else()
    _OPENDDS_RETURN_ERR("Failed to locate ACE_ROOT")
  endif()

else()
  _OPENDDS_RETURN_ERR("ACE_ROOT has already been set")
endif()

if (NOT DEFINED TAO_ROOT)
  if(OPENDDS_USE_PREFIX_PATH)
    set(TAO_ROOT "${_OPENDDS_RELATIVE_PREFIX_ROOT}/share/tao")
    set(TAO_INCLUDE_DIR "${_OPENDDS_RELATIVE_PREFIX_ROOT}/include")
    set(TAO_BIN_DIR ${_OPENDDS_RELATIVE_PREFIX_ROOT}/bin)
    set(TAO_LIB_DIR ${_OPENDDS_RELATIVE_PREFIX_ROOT}/lib)

  elseif(OPENDDS_TAO)
    set(TAO_ROOT "${OPENDDS_TAO}")
    set(TAO_INCLUDE_DIR "${OPENDDS_TAO}")
    set(TAO_BIN_DIR ${ACE_BIN_DIR})
    set(TAO_LIB_DIR ${ACE_LIB_DIR})

  else()
    _OPENDDS_RETURN_ERR("Failed to locate TAO_ROOT")
  endif()

else()
  _OPENDDS_RETURN_ERR("TAO_ROOT has already been set")
endif()

set(_dds_bin_hints ${OPENDDS_BIN_DIR})
set(_tao_bin_hints ${ACE_BIN_DIR})
set(_ace_bin_hints ${TAO_BIN_DIR})

find_program(PERL perl)

find_program(OPENDDS_IDL
  NAMES
    opendds_idl
  HINTS
    ${_dds_bin_hints}
)

find_program(TAO_IDL
  NAMES
    tao_idl
  HINTS
    ${_tao_bin_hints}
)

find_program(ACE_GPERF
  NAMES
    ace_gperf
  HINTS
    ${_ace_bin_hints}
)

set(_ace_libs
  ACE_XML_Utils
  ACE
)

set(_tao_libs
  TAO_IORManip
  TAO_ImR_Client
  TAO_Svc_Utils
  TAO_IORTable
  TAO_IDL_FE
  TAO_PortableServer
  TAO_BiDirGIOP
  TAO_PI
  TAO_CodecFactory
  TAO_AnyTypeCode
  TAO
)

set(_opendds_libs
  OpenDDS_Dcps
  OpenDDS_FACE
  OpenDDS_Federator
  OpenDDS_InfoRepoDiscovery
  OpenDDS_InfoRepoLib
  OpenDDS_InfoRepoServ
  OpenDDS_Model
  OpenDDS_monitor
  OpenDDS_Multicast
  OpenDDS_QOS_XML_XSC_Handler
  OpenDDS_Rtps
  OpenDDS_Rtps_Udp
  OpenDDS_Security
  OpenDDS_Shmem
  OpenDDS_Tcp
  OpenDDS_Udp
)

list(APPEND _all_libs ${_opendds_libs} ${_ace_libs} ${_tao_libs})

set(OPENDDS_IDL_DEPS
  TAO::IDL_FE
  ACE::ACE
)

set(OPENDDS_DCPS_DEPS
  TAO::PortableServer
  TAO::BiDirGIOP
  TAO::PI
  TAO::CodecFactory
  TAO::AnyTypeCode
  TAO::TAO
  ACE::ACE
)

set(OPENDDS_FACE_DEPS
  OpenDDS::Dcps
)

set(OPENDDS_FEDERATOR_DEPS
  OpenDDS::InfoRepoLib
)

set(OPENDDS_INFOREPODISCOVERY_DEPS
  OpenDDS::Tcp
  OpenDDS::Dcps
)

set(OPENDDS_INFOREPOLIB_DEPS
  OpenDDS::InfoRepoDiscovery
  TAO::Svc_Utils
  TAO::ImR_Client
  TAO::IORManip
  TAO::IORTable
)

set(OPENDDS_INFOREPOSERV_DEPS
  OpenDDS::Federator
)

set(OPENDDS_MODEL_DEPS
  OpenDDS::Dcps
)

set(OPENDDS_MONITOR_DEPS
  OpenDDS::Dcps
)

set(OPENDDS_MULTICAST_DEPS
  OpenDDS::Dcps
)

set(OPENDDS_QOS_XML_XSC_HANDLER_DEPS
  OpenDDS::Dcps
  ACE::XML_Utils
)

set(OPENDDS_RTPS_DEPS
  OpenDDS::Dcps
)

set(OPENDDS_RTPS_UDP_DEPS
  OpenDDS::Rtps
)

set(OPENDDS_SECURITY_DEPS
  OpenDDS::Rtps
  ACE::XML_Utils
)

set(OPENDDS_SHMEM_DEPS
  OpenDDS::Dcps
)

set(OPENDDS_TCP_DEPS
  OpenDDS::Dcps
)

set(OPENDDS_UDP_DEPS
  OpenDDS::Dcps
)

set(_dds_lib_hints  ${OPENDDS_LIB_DIR})
set(_ace_lib_hints  ${ACE_LIB_DIR})
set(_tao_lib_hints  ${TAO_LIB_DIR})

set(_suffix_RELEASE "")
set(_suffix_DEBUG d)
foreach(_cfg  RELEASE  DEBUG)
  set(_sfx ${_suffix_${_cfg}})

  foreach(_lib ${_ace_libs})
    string(TOUPPER ${_lib} _LIB_VAR)

    find_library(${_LIB_VAR}_LIBRARY_${_cfg}
      ${_lib}${_sfx}
      HINTS ${_ace_lib_hints}
    )
  endforeach()

  foreach(_lib ${_tao_libs})
    string(TOUPPER ${_lib} _LIB_VAR)

    find_library(${_LIB_VAR}_LIBRARY_${_cfg}
      ${_lib}${_sfx}
      # By default TAO libraries are built into ACE_ROOT/lib
      # so the hints are shared here.
      HINTS ${_tao_lib_hints} ${_ace_lib_hints}
    )
  endforeach()

  foreach(_lib ${_opendds_libs})
    string(TOUPPER ${_lib} _LIB_VAR)

    find_library(${_LIB_VAR}_LIBRARY_${_cfg}
      ${_lib}${_sfx}
      HINTS ${_dds_lib_hints}
    )
  endforeach()

endforeach()

function(opendds_extract_version  in_version_file  out_version  out_major  out_minor)
  file(READ "${in_version_file}" contents)
  if(contents)
    string(REGEX MATCH "OpenDDS version (([0-9]+).([0-9]+))" _ "${contents}")
    set(${out_version} ${CMAKE_MATCH_1} PARENT_SCOPE)
    set(${out_major}   ${CMAKE_MATCH_2} PARENT_SCOPE)
    set(${out_minor}   ${CMAKE_MATCH_3} PARENT_SCOPE)
  endif()
endfunction()

opendds_extract_version("${DDS_ROOT}/VERSION"
  OPENDDS_VERSION
  OPENDDS_VERSION_MAJOR
  OPENDDS_VERSION_MINOR
)

include(SelectLibraryConfigurations)
include(FindPackageHandleStandardArgs)

foreach(_lib ${_all_libs})
  string(TOUPPER ${_lib} _LIB_VAR)
  select_library_configurations(${_LIB_VAR})
endforeach()

find_package_handle_standard_args(OPENDDS
  FOUND_VAR OPENDDS_FOUND
  REQUIRED_VARS
    OPENDDS_INCLUDE_DIR
    OPENDDS_DCPS_LIBRARY
    OPENDDS_IDL
    ACE_LIBRARY
    ACE_GPERF
    TAO_LIBRARY
    TAO_IDL
    PERL
  VERSION_VAR OPENDDS_VERSION
)

macro(_ADD_TARGET_BINARY  target  path)
  if (NOT TARGET ${target} AND EXISTS "${path}")
    add_executable(${target} IMPORTED)
    set_target_properties(${target}
      PROPERTIES
        IMPORTED_LOCATION "${path}"
    )
  endif()
endmacro()

macro(_ADD_TARGET_LIB  target  var_prefix  include_dir)
  set(_debug_lib "${${var_prefix}_LIBRARY_DEBUG}")
  set(_release_lib "${${var_prefix}_LIBRARY_RELEASE}")
  set(_deps "${${var_prefix}_DEPS}")

  if (NOT TARGET ${target} AND
      (EXISTS "${_debug_lib}" OR EXISTS "${_release_lib}"))

    add_library(${target} UNKNOWN IMPORTED)
    set_target_properties(${target}
      PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${include_dir}"
        INTERFACE_LINK_LIBRARIES "${_deps}"
    )

    if (EXISTS "${_release_lib}")
      set_property(TARGET ${target}
        APPEND PROPERTY
        IMPORTED_CONFIGURATIONS RELEASE
      )
      set_target_properties(${target}
        PROPERTIES
          IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "CXX"
          IMPORTED_LOCATION_RELEASE "${_release_lib}"
      )
    endif()

    if (EXISTS "${_debug_lib}")
      set_property(TARGET ${target}
        APPEND PROPERTY
        IMPORTED_CONFIGURATIONS DEBUG
      )
      set_target_properties(${target}
        PROPERTIES
          IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "CXX"
          IMPORTED_LOCATION_DEBUG "${_debug_lib}"
      )
    endif()

    list(APPEND OPENDDS_LIBRARIES ${target})

  endif()
endmacro()

if(OPENDDS_FOUND)
  set(OPENDDS_INCLUDE_DIRS
      ${OPENDDS_INCLUDE_DIR}
      ${ACE_INCLUDE_DIR}
      ${TAO_INCLUDE_DIR}
      ${TAO_INCLUDE_DIR}/orbsvcs
  )

  _ADD_TARGET_BINARY(opendds_idl "${OPENDDS_IDL}")
  _ADD_TARGET_BINARY(tao_idl "${TAO_IDL}")
  _ADD_TARGET_BINARY(ace_gperf "${ACE_GPERF}")
  _ADD_TARGET_BINARY(perl "${PERL}")

  foreach(_lib ${_ace_libs})
    string(TOUPPER ${_lib} _VAR_PREFIX)

    if("${_lib}" STREQUAL "ACE")
      set(_target "ACE::ACE")
    else()
      string(REPLACE "ACE_" "ACE::" _target ${_lib})
    endif()

    _ADD_TARGET_LIB(${_target} ${_VAR_PREFIX} "${ACE_INCLUDE_DIR}")
  endforeach()

  foreach(_lib ${_tao_libs})
    string(TOUPPER ${_lib} _VAR_PREFIX)

    if("${_lib}" STREQUAL "TAO")
      set(_target "TAO::TAO")
    else()
      string(REPLACE "TAO_" "TAO::" _target ${_lib})
    endif()

    _ADD_TARGET_LIB(${_target} ${_VAR_PREFIX} "${TAO_INCLUDE_DIR}")
  endforeach()

  foreach(_lib ${_opendds_libs})
    string(TOUPPER ${_lib} _VAR_PREFIX)
    string(REPLACE "OpenDDS_" "OpenDDS::" _target ${_lib})

    _ADD_TARGET_LIB(${_target} ${_VAR_PREFIX} "${OPENDDS_INCLUDE_DIR}")

  endforeach()

  if(NOT TARGET OpenDDS::OpenDDS)
    add_library(OpenDDS::OpenDDS INTERFACE IMPORTED)

    set(_opendds_core_libs
      OpenDDS::Dcps
      OpenDDS::Multicast
      OpenDDS::Rtps
      OpenDDS::Rtps_Udp
      OpenDDS::InfoRepoDiscovery
      OpenDDS::Shmem
      OpenDDS::Tcp
      OpenDDS::Udp)

    if(OPENDDS_SECURITY)
      list(APPEND _opendds_core_libs OpenDDS::Security)
    endif()

    set_target_properties(OpenDDS::OpenDDS
      PROPERTIES
        INTERFACE_LINK_LIBRARIES "${_opendds_core_libs}")

  endif()

  include(${_OPENDDS_FIND_MODULE_DIR}/FindOpenDDS/options.cmake)
  include(${_OPENDDS_FIND_MODULE_DIR}/FindOpenDDS/api_macros.cmake)

  # Summary information
  message(STATUS "Added the following targets to OPENDDS_LIBRARIES:")
  foreach(_target ${OPENDDS_LIBRARIES})
    get_target_property(_target_location ${_target} LOCATION)
    message(STATUS "${_target} -> ${_target_location}")
  endforeach()
endif()
