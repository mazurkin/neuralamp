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

# length of the input file in samples
INPUT_FILE_LEN=$(soxi -s "${SCRIPT_DIR}/input.wav")
declare -r INPUT_FILE_LEN

# input file statistics
echo "*** Input: input.wav"
sox "${SCRIPT_DIR}/input.wav" -n stats

# conversion
function build_model() {
    local -r WAV_FILE=${1?No path to the WAV file}

    # statistics
    echo "*** Capture: ${WAV_FILE}"
    sox "${WAV_FILE}" -n stats

    # calculate the length of the wav file in samples
    local -r WAV_FILE_LEN=$(soxi -s "${WAV_FILE}")

    # remove old output WAV file (if exists)
    rm --force "${SCRIPT_DIR}/output.wav"

    # process the capture WAV file
    if (( WAV_FILE_LEN > INPUT_FILE_LEN ))
    then
        # trim if we the capture WAV file is longer than the input file
        sox "${WAV_FILE}" "${SCRIPT_DIR}/output.wav" trim "0s" "${INPUT_FILE_LEN}s"
    elif (( WAV_FILE_LEN < INPUT_FILE_LEN ))
    then
        # pad the end if the capture WAV file is shorter than the input file
        local -r WAV_FILE_PAD=$(echo "${INPUT_FILE_LEN} - ${WAV_FILE_LEN}" | bc)
        sox "${WAV_FILE}" "${SCRIPT_DIR}/output.wav" pad "0s" "${WAV_FILE_PAD}s"
    else
        # just copy the file without processing
        cp "${WAV_FILE}" "${SCRIPT_DIR}/output.wav"
    fi

    # file name
    local -r WAV_FILE_NAME=$(basename "${WAV_FILE}")

    # create the model's folder
    local -r MODEL_FOLDER="${SCRIPT_DIR}/models/${WAV_FILE_NAME%.wav}"
    mkdir --parents "${MODEL_FOLDER}"

    # build the model
    conda run --no-capture-output --live-stream --name "neuralamp" \
        nam-full \
            --no-plots \
            "${PACKAGE_DIR}/config/local/data.json" \
            "${PACKAGE_DIR}/config/models/a2.json" \
            "${PACKAGE_DIR}/config/local/learning.json" \
            "${MODEL_FOLDER}"
}

# compose classpath library list
for WAV_FILE in "${WAV_FILES[@]}"
do
    build_model "${WAV_FILE}"
done
