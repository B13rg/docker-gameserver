#!/bin/bash

echo "Fetching server list"
curl -o ./data/serverlist.csv "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/serverlist.csv"

export conf="./data/shortnamearray.json"
echo '{"include": {}}' > $conf

# convert csv to json
while read -r line; do
  export shortname=$(echo "$line" | awk -F, '{ print $1 }')
  export servername=$(echo "$line" | awk -F, '{ print $2 }')
  export gamename=$(echo "$line" | awk -F, '{ print $3 }')
  export distro=$(echo "$line" | awk -F, '{ print $4 }')

  yq -iP '.include[strenv(shortname)]={"shortname": strenv(shortname),"servername": strenv(servername),"gamename": strenv(gamename),"distro": strenv(distro)}' ./data/shortnamearray.json -o json
done < <(tail -n +2 ./data/serverlist.csv)

echo "Found $(yq '.include | keys | length' ${conf}) items"

echo "Fetching distro package lists"
while read -r distro; do
  curl -o "./data/${distro}.csv" "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/data/${distro}.csv"
  # load into conf file
  while read -r line; do
    # add package lists to config
    export shortname=$(echo $line | awk -F "," '{print $1}')
    export pkgs=$(echo $line | awk -v shortname="${shortname}" -F, '$1==shortname {$1=""; print $0}')
    if [ -n "${pkgs}" ]; then
      yq -iP '.include[strenv(shortname)].pkgs=strenv(pkgs)' ./data/shortnamearray.json -o json
    fi
  done < <(tail -n +3 ./data/${distro}.csv)
  # first line all
  # second line steamcmd
done < <(yq -r '[.include.*.distro] | unique[]' ${conf})

echo "Fetching server configs"
while read -r server; do
  mkdir -p ./data/server_cfg
  curl -o "./data/server_cfg/${server}.cfg" "https://raw.githubusercontent.com/GameServerManagers/LinuxGSM/master/lgsm/config-default/config-lgsm/${server}server/_default.cfg"
  # load port configs into conf file
  while read -r line; do
    export portid=$(echo $line | awk -F "=" '{print $1}')
    export portnum=$(echo $line | awk -F "=" '{print $2}' | tr -d '"')
    server=$server yq -iP '.include[strenv(server)].ports[strenv(portid)]=strenv(portnum)' ./data/shortnamearray.json -o json
  done < <(grep '^\w*port\w*=' ./data/server_cfg/${server}.cfg)
done < <(yq -r '.include | keys[]' ${conf})
