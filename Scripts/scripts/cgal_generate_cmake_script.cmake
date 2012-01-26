# Copyright (c) 2012
# Utrecht University (The Netherlands),
# ETH Zurich (Switzerland),
# INRIA Sophia-Antipolis (France),
# Max-Planck-Institute Saarbruecken (Germany),
# and Tel-Aviv University (Israel).  All rights reserved.
#
# This file is part of CGAL (www.cgal.org); you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; version 3 of the License,
# or (at your option) any later version.
#
# Licensees holding a valid commercial license may use this file in
# accordance with the commercial license agreement provided with the software.
#
# This file is provided AS IS with NO WARRANTY OF ANY KIND, INCLUDING THE
# WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# $URL: svn+ssh://fcacciola@scm.gforge.inria.fr/svn/cgal/trunk/Scripts/scripts/cgal_create_makefile $
# $Id: cgal_create_makefile 36976 2007-03-09 22:53:24Z reichel $
#
# Author(s)     : Eric Berberich <eric@mpi-inf.mpg.de>

cmake_minimum_required(VERSION 2.6.2)

message(STATUS "Create CMakeLists.txt")

# message(STATUS "Repeat command line options: ${OPTIONS}")

set(PROJECT CGAL) #`basename $PWD` # TODO set value based on dir
set(SINGLE_SOURCE "")
list(INSERT CGAL_COMPONENTS 0 GMP MPFR RS3 MPFI) # TODO default value
set(WITH_QT3 FALSE)
set(WITH_QT4 FALSE)
set(WITH_ALL_PRECONFIGURED_LIBS FALSE)
list(INSERT BOOST_COMPONENTS 0 thread) # TODO default value

# TODO enable_testing()?


### Delete file if it exists

if (EXISTS CMakeLists.txt)
  file(RENAME CMakeLists.txt CMakeLists.bak)
endif()

### Parse options

# TODO parsing and lower/upper case

#-s
#-c/-p
#-b
#-t? # for testing

### Start to write file

file(APPEND CMakeLists.txt "# Created by the script cgal_generate_cmake_script\n" )
file(APPEND CMakeLists.txt "# This is the CMake script for compiling a set of CGAL applications.\n\n" )

if ( "${SINGLE_SOURCE}" STREQUAL "" ) 
  file(APPEND CMakeLists.txt "project(${PROJECT})\n\n")
else()
  file(APPEND CMakeLists.txt "project(${SINGLE_SOURCE})\n\n")
endif()


