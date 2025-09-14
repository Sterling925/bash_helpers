# [Documentation](https://bats-core.readthedocs.io/en/stable/writing-tests.html)

setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    # ... the remaining setup is unchanged

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"
}


teardown() {
    : # NOP
}


# Confirm all functions appear in at least one test
#
# Specifically, checks each function appears
# at least once in the text file.
#
# Note this test will break if order of helper functions changed
#
@test "test are all functions exercised" {
    test_helpers_dir=$DIR

    load "${test_helpers_dir}/../src/helpers.sh"
    fn_set_strict_mode
    # make list of all `fn_*()` instances in src
    # Confirm all in list exits in test file

    run grep "() {" "${test_helpers_dir}/../src/helpers.sh"
    assert_equal "${lines[0]}" "fn_confirm() {"
    assert_equal "${lines[1]}" "fn_set_strict_mode() {"
    local qty=${#lines[@]}
    assert [ $qty -gt 13 ]
    for f in "${lines[@]}"
    do
        local name=$(echo "${f}" | awk -F'\\() {' '{print $1}')

        fn_is_defined "${name}"
        assert_success

        if ! fn_search_file "$name" "${test_helpers_dir}/test_helpers.bats" ;then
            echo -e "Did not find test for \"$name\""
            exit 255
        fi

    done

}


@test "test fn_nop" {                                                                                             
    load ../src/helpers.sh
    fn_set_strict_mode                                                                                     
    run fn_nop                                                                                 
    [ "$status" -eq 0 ]                                                                                            
    [ "$output" = "" ]                                                                    
}          


@test "test fn_todo" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_todo "Write this test!"
    [ "$status" -eq 1 ]
    assert_equal "$output" "todo \"Write this test!\""
}


@test "test fn_is_yes yes 1" {
    load ../src/helpers.sh                                                                                         
    fn_set_strict_mode                                                                                             
    run fn_is_yes "y"                                                                                 
    [ "$status" -eq 0 ]                                                                                            
    assert_equal "$output" ""
}


@test "test fn_is_yes yes 2" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes "yes"
    [ "$status" -eq 0 ]
    assert_equal "$output" ""                     
}


@test "test fn_is_yes yes 3" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes "Y"
    [ "$status" -eq 0 ]
    assert_equal "$output" ""                     
}


@test "test fn_is_yes yes 4" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes "Yes"
    [ "$status" -eq 0 ]
    assert_equal "$output" ""                     
}


@test "test fn_is_yes yes 5" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes "YEs"
    [ "$status" -eq 0 ]
    assert_equal "$output" ""
}


@test "test fn_is_yes no 1" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes "n"
    [ "$status" -eq 255 ]
    assert_equal "$output" ""                     
}


@test "test fn_is_yes no 2" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes "no"
    [ "$status" -eq 255 ]
    assert_equal "$output" ""                     
}


@test "test fn_is_yes no 3" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes "7"
    [ "$status" -eq 255 ]
    assert_equal "$output" ""
}


@test "test fn_is_yes no 4" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes "0"
    [ "$status" -eq 255 ]
    assert_equal "$output" ""
}


@test "test fn_is_yes no 5" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_yes ""
    [ "$status" -eq 255 ]
    assert_equal "$output" ""
}


@test "test fn_is_defined yes" {
    load ../src/helpers.sh
    fn_set_strict_mode
    my_var="hello"
    run fn_is_defined ${my_var} 
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}


@test "test fn_is_defined yes 2" {
    load ../src/helpers.sh
    fn_set_strict_mode                                                                                 
    my_var="yes"                                                                                                 
    run fn_is_defined ${my_var}                                                                                    
    [ "$status" -eq 0 ]                                                                                            
    [ "$output" = "" ]                                                                                             
}       


@test "test fn_is_defined no" {
    load ../src/helpers.sh
    fn_set_strict_mode
    my_var=""
    run fn_is_defined ${my_var} 
    [ "$status" -eq 1 ]
    #[ "$output" = "" ]
}


@test "test fn_is_defined no 1" {
    load ../src/helpers.sh
    fn_set_strict_mode
    my_var="\n"
    run fn_is_defined ${my_var}
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}


@test "test fn_is_dir no" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_dir "/media/does_not_exist"
    [ "$status" -eq 1 ]
    [ "$output" = "" ]
}


@test "test fn_is_dir yes" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_dir "./"
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}


@test "test fn_is_not_installed yes" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_not_installed "this_does_not_exist"
    [ "$status" -eq 0 ]

    # user@System39:~$ this_does_not_exist --version
    # this_does_not_exist: command not found
    # // this_does_not_exist does not appear to be installed

    assert_equal "${lines[1]}"  "// this_does_not_exist does not appear to be installed"
}


