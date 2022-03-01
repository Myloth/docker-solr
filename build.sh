#!/bin/bash
# Read and parse single section in INI file

# Get/Set single INI section
GetINISection() {
  local filename="$1"
  local section="$2"

  array_name="configuration"
  declare -g -A ${array_name}
  eval $(awk -v configuration_array="${array_name}" \
             -v members="$section" \
             -F= '{
                    if ($1 ~ /^\[/)
                      section=tolower(gensub(/\[(.+)\]/,"\\1",1,$1))
                    else if ($1 !~ /^$/ && $1 !~ /^;/) {
                      gsub(/^[ \t]+|[ \t]+$/, "", $1);
                      gsub(/[\[\]]/, "", $1);
                      gsub(/^[ \t]+|[ \t]+$/, "", $2);
                      if (section == members) {
                        if (configuration[section][$1] == "")
                          configuration[section][$1]=$2
                        else
                          configuration[section][$1]=configuration[section][$1]" "$2}
                      }
                    }
                    END {
                        for (key in configuration[members])
                          print configuration_array"[\""key"\"]=\""configuration[members][key]"\";"
                    }' ${filename}
        )
}

if [ "$#" -eq "1" ] && [ -n "$1" ]; then
  filename='./configsets/parameters.ini'
  section="$1"
  GetINISection "$filename" "$section"

  for key in $(eval echo $\{'!'configuration[@]\}); do
          echo -e "  ${key} = $(eval echo $\{configuration[$key]\}) (access it using $(echo $\{configuration[$key]\}))"
  done
else
  echo "missing INI file and/or INI section"
fi

IFS=','
collections=(${configuration[COLLECTIONSUFFIX]})
aliases=(${configuration[ALIASSUFFIX]})

make update-config CONFIG=${section}

for (( i=0 ; i<${#collections[*]} ; i++ )) ; do
   make create NAME=${section}_${collections[$i]} CONFIG=$section SHARDS=${configuration[NBSHARDS]} REPLICAS=${configuration[NBREPLICA]}
done

for (( i=0 ; i<${#aliases[*]} ; i++ )) ; do
    make create-alias NAME=${section}_${collections[$i]} ALIAS=${section}_${aliases[$i]}
done

