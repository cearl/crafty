#!/bin/bash
plugins_array=()
##############Automatic##############################
plugins_array+=('boxxworldmap')
plugins_array+=('ghost-hunt')
plugins_array+=('armor-abilities')
plugins_array+=('bkcommonlib')
plugins_array+=('auctions')
plugins_array+=('chestshop')
plugins_array+=('citizens')
plugins_array+=('colorme')
plugins_array+=('antibuild')
plugins_array+=('essentials')
plugins_array+=('factions')
plugins_array+=('fakeplayers')
plugins_array+=('guns')
plugins_array+=('headhunter')
plugins_array+=('herobrineunleashed')
plugins_array+=('idisguise')
plugins_array+=('lockette')
plugins_array+=('logblock')
plugins_array+=('lorelocks')
plugins_array+=('magicspells')
plugins_array+=('mcmmo')
plugins_array+=('mobarena')
plugins_array+=('nocheatplus')
plugins_array+=('nodusclearchat')
plugins_array+=('pvp-arena')
plugins_array+=('pay-for-mob')
plugins_array+=('pets')
plugins_array+=('potionarrows')
plugins_array+=('protocollib')
plugins_array+=('colorsignz')
plugins_array+=('signshop')
plugins_array+=('spawner')
plugins_array+=('simpleskins-reloaded')
plugins_array+=('statues')
plugins_array+=('survival-games')
plugins_array+=('enchanter')
plugins_array+=('vault')
plugins_array+=('worldedit')
plugins_array+=('worldguard')






###############Config ##############################
# 
# IRC:freenode: krisabsinthe42 
# you will need wget,curl and screen installed.
# NOTE: This script grabs the latest DEVELOPMENT build of CraftBukkit by default. 
# 2 Variables need changed for YOUR enviroment 'craftbukkit_branch' and 'minecraft_home'
# I wrote this to be an update script but it can also be used to stand up a Craftbukkit 
# installation from scratch. Just configure the variables and run the script.
craftbukkit_branch="dev"  #uncomment for developemnt builds
#craftbukkit_branch="beta" #uncomment for beta builds
#craftbukkit_branch="rb"   #uncomment for recommended builds
DIR=$(cd $(dirname "$0"); pwd)
minecraft_home="/home/minecraft"
craftbukkit_latest=`curl -s http://dl.bukkit.org/downloads/craftbukkit/list/$craftbukkit_branch/?page=1 | grep \# |grep class| head -1 | sed -e 's/"/ /g' | awk '{print $9}'`
cb_full_path=" http://dl.bukkit.org/downloads/craftbukkit/list/dev$craftbukkit_latest"
cb_version=`echo "$cb_full_path"| sed -e 's/\// /g' | awk '{print $10}'`
out_file="$minecraft_home/craftbukkit.$cb_version.jar"
restart_minecraft="True"
minecraft_proc=`pidof java`
needs_restart="False"
bukkit_org_path_prefix="http://dev.bukkit.org/bukkit-plugins/"
plugin_update_success=()
plugin_update_failure=()
plugins_new=()
echo -en "\n"

