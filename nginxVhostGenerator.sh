#!/usr/bin/bash

# Nginx Vhost Generator
# BASH script to generate an Nginx Vhost
# By Nicholas Grogg

# Color variables
## Errors
red=$(tput setaf 1)
## Clear checks
green=$(tput setaf 2)
## User input required
yellow=$(tput setaf 3)
## Set text back to standard terminal font
normal=$(tput sgr0)


# Help function
function helpFunction(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "generate/Generate" \
    "* Generate an Nginx Vhost" \
    "* Designed for DEB/RPM servers only" \
    "* Saves to a locally created output folder" \
    "Usage, ./nginxVhostGenerator.sh generate" \
    " " \
    "Script can also take answer to questions as arguments" \
    "Answer 1 for yes and 0 for no" \
    "Usage. ./nginxVhostGenerator.sh generate DOMAIN WWW_REDIRECT? HTTP_TO_HTTPS? WORDPRESS? DOCROOT? PROXY_PASS?" \
    "Ex. ./nginxVhostGenerator.sh generate rustyspoon.com 1 1 0 1 0" \
    " " \
    "See README for breakdown of questions" \
    "If unsure, run guided script."
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Generate" \
    "----------------------------------------------------"
}

# Main, read passed flags
printf "%s\n" \
"Nginx Vhost Generator" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------"

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    helpFunction
    exit
    ;;
[Gg]enerate)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2 $3 $4 $5 $6 $7
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    helpFunction
    exit
    ;;
esac
