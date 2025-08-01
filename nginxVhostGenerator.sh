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

    ## Private IP to variable, filter private IP of server
    privateIP=$(hostname -i | awk '{print $1}')

    ## Questions for VirtualHost, all assume a flag wasn't passed
    ### Domain
    if [[ -z $siteDomain ]]; then
            printf "%s\n" \
            "${yellow}What is the Domain?" \
            "----------------------------------------------------" \
            "Ex. rustyspoon.com" \
            " " \
            "Enter site domain to use:${normal}" \
            " "
            read siteDomain
    fi

    ### WWW Redirect?
    if [[ -z $wwwRedirect ]]; then
            printf "%s\n" \
            "${yellow}Is there a WWW Redirect?" \
            "----------------------------------------------------" \
            "WWW redirect for domain?" \
            "This is not needed if there isn't a CNAME redirect." \
            " " \
            "Ex. www.rustyspoon.com would redirect to rustyspoon.com" \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read wwwRedirect
    fi

    ### HTTP -> HTTPS?
    if [[ -z $httpRedirect ]]; then
            printf "%s\n" \
            "${yellow}Should HTTP traffice redirect to HTTPS?" \
            "----------------------------------------------------" \
            "Redirect HTTP (port 80) traffic to HTTPS on (port 443)? " \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read httpRedirect
    fi

    ### Docroot defined?
    if [[ -z $docrootDefined ]]; then
            printf "%s\n" \
            "${yellow}Is there a Docroot?" \
            "----------------------------------------------------" \
            "Should a Docroot be defined?" \
            "This option should not be used with Proxy Pass" \
            " " \
            "A Generic docroot will be defined" \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read docrootDefined
    fi

    ### Proxy Pass to another server?
    if [[ -z $proxyPass ]]; then
            printf "%s\n" \
            "${yellow}Is there a Proxy Pass?" \
            "----------------------------------------------------" \
            "Will traffic be proxied to another server?" \
            "This option should not be used with Docroot" \
            " " \
            "A Generic Proxy Pass will be defined " \
            " " \
            "Enter: 1 for yes or 0 for no${normal}" \
            " "
            read proxyPass
    fi

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
    if [[ -f output/$siteDomain.conf ]]; then
            mv output/$siteDomain.conf output/$siteDomain.$(date +%Y%m%d).conf-DIS
    fi

    ## Begin HTTP Virtualhost section
    ### If HTTP -> HTTPS = 1
    if [[ $httpRedirect -eq "1" ]]; then
        echo "# HTTP Section" >> output/$siteDomain.conf
        echo "server {" >> output/$siteDomain.conf
        echo "    ## Listen on HTTP port" >> output/$siteDomain.conf
        echo "    listen 80;" >> output/$siteDomain.conf
        echo "    listen [::]:80;" >> output/$siteDomain.conf

        ### If WWW Redirect = 1 append www to domain
        if [[ $wwwRedirect -eq "1" ]]; then
            redirectDomain+="$siteDomain www.$siteDomain"
            echo "    " >> output/$siteDomain.conf
            echo "    ## Domain" >> output/$siteDomain.conf
            echo "    server_name $redirectDomain;" >> output/$siteDomain.conf
        else
            echo "    " >> output/$siteDomain.conf
            echo "    ## Domain" >> output/$siteDomain.conf
            echo "    server_name $siteDomain;" >> output/$siteDomain.conf
        fi

        #### Redirect to HTTPS
            echo "    " >> output/$siteDomain.conf
            echo "    ## Redirect to HTTPS, use 302 for SEO" >> output/$siteDomain.conf
            echo "    return 302 https://\$host\$request_uri;" >> output/$siteDomain.conf

        ## Close HTTP Virtualhost section
        echo "}" >> output/$siteDomain.conf
        echo "    " >> output/$siteDomain.conf
    fi

    ### Begin HTTPS Virtualhost section
    echo "# HTTPS Section" >> output/$siteDomain.conf
    echo "server {" >> output/$siteDomain.conf
    echo "    ## Listen on HTTPS port" >> output/$siteDomain.conf
    echo "    listen 443 ssl;" >> output/$siteDomain.conf
    echo "    listen [::]:443 ssl;" >> output/$siteDomain.conf

    #### If WWW Redirect = 1
    if [[ $wwwRedirect -eq "1" ]]; then
        ##### Edge case from testing
        if [[ $wwwRedirect -eq "1" && $httpRedirect -eq "0" ]]; then
            redirectDomain+="$siteDomain www.$siteDomain"
        fi
        echo "    " >> output/$siteDomain.conf
        echo "    ## Domain" >> output/$siteDomain.conf
        echo "    server_name $redirectDomain;" >> output/$siteDomain.conf
    else
        echo "    " >> output/$siteDomain.conf
        echo "    ## Domain" >> output/$siteDomain.conf
        echo "    server_name $siteDomain;" >> output/$siteDomain.conf
    fi

    ### Logging
    echo "    " >> output/$siteDomain.conf
    echo "    ## Logging" >> output/$siteDomain.conf
    echo "    access_log /var/log/nginx/$siteDomain.access.log;" >> output/$siteDomain.conf
    echo "    error_log  /var/log/nginx/$siteDomain.error.log error;" >> output/$siteDomain.conf


    ### SSL Placeholder
    echo "    " >> output/$siteDomain.conf
    echo "    ## SSL Configurations" >> output/$siteDomain.conf
    echo "    ### SSL Protocols to use" >> output/$siteDomain.conf
    echo "    ssl_protocols TLSv1.2 TLSv1.3;" >> output/$siteDomain.conf
    echo "    " >> output/$siteDomain.conf
    echo "    #TODO: Update ciphers as needed" >> output/$siteDomain.conf
    echo "    ### SSL Ciphers to allow/deny" >> output/$siteDomain.conf
    echo "    ssl_ciphers \"ECDH+AESGCM:ECDH+CHACHA20:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS\";" >> output/$siteDomain.conf
    echo "    " >> output/$siteDomain.conf
    echo "    #TODO: Replace with proper SSL filepath" >> output/$siteDomain.conf
    echo "    ### SSL Cert and Key" >> output/$siteDomain.conf
    echo "    ssl_certificate /path/to/cert;" >> output/$siteDomain.conf
    echo "    ssl_certificate_key /path/to/key;" >> output/$siteDomain.conf

    ### Proxy Pass to another server?
    if [[ $proxyPass -eq "1" ]]; then
        echo "    " >> output/$siteDomain.conf
        echo "    #TODO: Replace with proper server IP" >> output/$siteDomain.conf
        echo "    ## Proxy Pass" >> output/$siteDomain.conf
        echo "    location / {" >> output/$siteDomain.conf
        echo "        proxy_pass https://SERVER_IP/;" >> output/$siteDomain.conf
        echo "    }" >> output/$siteDomain.conf
    fi

    ### Create a docroot for domain?
    if [[ $docrootDefined -eq "1" ]]; then
        echo "    " >> output/$siteDomain.conf
        echo "    #TODO: Adjust docroot filepath as needed" >> output/$siteDomain.conf
        echo "    ## Docroot" >> output/$siteDomain.conf
        echo "    root /var/www/$siteDomain;" >> output/$siteDomain.conf
        echo "    " >> output/$siteDomain.conf
        echo "    ## Docroot Index" >> output/$siteDomain.conf
        echo "    try_files index.html index.php;" >> output/$siteDomain.conf
        echo "    " >> output/$siteDomain.conf
        echo "    ## Disable symlink handling" >> output/$siteDomain.conf
        echo "    disable_symlinks on;" >> output/$siteDomain.conf
    fi

    ### File blocks
    echo "    " >> output/$siteDomain.conf
    echo "    #TODO: Expand/adjust as needed" >> output/$siteDomain.conf
    echo "    ## Filepath Blocks" >> output/$siteDomain.conf
    echo "    ### Block access to xmlrpc.php" >> output/$siteDomain.conf
    echo "    location /xmlrpc.php {" >> output/$siteDomain.conf
    echo "        deny all;" >> output/$siteDomain.conf
    echo "        return 403;" >> output/$siteDomain.conf
    echo "    }" >> output/$siteDomain.conf
    echo "    " >> output/$siteDomain.conf
    echo "    ### Deny access to backup/config files" >> output/$siteDomain.conf
    echo "    location ~* \.(bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist|gz|bz|dump|zip|gzip)$ {" >> output/$siteDomain.conf
    echo "        deny all;" >> output/$siteDomain.conf
    echo "        return 403;" >> output/$siteDomain.conf
    echo "    }" >> output/$siteDomain.conf

    ### Close HTTPS Virtualhost tag
    echo "}" >> output/$siteDomain.conf

    ## Closing notes
    printf "%s\n" \
    "${green}VirtualHost generated" \
    "----------------------------------------------------" \
    "Check output dir" \
    "Verify values correct before deploying VirtualHost${normal} "

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
