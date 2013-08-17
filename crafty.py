#!/usr/local/bin/python
import sys
import pycurl
from string import maketrans 
import cStringIO
import re
import urllib
# Set Your MC directory
minecraftHome = "/home/minecraft/"
projectHome = []
plugin_versions = []
new_plugin = ""

def usage():
    print("Install a plugin: Crafty 'plugin-name'")
    print("Update plugins and CraftBukkit just run Crafty with no options")
    print("Examples:")
    print("---------")
    print("Crafty                        Downloads and installs all updates")
    print('Crafty "worldedit"            Downloads and installs the WorldEdit plugin')
    print('Crafty "tim the enchanter"    Downloads and installs Tim the Enchanter plugin') 



def getPlugs():
    print ("Fetching Plugin")
     

def updatePlugs():
    print("Checking Plugins:")
    return(0)


def updateBukkit():
    print("Checking Craftbukkit:")
    return(0)





def search():
    # This is by no means perfect but it works surprisingly well!

    print("-------------------------")
    print("Looking up on Bukkit.org:")
    print("-------------------------")
    # user input formatting
    buf = cStringIO.StringIO()
    intab = " "
    outtab = "+"
    trantab = maketrans(intab, outtab)
    str = sys.argv[1] 
    # Use google query to guess the project's bukkit uri
    c = pycurl.Curl()
    c.setopt(pycurl.USERAGENT, "Mozilla") 
    c.setopt(c.URL, "http://www.google.com/search?q=site:dev.bukkit.org+"+str.translate(trantab))
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
            item = item.replace('href="/url?q=', '')
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
        if "Download" in item:
            item = item.replace('href="', '')
            item = item.replace('">Download</a>', '')
            projectHome[1] = "http://dev.bukkit.org"+item
            print("Found Version @ "+ projectHome[1])
    # Find file
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
            projectHome[2] = item
    print("Found file    @ "+projectHome[2])
    print("=========")
    print("-[Facts]-")
    print("=========")
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
     
    print('[Date Created] '+facts_storage[0]) 
    print('[Last Updated] '+facts_storage[1]) 
          
    buf.close()
    getPlugs()
    





if __name__ == '__main__':
    
   search()

    