function downloader(){
for i in "${plugins_new[@]}"
do
  latest=`curl -s $bukkit_org_path_prefix$i/files/ | grep "col-file" | grep href | grep "td class" | head -1 | sed -e 's/"/ /g' | awk '{print $6}'`
  plugin_download="http://dev.bukkit.org$latest"
  grab_file=`curl -s $plugin_download | grep Download |sed -e 's/"/ /g' | awk '{print $7}'|tr -d '\r'`
  nginx_302=`curl -s -I $grab_file | grep Location |awk '{print $2}'|tr -d '\r'`  
  new_file_size=`curl -s -I $nginx_302 | grep "Content-Length:" | awk '{print $2}'|tr -d '\r'`
  name_of_file=`echo "$nginx_302"| sed -e 's/\// /g'| awk '{print $NF}'|tr -d '\r'`
  old_file_size=`ls -al $minecraft_home/plugins/$name_of_file| awk '{print $5}'`
  file_type=`echo "$name_of_file"| sed -e 's/\./ /g' | awk '{print $NF}'`
  #matches file size to determine if an update is needed
  if [ "$new_file_size" = "$old_file_size" ]; then
      echo -en "-$name_of_file already up-to-date\n"
  else
      echo -en "+Downloading $name_of_file\n"
      wget -nv $grab_file --output-document=$minecraft_home/plugins/$name_of_file >/dev/null 2>&1
      needs_restart="True"
      echo -en "+$name_of_file was updated\e[92m[OK]\e[97m\n"
      #unpack by extention
      if [ "$file_type" == "zip" ];then
          cd $minecraft_home/plugins
          echo -en "+unpacking archive\n"
          unzip -o -qq $name_of_file && plugin_update_success+=($name_of_file) || echo -en "!error unpacking $name_of_file \e[31m[FAIL]\e[97m\n" || plugin_update_failure+=($name_of_file)
      elif [ "$file_type" == "rar" ];then
           cd $minecraft_home/plugins
           echo -en "+unpacking archive\n"
           unrar -o+ $name_of_file &>/dev/null && plugin_update_success+=($name_of_file) || echo -en "!error unpacking $name_of_file \e[31m[FAIL]\e[97m\n"|| plugin_update_failure+=($name_of_file)
      elif [ "$file_type" == "tar" ];then
           cd $minecraft_home/plugins
            echo -en "+unpacking archive\n"
	   tar xf --overwrite $name_of_file && plugin_update_success+=($name_of_file) || echo -en "!error unpacking $name_of_file \e[31m[FAIL]\e[97m\n"|| plugin_update_failure+=($name_of_file)
      elif [ "$file_type" == "tgz" ];then
           cd $minecraft_home/plugins
           echo -e "+ unpacking archive"
           tar zxf --overwrite $name_of_file && plugin_update_success+=($name_of_file) || echo -en "!error unpacking $name_of_file \e[31m[FAIL]\e[97m \n"|| plugin_update_failure+=($name_of_file)
      elif [ "$file_type" == "gz" ];then
           cd $minecraft_home/plugins
           echo -e "+unpacking archive"
      elif [ "$file_type" == "jar" ];then
	   echo -en "No unpacking needed\n"
     else 
	echo -en "*hmmm... file was not zip,rar,tar,tgz,gz or jar \e[31m[FAIL]\e[97m\n"
        echo -en "*manual installation required\n"
        plugin_update_failure+=($name_of_file)
     fi
    
  fi 
    
done

# restart minecraft
if [ "$restart_minecraft" = "True" ];then
        if [ "$needs_restart" = "True" ];then
                echo -en "Restarting Minecraft in screen\n"
                kill -9 $minecraft_proc #die now!
                cd $minecraft_home
                screen -S CraftBukkit -dmS java -Xmx9500M -Xms9500M -jar $out_file nogui || echo -en "-Error starting server back up \e[31m[FAIL]\e[97m"
        fi
else
        echo -en "Please restart minecraft manually or set the restart_minecraft variable as True\n"
fi
}




function updater () {
echo -en "\e[94mChecking Craftbukkit:\e[97m\n--------------------\n"
if [ -e $out_file ];then
	echo -en "CraftBukkit already up-to-date\n"
else  
	echo -en "+Downloading Build#:  $cb_version\n"
	wget -nv http://dl.bukkit.org$craftbukkit_latest --output-document=$minecraft_home/craftbukkit.$cb_version.jar && echo -en "+Craftbukkit updated to $cb_version \e[92m[OK]\n" || echo -en "!Could not download or write to the file system \e[92m[FAIL]\n" 
        needs_restart="True"
fi

#loop that checks all the plugins listed in the plugins_array
echo -en "\e[94mChecking plugins:\e[97m\n--------------------\n"
for i in "${plugins_array[@]}"
do
  latest=`curl -s $bukkit_org_path_prefix$i/files/ | grep "col-file" | grep href | grep "td class" | head -1 | sed -e 's/"/ /g' | awk '{print $6}'`
  plugin_download="http://dev.bukkit.org$latest"
  grab_file=`curl -s $plugin_download | grep Download |sed -e 's/"/ /g' | awk '{print $7}'|tr -d '\r'`
  nginx_302=`curl -s -I $grab_file | grep Location |awk '{print $2}'|tr -d '\r'`  
  new_file_size=`curl -s -I $nginx_302 | grep "Content-Length:" | awk '{print $2}'|tr -d '\r'`
  name_of_file=`echo "$nginx_302"| sed -e 's/\// /g'| awk '{print $NF}'|tr -d '\r'`
  old_file_size=`ls -al $minecraft_home/plugins/$name_of_file| awk '{print $5}'`
  file_type=`echo "$name_of_file"| sed -e 's/\./ /g' | awk '{print $NF}'`
  #matches file size to determine if an update is needed
  if [ "$new_file_size" = "$old_file_size" ]; then
      echo -en "-$name_of_file already up-to-date\n"
  else
      echo -en "+Downloading $name_of_file\n"
      wget -nv $grab_file --output-document=$minecraft_home/plugins/$name_of_file >/dev/null 2>&1
      needs_restart="True"
      echo -en "+$name_of_file was updated\e[92m[OK]\e[97m\n"
      #unpack by extention
      if [ "$file_type" == "zip" ];then
          cd $minecraft_home/plugins
          echo -en "+unpacking archive\n"
          unzip -o -qq $name_of_file && plugin_update_success+=($name_of_file) || echo -en "!error unpacking $name_of_file \e[31m[FAIL]\e[97m\n" || plugin_update_failure+=($name_of_file)
      elif [ "$file_type" == "rar" ];then
           cd $minecraft_home/plugins
           echo -en "+unpacking archive\n"
           unrar -o+ $name_of_file &>/dev/null && plugin_update_success+=($name_of_file) || echo -en "!error unpacking $name_of_file \e[31m[FAIL]\e[97m\n"|| plugin_update_failure+=($name_of_file)
      elif [ "$file_type" == "tar" ];then
           cd $minecraft_home/plugins
            echo -en "+unpacking archive\n"
	   tar xf --overwrite $name_of_file && plugin_update_success+=($name_of_file) || echo -en "!error unpacking $name_of_file \e[31m[FAIL]\e[97m\n"|| plugin_update_failure+=($name_of_file)
      elif [ "$file_type" == "tgz" ];then
           cd $minecraft_home/plugins
           echo -e "+ unpacking archive"
           tar zxf --overwrite $name_of_file && plugin_update_success+=($name_of_file) || echo -en "!error unpacking $name_of_file \e[31m[FAIL]\e[97m \n"|| plugin_update_failure+=($name_of_file)
      elif [ "$file_type" == "gz" ];then
           cd $minecraft_home/plugins
           echo -e "+unpacking archive"
      elif [ "$file_type" == "jar" ];then
	   echo -en "No unpacking needed\n"
     else 
	echo -en "*hmmm... file was not zip,rar,tar,tgz,gz or jar \e[31m[FAIL]\e[97m\n"
        echo -en "*manual installation required\n"
        plugin_update_failure+=($name_of_file)
     fi
    
  fi 
    
done

# reload minecraft
if [ "$restart_minecraft" = "True" ];then
	if [ "$needs_restart" = "True" ];then
		echo -en "Restarting Minecraft in screen\n"
        	kill -9 $minecraft_proc	#die now!
        	cd $minecraft_home
       	        screen -S CraftBukkit -dmS java -Xmx9500M -Xms9500M -jar $out_file nogui || echo -en "-Error starting server back up \e[31m[FAIL]\e[97m"
        fi
else 
	echo -en "Please restart minecraft manually or set the restart_minecraft variable as True\n"
fi

# display any failures

if [ "${#plugin_update_failure[@]}" != "0" ];then
    for i in "${plugin_update_failure[@]}"
    do
       echo -en "-$i failed to update \e[31m[FAIL]\e[97m"
    done
if [ "${#plugin_update_failure[@]}" = "0" ];then
      if [ "${#plugin_update_success[@]}" = "0" ];then
        echo -en "-No updates applied\n"
     else
        echo -en "+Updated:\n ${plugin_update_success[@]}\n"
    fi
 fi

fi

 
if [ "${#plugin_update_success[@]}" = "0" ];then
	echo "No updates applied"
else
	echo -e "Updated:\n ${plugin_update_success[@]}"
fi
}

