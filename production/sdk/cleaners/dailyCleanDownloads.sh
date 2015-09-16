#!/usr/bin/env bash

# Utility to clean build machine
echo -e "\n\tDaily clean of ${HOSTNAME} download server on $(date )\n"

cDir="/home/data/httpd/download.eclipse.org/eclipse/downloads/drops4"
buildType="N*"
allOldBuilds=$( find ${cDir} -maxdepth 1 -type d -ctime +3 -name "${buildType}" )
nbuilds=$( find ${cDir} -maxdepth 1 -type d -name "${buildType}" | wc -l )
echo -e "\tNumber of N-builds before cleaning: $nbuilds"
#echo -e "\n\tDEBUG: allOldBuilds: \n${allOldBuilds}"

# Make sure we leave at least 4 on DL server, no matter how old
# To avoid 'ls' see http://mywiki.wooledge.org/ParsingLs
# technically, applies to "find" as well.
shopt -s nullglob
count=0
#echo "DEBUG: checking ${cDir}/${buildType}"
files=(${cDir}/${buildType})
# We count on files being "ordered" by date/timestamp in name
for  ((i=${#files[@]}-1; i>=0; --i)); do
  newest[$count]="${files[$i]}"
  #echo "DEBUG: count = $count"
  count=$(( count + 1 ))
  if [ $count -gt 3 ] 
  then 
    break
  fi  
done
#echo "DEBUG: newest (up to 4)"
#for nfile in ${newest[*]}; do
#  echo "$nfile"
#done
#DEBUG    echo -e "\n\tnewest: \n${newest}";
areNotToDelete=$(printf '%s\n' "${newest[@]}" | paste -sd '|')
#echo "DEBUG: areNotToDelete: ${areNotToDelete}"
for buildname in ${allOldBuilds}; do
  if [[ $buildname =~ $areNotToDelete ]]
  then
    echo -e "\tDEBUG: Not removed (since one of 4 newest, even though old): \n\t$buildname"
  else
    rm -fr $buildname
    RC=$?
    if [[ $RC = 0 ]]
    then
      echo -e "Removed: $buildname"
    else
      echo -e "\n\tAn Error occured removeding $buildname. RC: $RC"
    fi
  fi
done

nbuilds=$( find ${cDir} -maxdepth 1 -type d -name "${buildType}" | wc -l )
echo -e "\tNumber of N-builds after cleaning: $nbuilds"

source /shared/eclipse/sdk/updateIndexFilesFunction.shsource >/dev/null
updateIndex >/dev/null
