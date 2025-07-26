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
    "Usage. ./nginxVhostGenerator.sh generate DOMAIN WWW_REDIRECT? HTTP_TO_HTTPS? DOCROOT? PROXY_PASS?" \
    "Ex. ./nginxVhostGenerator.sh generate rustyspoon.com 1 1 1 0" \
    " " \
    "See README for breakdown of questions" \
    "If unsure, run guided script."
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Generate" \
    "----------------------------------------------------"

    ## Variables
    siteDomain=$1
    wwwRedirect=$2
    httpRedirect=$3
    docrootDefined=$4
    proxyPass=$5

    ## Create output directory if it doesn't exist
    if [[ ! -f output ]]; then
            mkdir output
    fi

    ## RPM/DEB check, assign filepath variables based on output

    ## Private IP to variable, filter private IP of server
    privateIP=$(hostname -i | awk '{print $1}')

    ## Questions for VirtualHost, all assume a flag wasn't passed
    ### Domain
    ### WWW Redirect?
    ### HTTP -> HTTPS?
    ### Docroot defined?
    ### Proxy Pass to another server?

    ## Value Confirmation, last chance to bail out
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Site Domain: " "$siteDomain" \
    " " \
    "Should there be a WWW Redirect?" "$wwwRedirect" \
    " " \
    "Should there be a HTTP -> HTTPS Redirect?" "$httpRedirect" \
    " " \
    "Should a Docroot be defined?" "$docrootDefined" \
    " " \
    "Should a Proxy Pass be defined?" "$proxyPass" \
    " " \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "
    read junkInput

    ## Check for vhost with file name already, move to new name and disable old vhost if so

    ## Begin HTTP Virtualhost section
    ### If HTTP -> HTTPS = 1
    #### If WWW Redirect = 1
    #### Redirect to HTTPS
    #### Close HTTP Virtualhost section

    ### Begin HTTPS Virtualhost section

    #### If WWW Redirect = 1

    ### Logging

    ### SSL Placeholder

    ### Proxy Pass to another server?

    ### Create a docroot for domain?
    ### Close HTTPS Virtualhost tag

    ## Closing notes

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
