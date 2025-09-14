#!/bin/env bash


run_tests_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source "${run_tests_dir}/src/helpers.sh"

if ! fn_is_file "${run_tests_dir}/test/bats/README.md" ;then
    echo "cloning sub modules"
    git submodule init
    fn_catch_error $LINENO
    git submodule update
    fn_catch_error $LINENO
fi

"${run_tests_dir}/test/bats/bin/bats" "${run_tests_dir}/test/test_helpers.bats"

