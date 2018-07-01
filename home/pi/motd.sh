
# Install:
# sudo cp ~/motd.sh /etc/profile.d/motd.sh
# sudo chown root:root /etc/profile.d/motd.sh
# sudo chmod +x /etc/profile.d/motd.sh
# sudo rm /etc/motd
#
# Change #PrintLastLog yes --- to "no"
# sudo nano /etc/ssh/sshd_config

let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh %02dm %02ds" "$days" "$hours" "$mins" "$secs"`

# get the load averages
read one five fifteen rest < /proc/loadavg

echo "$(tput setaf 2)
   .~~.   .~~.    `date +"%A, %e %B %Y, %r"`
  '. \ ' ' / .'   Uptime: ${UPTIME}$(tput setaf 1)
   .~ .~~~..~.
  : .~.'~'.~. :   CPU Temperature....: `exec -- /opt/vc/bin/vcgencmd measure_temp | cut -c "6-9"`
 ~ (   ) (   ) ~  Load Averages......: ${one}, ${five}, ${fifteen}
( : '~'.~.'~' : ) Running Processes..: `ps ax | wc -l | tr -d " "`
 ~ .~ (   ) ~. ~  Connections........: Established: `sudo netstat -anp | grep -w 42423 | grep ESTABLISHED | wc -l` | All: `sudo netstat -anp | grep -w 42423 | wc -l`
  (  : '~' :  )   Disk Space.........: Free: `df -Ph | grep -E '^/dev/root' | awk '{ print $4 }'` | Used: `df -Ph | grep -E '^/dev/root' | awk '{ print $3 }'` $(tput setaf 2)`df -Ph | grep -E '^/dev/root' | awk '{ print $5 }'`$(tput setaf 1)
   '~ .~~~. ~'    
       '~'
$(tput sgr0)"
