#!bin/env bash

# Top level script to import helper functions.
# Call as `source bash_helpers/load_helpers.sh`

# For now just import all helper functions.
# Later may update this to take an argument
# of which helpers to import.


load_helpers_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source "${load_helpers_dir}/src/helpers.sh"

