##############################################################################
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##############################################################################
ifeq ($(JAVA_VERSION), SE80)
	JDKVERSION = openjdk8
else
	ifeq ($(JAVA_VERSION), SE90)
		JDKVERSION = openjdk9
	else
		ifeq ($(JAVA_VERSION), SE100)
			JDKVERSION = openjdk10
		endif
	endif
endif

ifneq (, $(findstring openj9, $(JAVA_IMPL)))
	JVM_VERSION = $(JDKVERSION)-openj9
else
	JVM_VERSION = $(JDKVERSION)
endif

$(info set JVM_VERSION to $(JVM_VERSION))

NPROCS:=1
OS:=$(shell uname -s)

ifeq ($(OS),Linux)
	NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)
endif
ifeq ($(OS),Darwin)
	NPROCS:=$(shell sysctl -n hw.ncpu)
endif
ifeq ($(CYGWIN),1)
 	NPROCS:=$(NUMBER_OF_PROCESSORS)
endif
EXTRA_JTREG_OPTIONS += -concurrency:$(NPROCS)

JTREG_BASIC_OPTIONS += -agentvm
# Only run automatic tests
JTREG_BASIC_OPTIONS += -a
# Always turn on assertions
JTREG_ASSERT_OPTION = -ea -esa
JTREG_BASIC_OPTIONS += $(JTREG_ASSERT_OPTION)
# Report details on all failed or error tests, times too
JTREG_BASIC_OPTIONS += -v:fail,error,time
# Retain all files for failing tests
JTREG_BASIC_OPTIONS += -retain:fail,error
# Ignore tests are not run and completely silent about it
JTREG_IGNORE_OPTION = -ignore:quiet
JTREG_BASIC_OPTIONS += $(JTREG_IGNORE_OPTION)
# Multiple by 4 the timeout numbers
JTREG_TIMEOUT_OPTION =  -timeoutFactor:4
JTREG_BASIC_OPTIONS += $(JTREG_TIMEOUT_OPTION)
# Create junit xml
JTREG_XML_OPTION = -xml:verify
JTREG_BASIC_OPTIONS += $(JTREG_XML_OPTION)
# Add any extra options
JTREG_BASIC_OPTIONS += $(EXTRA_JTREG_OPTIONS)

ifdef JTREG_TEST_DIR
# removing "
JTREG_TEST_DIR := $(subst ",,$(JTREG_TEST_DIR))
else
JTREG_TEST_DIR := $(TEST_ROOT)$(D)openjdk_regression$(D)openjdk-jdk$(D)jdk$(D)test
endif

ifdef JTREG_HOTSPOT_TEST_DIR
# removing "
JTREG_HOTSPOT_TEST_DIR := $(subst ",,$(JTREG_TEST_DIR))
else
JTREG_HOTSPOT_TEST_DIR := $(TEST_ROOT)$(D)openjdk_regression$(D)openjdk-jdk$(D)hotspot$(D)test
endif