case "$1" in
       	
-i)  if [ "$2" = "" ];then
        echo "USAGE: script -i \"project name\""
        exit 1
    else
        query=`echo $2 | sed -e 's/ /+/g'|sed 's/[!@#\$%^&=*()]//g'`
	search=`curl -s -A Mozilla "http://www.google.com/search?q=bukkit+$query"|sed -e 's/\s\+/\n/g'| grep bukkit.org | head -1 | sed -e 's/"/ /g'| sed -e 's/url?q=/ /g'| awk -F \& '{print $1}'| awk '{print $3}'| grep bukkit-plugins`
        project_name=`echo "$search" |sed -e 's/\// /g' | awk '{print $NF}'`
	if [ "$project_name" = "" ];then
	   echo "Unable to guess project name"
	   exit 0   
	else
           echo -en "Project page: \e[92m'$search'\e[97m\n"
	   echo -en "Installable Name: \e[93m$project_name \e[97m\n"
           echo -en "Continue installation of \e[93m$project_name \e[97m(y/n)"
           read response
		if [ "$response" = "y" ];then
                  running_script="$DIR/$0"
                  current_plugins=`cat $running_script | grep plugins_array | grep -v \# |sed 's/[!@#\$%^&=*()]/ /g' | head -1|sed -e 's/ /\n/g' | grep -v plugins_array | grep -v "^$" | awk -F \' '{print $2}'`
                  concat_plugins_list=`echo -en "$current_plugins\n$project_name"| grep -v "^$"`
                  echo "$concat_plugins_list"
		  line_count=`cat $running_script|wc -l`
                  line_to_write_after=3
                  tail_size=`expr $line_count - $line_to_write_after`
		  head_script=`head -$line_to_write_after $running_script`
                  tail_script=`tail -$tail_size $running_script`
                  plugs_list=`echo "$concat_plugins_list"|while read a; do echo "plugins_array+=('$a')"|uniq ;done`
                  #adds new plugins back into this script
		  echo "$head_script" > $running_script.swp || exit 1
		  echo "$plugs_list" >> $running_script.swp || exit 1
	          echo "$tail_script" >> $running_script.swp || exit 1
		  mv $running_script.swp $running_script 
		  echo "Triggering install"
	 	  plugins_new+=("$project_name")
		  downloader
                fi
	exit 0
	fi
    fi
    ;;
    
esac
# Defaults to update (cron friendly)
updater

	