@test "test fn_is_not_installed no" {
    load ../src/helpers.sh
    fn_set_strict_mode
    run fn_is_not_installed "bash"
    [ "$status" -eq 1 ]

    # user@System39:~$ bash --version
    # GNU bash, version 5.2.21(1)-release (x86_64-pc-linux-gnu)
    # Copyright (C) 2022 Free Software Foundation, Inc.
    # License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    #
    # This is free software; you are free to change and redistribute it.
    # There is NO WARRANTY, to the extent permitted by law.
    # // bash is installed

    assert_equal "${lines[5]}" "// bash is installed"
}


# test the following
# * fn_is_file()
# * fn_remove_file()
@test "test file operations" {
    load ../src/helpers.sh
    fn_set_strict_mode

    temp_file=$(mktemp /tmp/mytempfile.XXXXXX)

    if ! fn_is_file $temp_file ;then
        false
    fi

    if ! fn_remove_file $temp_file ;then
        false
    fi

    if fn_is_file $temp_file ;then
        false
    fi
    
}


# test the following
# * fn_is_file()
# * fn_search_file()
# * fn_remove_file()
@test "test file operations 2" {
    load ../src/helpers.sh
    fn_set_strict_mode

    temp_file=$(mktemp /tmp/mytempfile2.XXXXXX)
    sleep 0.25
    if ! fn_is_file $temp_file ;then
        false
    fi

    echo -e "All work and no play\n" > $temp_file
    if fn_search_file "Jack" $temp_file ;then
        false
    fi
    echo  -e "makes Jack a dull boy.\n" >> $temp_file
    if ! fn_search_file "Jack" $temp_file ;then
        false
    fi  

    if ! fn_is_file $temp_file ;then
        false
    fi
    
    if ! fn_remove_file $temp_file ;then
        false
    fi

    if fn_is_file $temp_file ;then
        false
    fi
    
}


# test the following
# * fn_is_file()
# * fn_check_sha256()
# * fn_remove_file()
@test "test file operations 3" {
    load ../src/helpers.sh
    fn_set_strict_mode

    temp_file=$(mktemp /tmp/mytempfile3.XXXXXX)
    sleep 0.25
    if ! fn_is_file $temp_file ;then
        false
    fi

    echo "All work and no play makes Jack a dull boy." > $temp_file
    
    if ! fn_is_file $temp_file ;then
        false
    fi

    local expected_hash="4489c0acf5973358718c763d3c20287308c7e31e3cd46fdc1a72c8cc0b0a5ef4"
    
    run fn_check_sha256 ${expected_hash} ${temp_file}
    assert_equal "$output" ""
    [ "$status" -eq 0 ]

    
    if ! fn_remove_file $temp_file ;then
        false
    fi

    if fn_is_file $temp_file ;then
        false
    fi
}


# test the following
# * fn_is_file()
# * fn_check_sha256() # Should fail due to mismatch
# * fn_remove_file()
@test "test file operations 4" {
    load ../src/helpers.sh
    fn_set_strict_mode

    temp_file=$(mktemp /tmp/mytempfile4.XXXXXX)
    sleep 0.25
    if ! fn_is_file $temp_file ;then
        false
    fi

    echo "All work and no play makes Jack a dull boy." > $temp_file
    
    if ! fn_is_file $temp_file ;then
        false
    fi

    local expected_hash="4489c0acf5973358718c763d3c20287308c7e31e3cd46fdc1a72c8cc0b0a5ef5"
    
    run fn_check_sha256 ${expected_hash} ${temp_file}
    assert_equal "$output" ""
    [ "$status" -eq 1 ]

    
    if ! fn_remove_file $temp_file ;then
        false
    fi

    if fn_is_file $temp_file ;then
        false
    fi
    
}


# Test fn_catch_error() fail
# Test will need line number updated if src changes
@test "test fn_catch_error yes" {
    load ../src/helpers.sh
    fn_set_strict_mode
    my_var=""
    run fn_is_defined ${my_var} 
    fn_catch_error $LINENO
    [ "$status" -eq 1 ]
    assert_output --partial "/src/helpers.sh: line 205: 1: unbound variable"
}


# Test fn_catch_error() success
# 
@test "test fn_catch_error no" {
    load ../src/helpers.sh
    fn_set_strict_mode
    my_var="hello"
    run fn_is_defined ${my_var} 
    fn_catch_error $LINENO
    [ "$status" -eq 0 ]
    assert_output ""
}


@test "test fn_is_running yes" {
    load ../src/helpers.sh
    fn_set_strict_mode

    run fn_is_running "idle_inject/0"
    assert_success
}


@test "test fn_is_running no" {
    load ../src/helpers.sh
    fn_set_strict_mode

    run fn_is_running "ThisProcessDoesNotExist"
    assert_failure
}

