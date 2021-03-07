#!/usr/bin/env bash

###########################################################################
###
###   Utility-Script to make zipping and unzipping of "per-environment"
###     config files easier.
###
###   Does not need any CLI args (but may support them optionally soon),
###     but asks everything (on CLI or via zenity, if installed).
###
###   The zenity popup sometimes won't appear in front of the shell.
###     Give something as $1 (e.g. "nogui") to avoid using zenity, even if
###     it is installed.
###
###   So, on a Mac/Linux with GUI, you can install zenity to use graphical
###     popups:
###     * Mac: brew install zenity
###     * Debian/Ubuntu/...: apt-get install zenity
###
###########################################################################

# Set "existsZenity" to true/false (Added $1 to zenity to prevent finding it)
existsZenity=`which zenity$1 > /dev/null && echo true || echo false`

# Set to true/false depending
exists7zip=`which 7z > /dev/null && echo true || echo false`

if [[ "$exists7zip" == "false" ]]
then
    echo "7zip command (7z) not found! Please install packet 'p7zip'!"
    exit 1
fi

caution="CAUTION: Never commit the files in jenkins/configs/vault/!"

# Let z==Z in comparisons so that the user may enter any of them.
shopt -s nocasematch

# Outputs the args to zenity resp. stderr
function info() {
    if [[ ${existsZenity} == true ]]
    then
        zenity --info --width 600 --text="$@"
    else
        echo -e "$@"
    fi
}

# Makes a list of given Arguments. $1=separator (before each argument), $(2..n)=text
# Example: makeList ", name=" ralf ludwig tobi
#          will output: ", name=ralf, name=ludwig, name=tobi"
function makeList() {
    sep=$1
    shift
    for element in "$@"
    do
        echo -n "${sep}${element}"
    done
}

# Makes an initials list of given Arguments. $1=separator (before each argument), $(2..n)=text
# Example: makeList " and " ralf ludwig tobi
#          will output: " and r=ralf and l=ludwig and t=tobi"
function makeInitialsList() {
    sep=$1
    shift
    for element in "$@"
    do
        echo -n "${sep}${element:0:1}=${element}"
    done
}

# $1=Prompt $2=Option1 $3=Option2 ...
function askAlternatives() {
    prompt=$1
    shift
    if [[ ${existsZenity} == true ]]
    then
        options=`makeList " --extra-button " "$@"`
        retVal=`zenity --info --width 600 --title 'Please choose' --text "${prompt}" --ok-label Cancel ${options}`
    else
        options=`makeInitialsList "/" "$@"`
        read -p "$prompt (${options:1}) " -n 1 -r
        for option in "$@"
        do
            [[ $REPLY == ${option:0:1} ]] && retVal=${option}
        done
    fi
    echo -n ${retVal}
}

function askPassword() {
    if [[ ${existsZenity} == true ]]
    then
        retVal=`zenity --password --width 600 --title 'Please enter password' --text "Please enter the password"`
    else
        read -p "Please enter the password: " -s retVal
    fi
    echo -n ${retVal}
}

info "${caution}"

mode=`askAlternatives "Crypt or Decrypt it?" Crypt Decrypt`
# Make the CR. Exit if cancelled / invalid option
echo && [[ -z "$mode" ]] && exit 2

echo "Mode: ${mode}"


password=`askPassword`

# if there is a password, prefix it with "-p"
[[ -z "$password" ]] || password="-p${password}"

if [[ "${mode}" == "Crypt" ]]
then
    rm -f jenkins/configs/vault.7z
    7z a ${password} jenkins/configs/vault.7z jenkins/configs/vault/*
    rm -rf jenkins/configs/vault/*
else
    [ ! -d "$dldir" ] && mkdir -p "$dldir"
    7z x ${password} jenkins/configs/vault.7z jenkins/configs/vault/
fi
