#!/bin/bash
#
#  Copyright (c) 2025 CEA*
#  *Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA)
#
#  SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
#
#  Licensed under the Solderpad Hardware License v 2.1 (the “License”); you
#  may not use this file except in compliance with the License, or, at your
#  option, the Apache License version 2.0. You may obtain a copy of the
#  License at
#
#  https://solderpad.org/licenses/SHL-2.1/
#
#  Unless required by applicable law or agreed to in writing, any work
#  distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations
#  under the License.
#
#
#  Authors       : Ihsane TAHIR
#  Creation Date : March, 2025
#  Description   : 
#  History       :
#
C_TOP="\e[1;32m" # Green
C_RST="\e[0m"    # Reset
C_MSG="\e[1;34m" # Blue

# Set project root to current working directory
export PROJECT_DIR="$(pwd)"

echo -e "${C_TOP}>>>>>> Initializing Platform <<<<<<${C_RST}"

############################################################
# Update all git submodules
############################################################
echo -e "${C_MSG}Update all git submodules${C_RST}"
git submodule init
git submodule sync
git submodule update --init --recursive --remote


############################################################
# Add the local path to the Perl libraries
############################################################
if [[ -n "$PERL5LIB" ]]; then
    export PERL5LIB="${PERL5LIB}:${PROJECT_DIR}/scripts/perl5"
else
    export PERL5LIB="${PROJECT_DIR}/scripts/perl5"
fi

# TOOLS
case $1 in
    questa)
        GEN_PATH=$QUESTA_PATH
        PATH="${QUESTA_PATH}/bin:$PATH"
        ;;
    xcelium)
        GEN_PATH=$XLM_PATH
        PATH="${XLM_PATH}/bin:$PATH"
        ;;
    vcs)
        GEN_PATH=$VCS_PATH
        export VCS_HOME=$VCS_PATH
        PATH="${VCS_HOME}/linux64/bin:$PATH"
        ;;
    *)
        echo "Invalid tool: $1"
        ;;
esac

export GEN_PATH
export PATH

#SCANLOGS
export SCRIPTS=$PROJECT_DIR/scripts
export PATH="${SCRIPTS}:$PATH"



############################################################
# Project-specific environment variables
############################################################
echo -e "${C_MSG}Running bender update${C_RST}"
bender update

export TARGET_CFG="cv64a60ax"

if CVA6_REPO_DIR="$(bender path cva6 2>/dev/null)"; then
    export CVA6_REPO_DIR
else
    echo "[ERROR]: unable to get path for cva6 via Bender"
    exit 1
fi

if CORE_V_VERIF_PATH="$(bender path core-v-verif 2>/dev/null)"; then
    export CORE_V_VERIF="$CORE_V_VERIF_PATH"
else
    echo "[ERROR]: unable to get path for core-v-verif via Bender"
    exit 1
fi
export DV_UTILS_DIR="${CORE_V_VERIF}/lib/cv_dv_utils"
export SCRIPTS_DIR="${DV_UTILS_DIR}/python/sim_cmd"

echo -e "${C_TOP}>>>>>> Initialization Done <<<<<<${C_RST}"