file(APPEND CMakeLists.txt
"cmake_minimum_required(VERSION 2.6.2)
if(\"\${CMAKE_MAJOR_VERSION}.\${CMAKE_MINOR_VERSION}\" VERSION_GREATER 2.6)
  if(\"\${CMAKE_MAJOR_VERSION}.\${CMAKE_MINOR_VERSION}.\${CMAKE_PATCH_VERSION}\" VERSION_GREATER 2.8.3)
    cmake_policy(VERSION 2.8.4)
  else()
    cmake_policy(VERSION 2.6)
  endif()
endif()

set( CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS true )
 
if ( COMMAND cmake_policy )

  cmake_policy( SET CMP0003 NEW )  

endif()

# CGAL and its components
")

# TODO enable_testing?
#if [ -n "$ENABLE_CTEST" ]; then
#  echo "enable_testing()"
#fi

foreach( component ${CGAL_COMPONENTS})
  # detect qt3, qt4
  if ( ${component} STREQUAL "Qt3" )
     set(WITH_QT3 TRUE)
  endif()
  if ( ${component} STREQUAL "Qt4" )
     set(WITH_QT4 TRUE)
  endif()
endforeach()

if ( WITH_ALL_PRECONFIGURED_LIBS )
  list(APPEND CGAL_COMPONENTS ALL_PRECONFIGURED_LIBS)
endif()


if ( ${CGAL_COMPONENTS} STREQUAL "")
  file(APPEND CMakeLists.txt "find_package( CGAL QUIET )\n\n")
else()
  foreach(comp ${CGAL_COMPONENTS})
    set(CGAL_SPACED_COMPONENTS "${CGAL_SPACED_COMPONENTS} ${comp}")
  endforeach()
  file(APPEND CMakeLists.txt "find_package( CGAL QUIET COMPONENTS ${CGAL_SPACED_COMPONENTS} )\n\n")
endif()


file(APPEND CMakeLists.txt 
"if ( NOT CGAL_FOUND )

  message(STATUS \"This project requires the CGAL library, and will not be compiled.\")
  return()  

endif()

# include helper file
include( \${CGAL_USE_FILE} )

# Boost and its components
")


### Boost and its components

if ( ${BOOST_COMPONENTS} STREQUAL "")
  file(APPEND CMakeLists.txt "find_package( Boost REQUIRED )\n\n")
else()
  foreach(comp ${BOOST_COMPONENTS})
    set(BOOST_SPACED_COMPONENTS "${BOOST_SPACED_COMPONENTS} ${comp}")
  endforeach()
  file(APPEND CMakeLists.txt "find_package( Boost REQUIRED COMPONENTS ${BOOST_COMPONENTS} )\n\n")
endif()

file(APPEND CMakeLists.txt 
"if ( NOT Boost_FOUND )

  message(STATUS \"This project requires the Boost library, and will not be compiled.\")

  return()  

endif()

")

if ( EXISTS include ) 
  file(APPEND CMakeLists.txt
"# include for local directory
include_directories( BEFORE include )\n\n")
endif()

if ( EXISTS ../../include ) 
  file(APPEND CMakeLists.txt
"# includes for local package
include_directories( BEFORE ../../include )\n\n")
endif()

if ( EXISTS ../include ) 
  file(APPEND CMakeLists.txt
"# includes for local package
include_directories( BEFORE ../include )\n\n")
endif()


if (WITH_QT3)
  file(APPEND CMakeLists.txt 
"# Qt3
# FindQt3-patched.cmake is FindQt3.cmake patched by CGAL developers, so
# that it can be used together with FindQt4: all its variables are prefixed
# by \"QT3_\" instead of \"QT_\".
find_package(Qt3-patched QUIET )

if ( NOT QT3_FOUND )

  message(STATUS \"This project requires the Qt3 library, and will not be compiled.\")
  return()  

endif()

if ( CGAL_Qt3_FOUND )
  
  include( Qt3Macros-patched )

endif()

")
endif()

if (WITH_QT4) 
file(APPEND CMakeLists.txt
"# Qt4
set( QT_USE_QTXML     true )
set( QT_USE_QTMAIN    true )
set( QT_USE_QTSCRIPT  true )
set( QT_USE_QTOPENGL  true )

find_package(Qt4)  

if ( NOT QT_FOUND )

  message(STATUS \"This project requires the Qt4 library, and will not be compiled.\")
  return()  

endif()

")
endif()


if ( NOT ${BOOST_COMPONENTS} STREQUAL "")

  file(APPEND CMakeLists.txt "# Boost linking\n" )

  foreach (BOOST_COMPONENT ${BOOST_COMPONENTS})
    file(APPEND CMakeLists.txt "link_libraries( \${Boost_${BOOST_COMPONENT}_LIBRARY} )\n")
  endforeach()

  file(APPEND CMakeLists.txt "\n")

endif()


# All Files or Single Source

if ( "xxx${SINGLE_SOURCE}" STREQUAL "xxx" )

  ###############
  # ALL SOURCES #
  ###############


  file(APPEND CMakeLists.txt
"# Creating entries for all .cpp/.C files with "main" routine
# ##########################################################

")

if (WITH_QT4) 
  file(APPEND CMakeLists.txt "include( CGAL_CreateSingleSourceCGALProgramQt4 )\n\n")
else()
  file(APPEND CMakeLists.txt "include( CGAL_CreateSingleSourceCGALProgram )\n\n")
endif()


  if (WITH_QT3) 

    file(APPEND CMakeLists.txt 
"if ( CGAL_Qt3_FOUND AND QT3_FOUND )

")

    file(GLOB SOURCE_FILES *.C *.cpp) # TODO sort?
    foreach( file ${SOURCE_FILES} )
      file(STRINGS ${file} filecontent)
      string(REGEX MATCH "(^main|[^a-zA-Z0-9_]main) *[(]" result ${filecontent})
      if (result)
        file(APPEND CMakeLists.txt "  qt3_automoc( ${file} )\n")
      endif()
    endforeach()
 
    file(APPEND CMakeLists.txt 
"# Make sure the compiler can find generated .moc files
  include_directories( BEFORE \${CMAKE_CURRENT_BINARY_DIR} )
  
  include_directories( \${QT3_INCLUDE_DIR} )

  link_libraries( \${QT3_LIBRARIES} )

endif()

")

  endif(WITH_QT3)

  if (WITH_QT4) 

    file(APPEND CMakeLists.txt 
"if ( CGAL_Qt4_FOUND AND QT_FOUND )

  include( \${QT_USE_FILE} )
  include_directories( \${QT_INCLUDE_DIR} )  

endif()

")

  endif(WITH_QT4)

  file(GLOB INPUT_FILES *.C *.cpp) # TODO sort?
  foreach( file ${INPUT_FILES} )
    file(STRINGS ${file} filecontent)
    string(REGEX MATCH "(^main|[^a-zA-Z0-9_]main) *[(]" result ${filecontent})
    if (result)
      string(FIND ${file} "." POSDOT REVERSE)
      string(SUBSTRING ${file} 0 ${POSDOT} BASE)
      if (WITH_QT4)
        file(APPEND CMakeLists.txt "create_single_source_cgal_program_qt4( \"${file}\" )"\n)
      else()
        file(APPEND CMakeLists.txt "create_single_source_cgal_program( \"${file}\" )\n")
      endif()
# TODO enable testing
#      if [ -n "$ENABLE_CTEST" ]; then 
#        if [ -f "$BASE.cin" ] ; then
#          CIN=" < $BASE.cin"
#        else
#          CIN=
#        fi
#        cat <<EOF
#add_test( "$BASE" \${CMAKE_CTEST_COMMAND}
#  --build-and-test "\${CMAKE_CURRENT_SOURCE_DIR}"
#                   "\${CMAKE_CURRENT_BINARY_DIR}"
#  --build-generator "\${CMAKE_GENERATOR}"
#  --build-makeprogram "\${CMAKE_MAKE_PROGRAM}"
#  --build-target $BASE
#  --build-no-clean
#  --build-run-dir "\${CMAKE_CURRENT_SOURCE_DIR}"
#  --test-command sh -c "\${CMAKE_CURRENT_BINARY_DIR}/$BASE$CIN" )
#EOF
#      fi
    endif()
  endforeach()
    
else()

    #################
    # SINGLE_SOURCE #
    #################

  file(APPEND CMakeLists.txt "\n\n# Creating entries for target: ${SINGLE_SOURCE}\n\n")

  file(GLOB ALL_SOURCES *.C *.cpp) # TODO sort sources?

  if (WITH_QT3) 

    file(APPEND CMakeLists.txt
"if ( CGAL_Qt3_FOUND AND QT3_FOUND )

  qt3_automoc( \${ALL_SOURCES} )

  # Make sure the compiler can find generated .moc files
  include_directories( BEFORE \${CMAKE_CURRENT_BINARY_DIR} )
 
  include_directories( \${QT3_INCLUDE_DIR} )

endif()

")

  endif(WITH_QT3)

  if(WITH_QT4)

    file(APPEND CMakeLists.txt
"if ( CGAL_Qt4_FOUND AND QT_FOUND )

  include( \${QT_USE_FILE} )
  include_directories( \${QT_INCLUDE_DIR} )  

")

    file(APPEND CMakeLists.txt "  # UI files (Qt Designer files)\n")
    file(GLOB UI_FILES *.ui) # TODO sort?
    foreach( file ${UI_FILES} )
      file(APPEND CMakeLists.txt "  qt4_wrap_ui( DT_UI_FILES ${file} )\n")
    endforeach()
    file(APPEND CMakeLists.txt "\n")

    file(APPEND CMakeLists.txt "  # qrc files (resources files, that contain icons, at least)\n")
    file(GLOB QRC_FILES *.qrc) # TODO sort?
    foreach( file ${QRC_FILES} )
      file(APPEND CMakeLists.txt "  qt4_add_resources ( DT_RESOURCE_FILES ${file} )\n")
    endforeach()
    file(APPEND CMakeLists.txt "\n")

    set(MOC_FILES "")
    file(APPEND CMakeLists.txt "  # use the Qt MOC preprocessor on classes that derives from QObject\n")
    file(GLOB INPUT_FILES include/*.h *.h) # TODO sort?
    foreach( file ${INPUT_FILES} )
      file(STRINGS ${file} filecontent)
      string(REGEX MATCH "Q_OBJECT" result ${filecontent})
      if (result)
        string(FIND ${file} "." POSDOT REVERSE)
        string(SUBSTRING ${file} 0 ${POSDOT} BASE)
        file(APPEND CMakeLists.txt "  qt4_generate_moc( ${BASE}.h ${BASE}.moc )\n")
        set(MOC_FILES "${BASE}.moc ${MOC_FILES}")
      endif()
    endforeach()
    file(APPEND CMakeLists.txt "\n")
    file(GLOB INPUT_FILES *.cpp) # TODO sort?
    foreach( file ${INPUT_FILES} )
      file(STRINGS ${file} filecontent)
      string(REGEX MATCH "Q_OBJECT" result ${filecontent})
      if (result)
        string(FIND ${file} "." POSDOT REVERSE)
        string(SUBSTRING ${file} 0 ${POSDOT} BASE)
        file(APPEND CMakeLists.txt "  qt4_generate_moc( ${BASE}.cpp ${BASE}.moc )\n")
        set(MOC_FILES "${BASE}.moc ${MOC_FILES}")
      endif()
    endforeach()
    file(APPEND CMakeLists.txt "\n")

    file(APPEND CMakeLists.txt "endif()\n\n")

    set( ALL_SOURCES "${ALL_SOURCES} ${MOC_FILES} \${DT_UI_FILES} \${DT_RESOURCE_FILES}")

  endif(WITH_QT4)

  file(APPEND CMakeLists.txt
"

add_executable( ${SINGLE_SOURCE} ${ALL_SOURCES} )

add_to_cached_list( CGAL_EXECUTABLE_TARGETS ${SINGLE_SOURCE} )

# Link the executable to CGAL and third-party libraries

")

  set(LIBS "")

  if (WITH_QT3)
    set(LIBS "\${QT3_LIBRARIES}")
  endif(WITH_QT3)
  if (WITH_QT4)
    set(LIBS "\${QT_LIBRARIES}")
  endif(WITH_QT4)

  file(APPEND CMakeLists.txt "target_link_libraries(${SINGLE_SOURCE} ${LIBS} \${CGAL_LIBRARIES} \${CGAL_3RD_PARTY_LIBRARIES})\n\n# EOF")

endif()
