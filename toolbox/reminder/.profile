reminder() {
   arg=$1
   if [ -z $arg ]; then
      ls ${DRM}/toolbox/reminder/ | grep -e '\w*\.reminder' | cut -f1 -d.
      return
   fi

   valid=0
   ls ${DRM}/toolbox/reminder/ | cut -f1 -d. | while read -r line; do
     if [[ $line == $arg ]]; then
         valid=1 
     fi
   done

   if [[ $valid == "0" ]]; then
      echo "Unknown arguments $arg, try to add ${arg}.reminder"
      return
   fi
   echo "\n"

   if [ -z $2 ]; then
       cat ${DRM}/toolbox/reminder/${arg}.reminder 
   elif [[ x"$2" == "xls" ]]; then
       cat ${DRM}/toolbox/reminder/${arg}.reminder | grep -e '\`.*\`'
   else
       key="\`$2\`"
       cat ${DRM}/toolbox/reminder/${arg}.reminder | sed -n "/$key/I,/\`/p"
   fi
   echo "\n"
  
}
remindex() {
   arg=$1
   if [ -z $arg ]; then
      ls ${DRM}/toolbox/reminder/ | grep -e '\w*\.reminder' | cut -f1 -d.
      return
   fi

   valid=0
   ls ${DRM}/toolbox/reminder/ | cut -f1 -d. | while read -r line; do
     if [[ $line == $arg ]]; then
         valid=1
     fi
   done

   if [[ $valid == "0" ]]; then
      echo "Unknown arguments $arg, try to add ${arg}.reminder"
      return
   fi
   echo "\n"
   vi ${DRM}/toolbox/reminder/${arg}.reminder
   echo "\n"

}


