function giefpass
   # EASY SETTINGS
   set EASY_PW_MAX 12
   set EASY_PW_INCLUDE_NUMBERS false

   # MEDIUM SETTINGS
   set MEDIUM_PW_MAX 32

   # HARDCORE SETTINGS
   set HARDCORE_PW_MAX 128

   # if $EASY_PW_INCLUDE_NUMBERS
   #    echo "True"
   # else
   #    echo "False"
   # end

set ENTROPY (cat /proc/sys/kernel/random/entropy_avail)
if [ $ENTROPY -lt 4000 ]
    echo "It's lower!"
else
   echo "its higher"
end

   return 

   # Check entropy requirements
   set ENTROPY_AVAIL (cat /proc/sys/kernel/random/entropy_avail)
   if [ $ENTROPY -lt 4000 ]
      echo "Woopsie, entropy_avail is lower then 4000"
   else
      echo "/proc/sys/kernel/random/entropy_avail = $ENTROPY_AVAIL" 
   end   
   return 

set ENTROPY (cat /proc/sys/kernel/random/entropy_avail)
if test (ENTROPY) -lt 4000:
   echo "Oof, entropy_avail is lower then 4000"
else
   echo "OKAY /proc/sys/kernel/random/entropy_avail = $ENTROPY_AVAIL" 
end

   return

   set pwfile /tmp/.pwngen
   touch "$pwfile"
   chmod 700 "$pwfile"
   echo "" > "$pwfile"
printf "\
 ██████  ██ ███████ ███████ ██████   █████  ███████ ███████ 
██       ██ ██      ██      ██   ██ ██   ██ ██      ██      
██   ███ ██ █████   █████   ██████  ███████ ███████ ███████ 
██    ██ ██ ██      ██      ██      ██   ██      ██      ██ 
 ██████  ██ ███████ ██      ██      ██   ██ ███████ ███████    
" | cat
   echo ""
   echo "Made with ❤️️  for FOSS and privacy"
   echo ""
   echo " - EDITOR: $EDITOR"
   echo " - EASY_PW_MAX: $EASY_PW_MAX"
   echo " - MEDIUM_PW_MAX: $MEDIUM_PW_MAX"
   echo " - HARDCORE_PW_MAX: $HARDCORE_PW_MAX"

   echo "----------- EASY PASSWORDS -----------" >> "$pwfile"
   # pwgen -c $pw_max_length -n -C 4 >> "$pwfile"
   # echo "--------------------------------------" >> "$pwfile"
   # pwgen -c $pw_max_length -ny -C 4 >> "$pwfile"
   # echo "--------------------------------------" >> "$pwfile"
   # pwgen -c $pw_max_length -nyc0 -C 4 >> "$pwfile"
   # echo "--------------------------------------" >> "$pwfile"
   # pwgen -yCsBv0 -c $pw_max_length -C 4 >> "$pwfile"
   # echo "--------------------------------------" >> "$pwfile"
   # pwgen -n -c 64 -C 4 >> "$pwfile"
   # echo "--------------------------------------" >> "$pwfile"
   # pwgen -n -c 32 -C 4 >> "$pwfile"
   # $EDITOR "$pwfile"
   rm "$pwfile"
end
