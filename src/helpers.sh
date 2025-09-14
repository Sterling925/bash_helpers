#!bin/env bash



# Ask yes or no to confirm action
# Pass argument of `action`, what is being asked
# Exit code 0 = success AKA 'y' or 'Y'
# Exit code 255 = error or `no`
#
# # Example use:
#
# fn_confirm "Delete file" && {
#    echo "You said yes"
# }
# # Output:
# Delete file? y/n: y
# You said yes
fn_confirm() {
    local description="${1}"
    local yes_no="n"
	read  -n1 -p "${description}? y/n: " yes_no
	echo "" # for new line
	if fn_is_yes  "${yes_no}" ; then
		return 0
	else
		return 255
	fi
}


# set strict mode
# -e: Exit immediately if any command returns a non-zero status.
# -u: Treat unset variables as an error and exit immediately.
# -o pipefail: Return the exit status of the first failed command in a pipeline, 
# rather than the last one.
fn_set_strict_mode() {
    set -euo pipefail
}


# No operation
fn_nop() {
    :
}


# TODO for not yet implemented code
#
# Print todo and exit with error
#
# Output matches function call to enable easy searching
fn_todo() {
    local msg=$1
    echo -e "todo \"${msg}\""
    exit 1
}


# Check if argument was yes
#
# Valid entries for yes
# y,Y,yes,Yes,YES, YEs
#
# Return Ok 0 if yes
# Return non zero for anything else
fn_is_yes() {
    local yes_maybe=${1}
    if [ "${yes_maybe}" == "y" ] || \
      [ "${yes_maybe}" == "Y" ]; then
        return 0
    elif [ "${yes_maybe}" == "yes" ] || \
      [ "${yes_maybe}" == "Yes" ]; then
        return 0
    elif [ "${yes_maybe}" == "YES" ] || \
      [ "${yes_maybe}" == "YEs" ]; then
        return 0
    else
        return 255
    fi
}


# Check if file exists
fn_is_file() {
	local file_path="${1}"
	if [ -f "${file_path}" ]; then
		return 0
	else
		return 1
	fi
}


# Check if directory exists
fn_is_dir() {
	local dir_path="${1}"
	if [ -d "${dir_path}" ]; then
		return 0
	else
		return 1
	fi
}


# Check if file sha256 matches expected
# Warning: Can not handle paths with spaces!
# Returns OK 0 if a match
# Returns Err !0 if file not found or hash does not match
fn_check_sha256() {
    local hash="${1}"
    local file="${2}"

    if ! fn_is_file "${file}" ; then
        return 255
    else
        echo "${hash} ${file}" | sha256sum --check --strict --status
        return $?
    fi
}


# Check if a process is already running
# Ok 0 means yes it is running
# Err 1 means it is not running
fn_is_running() {
    local process_name="${1}"
	pgrep -x "${process_name}" && {
		return 0
	}
	return 1
}


# Check if a program is not yet installed
# Assumes program supports `--version` to return a version
#
# Returns 1 Err if program is found
# Returns 0 Ok if program command is not found
fn_is_not_installed() {
	local program_name="${1}"
	"${program_name}" --version
	if [ 0 == $? ]; then
		echo "// ${program_name} is installed"
		return 1
	else
		echo "// ${program_name} does not appear to be installed"
		return 0
	fi
}


# Check if $1 string exists in $2 file
# return success if string found
# return error if string not found or file not found
fn_search_file() {
	local target_text="${1}"
	local file_path="${2}"
	if fn_is_file "${file_path}" ; then
		if grep -q "${target_text}" "${file_path}"; then
			echo "// Found text: ${target_text}"
			return 0
		else
			echo "// Did not find text: ${target_text}"
			return 1
		fi
	else
		echo "// Did not find file: ${file_path}"
		return 2
	fi
}


# Remove file if it exists
fn_remove_file() {
	if fn_is_file $1 ; then
		rm $1
		return $?
	else
		return 0
	fi
}


# Check for error from last function
#
# Call like `fn_catch_error $LINENO` to pass line number
fn_catch_error() {
	local last_error=$?
	if [ 0 != ${last_error} ]; then
		echo "// Script error code ${last_error} detected on line $1"
		fn_confirm "Exit failed script" && {
			exit ${last_error}
		}
	fi
}


# Check for empty string
#
# call as fn_is_defined "$<variable>"
#
# return Ok 0 if string has content other than "\n"
# return Err 1 if empty string or just newline
fn_is_defined() {
	if [ "" == ${1} ] || [ "\n" == ${1} ]; then
		return 1
	else
		return 0
	fi
}
