#!/bin/bash
: '
 * @author [Femi Awe]
 * @email [fawe@cisco.com]
 * @desc [SE Hackathon - DNAC data into Grafana]
'

# Authentication
DNA_URL="https://sandboxdnac.cisco.com" 
auth_URL="/dna/system/api/v1/auth/token"
basic_auth="ZGV2bmV0dXNlcjpDaXNjbzEyMyE="

# URLs
site_health="/dna/intent/api/v1/site-health"
network_health="/dna/intent/api/v1/network-health"
client_health="/dna/intent/api/v1/client-health"
devices_list="/dna/intent/api/v1/network-device"

#DNA directory
DNA_directory="/home/dna/"

#Function to reset CLI color to default white 
default-color()
{
   echo -e "\e[0m" 
}

#Site health function
get_site_health ()
{
    #API to get site_health and save it as site_health.json
    site_health_json=$(curl -k "$DNA_URL$site_health" \
    -X GET -H "x-auth-token: $token" | python -mjson.tool > "$DNA_directory"site_health.json)
    #Save site_health file as csv
    site_health_csv=$(jq -r '.response[] | [.clientHealthWired, .networkHealthAccess, .networkHealthCore, .networkHealthDistribution, .networkHealthRouter, .siteName, .siteType, .clientHealthWireless, .networkHealthOthers, .networkHealthWireless] |  @csv' "$DNA_directory"site_health.json > "$DNA_directory"site_health.csv)
} #End of get network_health

#Network health function
get_network_health () 
{
    #API to get network_health and save it as network_health.json
    network_health_json=$(curl -k "$DNA_URL$network_health" \
    -X GET -H "x-auth-token: $token" | python -mjson.tool > "$DNA_directory"network_health.json)
    #Save network_health as csv
    network_health_csv=$(jq -r '.healthDistirubution[] | [.category, .goodPercentage, .healthScore] |  @csv' "$DNA_directory"network_health.json > "$DNA_directory"network_health.csv)

} #End of get network_health

#Client health function
get_client_health () 
{
    #API to get client_health and save it as client_health.json
    client_health_json=$(curl -k "$DNA_URL$client_health" \
    -X GET -H "x-auth-token: $token" | python -mjson.tool > "$DNA_directory"client_health.json)
    #Save client_health as csv
    client_health_csv=$(jq -r '.response[].scoreDetail[] | [.scoreCategory.value, .scoreValue ] |  @csv' "$DNA_directory"client_health.json > "$DNA_directory"client_health.csv)

} #End of get client_health

#Site health function
get_devices_list ()
{
    #API to get devices_list and save it as devices_list.json
    devices_list_json=$(curl -k "$DNA_URL$devices_list" \
    -X GET -H "x-auth-token: $token" | python -mjson.tool > "$DNA_directory"devices_list.json)
    #Save devices_list file as csv
    devices_list_csv=$(jq -r '.response[] | [.lastUpdated, .upTime, .collectionStatus, .hostname, .macAddress, .managementIpAddress, .role, .platformId, .softwareVersion] |  @csv' "$DNA_directory"devices_list.json > "$DNA_directory"devices_list.csv)
} #End of get devices_list

#Function to get token, site_health, network_health, client_health and devices_list from Cisco DNA center and 
get_health ()
{
statuscode=$(curl -k -o /dev/null --silent --head --write-out '%{http_code}\n' "$DNA_URL$auth_URL" \
             -X POST -H "Authorization: Basic $basic_auth" )
    if [ "$statuscode" -eq 200 ]; then
        token_url=$(curl -k "$DNA_URL$auth_URL" \
        -X POST -H "Authorization: Basic $basic_auth" )
        #sed to remove first 10 characters and 2 last characters.
        token=$(echo "$token_url" | sed -e 's/^.\{10\}//' -e 's/.\{2\}$//')
        #Call all functions
        get_site_health
        get_network_health
        get_client_health
        get_devices_list
    else
        echo -e "\e[91m\nToken can not be creating, please check URL or Base code\nError HTTP Code is: $statuscode"
        default-color
        exit
    fi
} #End of get_health function
#Call get_health function
get_health

#Database
#Change schema and infile location if needed 
mysql -uroot -p$dbPasswd << EOF
use mysql;
use DNA;
-- Truncate site_health table and re-add data again
truncate table site_health;
load data local infile "/home/dna/site_health.csv" 
    into table site_health 
    fields terminated by','
    OPTIONALLY ENCLOSED BY '"'
    lines terminated by'\n'
    (clientHealthWired, networkHealthAccess, networkHealthCore, networkHealthDistribution, networkHealthRouter, siteName, siteType, clientHealthWireless, 
    networkHealthOthers, networkHealthWireless) 
    set datetime = now(), id = null;
-- End of site_health

-- Truncate devices_list table and re-add data again
truncate table devices_list;
load data local infile "/home/dna/devices_list.csv" 
    into table devices_list 
    fields terminated by','
    ENCLOSED BY '"'
    lines terminated by'\n'
    (lastUpdated, upTime, collectionStatus, hostname, macAddress, managementIpAddress, role, platformId, softwareVersion) 
    set datetime = now(), id = null;
-- End of site_health

-- Fills up network_health table with new data
load data local infile "/home/dna/network_health.csv" 
    into table network_health
    fields terminated by','
    OPTIONALLY ENCLOSED BY '"'
    lines terminated by'\n'
    (category, goodPercentage, healthScore)
    set datetime = now(), id = null;
-- End of adding data into network_health table

-- Truncate client_health table and re-add data again
truncate table client_health;
load data local infile "/home/dna/client_health.csv" 
    into table client_health
    fields terminated by','
    OPTIONALLY ENCLOSED BY '"'
    lines terminated by'\n'
    (category, scoreDetail)
    set datetime = now(), id = null;
-- End of client_health
EOF

#End of Bash Script
