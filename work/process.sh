#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail
set -o monitor
set -o noglob

# calculate the script's directory
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
declare -r -x SCRIPT_DIR

# calculate the package directory
PACKAGE_DIR=$(dirname -- "${SCRIPT_DIR}")
declare -r -x PACKAGE_DIR

# loop through all files
readarray -d '' WAV_FILES < <(find "${SCRIPT_DIR}/captures" -maxdepth 1 -type f -name "*.wav" -print0)
declare -r WAV_FILES

# conversion
function build_model() {
    local -r WAV_FILE=${1?No path to the WAV file}

    # file name
    local -r WAV_FILE_NAME=$(basename "${WAV_FILE}")

    # calculate the length of the wav file in samples
    local -r WAV_FILE_LEN=$(soxi -s "${WAV_FILE}")
    echo "${WAV_FILE_NAME} / ${WAV_FILE_LEN}"

    # trim if we need to trim
    if (( WAV_FILE_LEN > 9120000 ))
    then
        sox "${WAV_FILE}" "${SCRIPT_DIR}/output.wav" trim "0s" "9120000s"
    fi

    # pad the end if the need to pad
    if (( WAV_FILE_LEN < 9120000 ))
    then
        local -r WAV_FILE_PAD=$(echo "9120000 - ${WAV_FILE_LEN}" | bc)
        sox "${WAV_FILE}" "${SCRIPT_DIR}/output.wav" pad "0s" "${WAV_FILE_PAD}s"
    fi

    # create the model's folder
    local -r MODEL_FOLDER="${SCRIPT_DIR}/models/${WAV_FILE_NAME%.wav}"
    mkdir --parents "${MODEL_FOLDER}"

    # build the model
    conda run --no-capture-output --live-stream --name "neuralamp" \
        nam-full \
            --no-plots \
            "${PACKAGE_DIR}/config/local/data.json" \
            "${PACKAGE_DIR}/config/models/wavenet.json" \
            "${PACKAGE_DIR}/config/local/learning.json" \
            "${MODEL_FOLDER}"
}

# compose classpath library list
for WAV_FILE in "${WAV_FILES[@]}"
do
    build_model "${WAV_FILE}"
done
