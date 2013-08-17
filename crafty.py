#!/usr/local/bin/python
import sys
import pycurl
from string import maketrans 
import cStringIO
import re
import urllib
import glob
import os
# Set Your MC directory
minecraftHome = "/home/minecraft/"
projectHome = []
plugin_versions = []
new_plugin = ""
plugsList = []
plugsName = []
class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

    def disable(self):
        self.HEADER = ''
        self.OKBLUE = ''
        self.OKGREEN = ''
        self.WARNING = ''
        self.FAIL = ''
        self.ENDC = ''


def usage():
    print("Install a plugin: Crafty 'plugin-name'")
    print("Update plugins and CraftBukkit just run Crafty with no options")
    print("Examples:")
    print("---------")
    print("Crafty                        Downloads and installs all updates")
    print('Crafty "worldedit"            Downloads and installs the WorldEdit plugin')
    print('Crafty "tim the enchanter"    Downloads and installs Tim the Enchanter plugin') 


def getPlugs():
    print ("Determining installed Plugins")
    plugsList = glob.glob(minecraftHome+"plugins/*.jar") 
    for item in plugsList:
     #unzip -c GunsPlus.jar plugin.yml | grep name|  sed -e 's/name\://g'
        #print("unzip -c " + item + " plugin.yml")
        p = os.popen("unzip -c " + item + " plugin.yml | grep '^name:'","r")
        while 1:
            line = p.readline()
            if not line: break
            if "name:" in line:
                line = re.sub('\n',"",line)
                line = re.sub('\r',"",line)
                line = re.sub("name:","",line)
                line = re.sub(" ","",line)
                plugsName.append(line) 
    print plugsName
def updatePlugs():
    print("Checking Plugins:")
    return(0)


def updateBukkit():
    print("Checking Craftbukkit:")
    return(0)





def search(plugin):
    # This is by no means perfect but it works surprisingly well!

    print("")
    print(bcolors.OKGREEN + "Looking up on Bing:"+ bcolors.ENDC)
    print("")
    # user input formatting
    buf = cStringIO.StringIO()
    intab = " "
    outtab = "+"
    trantab = maketrans(intab, outtab)
    # str = sys.argv[1] 
    str = plugin
    # Use Bing query to guess the project's bukkit uri
    c = pycurl.Curl()
    c.setopt(pycurl.USERAGENT, "Mozilla") 
    c.setopt(c.URL, "http://www.bing.com/search?q=site:dev.bukkit.org+"+str.translate(trantab)+"&&format=rss")
    c.setopt(c.WRITEFUNCTION, buf.write)
    c.perform()
    buffer =  buf.getvalue()
    parsed_buffer = re.sub('<[^<]> ', " ", buffer)
    parsed_buffer = re.sub('&'," ", parsed_buffer)
    parsed_buffer = re.sub("\d+", " ", parsed_buffer)
    search_results = parsed_buffer.split()
    buf.close()
    for item in search_results:
        if "url?q=http://dev.bukkit.org/bukkit-plugins/" and "files/" in item:
            item = item.replace('Bukkit</title><link>', '')
            item = item.replace('files/', '')
            projectHome.append(item)
            
    print("Found project @ "+projectHome[0])
    # Find the latest version
    buf = cStringIO.StringIO()
    c = pycurl.Curl()
    c.setopt(pycurl.USERAGENT, "Mozilla")
    c.setopt(c.URL, projectHome[0])
    c.setopt(c.WRITEFUNCTION, buf.write)
    c.perform()
    buffer = buf.getvalue()
    buffer = re.sub('<[^<]> ', " ", buffer)
    
    version_results = buffer.split()
    for item  in version_results:
        if "<dt>Downloads</dt>" in item:
            item = ""
        if "span" in item:
            item = ""
        if "Download" in item:
            item = item.replace('href="', '')
            item = item.replace('">Download</a>', '') 
            projectHome[1] = "http://dev.bukkit.org"+item
    print("Found Version @ "+ projectHome[1])
    # Find file
    try:
        buf = cStringIO.StringIO()
        c = pycurl.Curl()
        c.setopt(pycurl.USERAGENT, "Mozilla")
        c.setopt(c.URL, projectHome[1])
        c.setopt(c.WRITEFUNCTION, buf.write)
        c.perform()
        buffer = buf.getvalue()
        buffer = re.sub('<[^<]> ', " ", buffer)
        version_results = buffer.split()
        for item in version_results:
            if "Download" not in item:
                item = ""
            elif "<dt>" in item:
                item = ""
            else:
               
                item = item.replace('href="', '')
                item = item.replace('">Download</a>', '')
                item = item.replace('</span></li>', '')
                new_plugin = item
    except:
        print("Sorry,could not determine which file to download")
        exit(1)

    print("Found file    @ "+new_plugin)
    print(bcolors.WARNING + "")
    print("-[Project Facts]-")
    print("" + bcolors.ENDC)
    # Get project facts
    buf = cStringIO.StringIO()
    c = pycurl.Curl()
    c.setopt(pycurl.USERAGENT, "Mozilla")
    c.setopt(c.URL, projectHome[0])
    c.setopt(c.WRITEFUNCTION, buf.write)
    c.perform()
    buffer = buf.getvalue()
    facts_storage = []
    facts_results = buffer.split('>')
    for item in facts_results:
        if 'data-shortdate' in item:
            if 'data-prefix' not in item:
                formatter = item.split('"')
                facts_storage.append(formatter[3])
     
    print(bcolors.OKBLUE +'[Date Created] '+ bcolors.ENDC  +facts_storage[0]) 
    print(bcolors.OKBLUE +'[Last Updated] '+ bcolors.ENDC +facts_storage[1]) 
          
    buf.close()
    return(0)
    





if __name__ == '__main__':
    
   search(sys.argv[1])

    
