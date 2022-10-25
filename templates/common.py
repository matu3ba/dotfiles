import os
import sys
import json
import urllib.parse
import urllib.request

import xml.etree.ElementTree as ET

# POST requires to use request.Request with data field
req = urllib.request.Request(url, data=logindata,
                             headers={'content-type': 'application/json'})
# response token
# token = "human readable ascii|random"
with urllib.request.urlopen(req) as response:
   tokenInfo = response.read()
   print(tokenInfo)
   tokenInfo_str = tokenInfo.decode()
   tokenInfo_json = json.loads(tokenInfo_str)
   print(type(tokenInfo_json))

# GET is the same without data field. Special things must be requested
# with url?urlenc_data, urlenc_data=urllib.parse.urlencode(data)

# JSON operations can also be done with jq
# jq '. | length'

# Python is unreliable on getting the local ip address
# One usually has multiple ip addresses with at least localhost=127.0.0.1,
# so `ip` should be parsed or better a Kernel or libc call be made.
get_local_ipaddress = subprocess.run(["hostname", "-I"], check=True, capture_output=True)
stdout_local_ipaddress = get_local_ipaddress.stdout
local_ipaddress = stdout_local_ipaddress.decode("utf-8").strip()

test1_json = json.loads('{"key1":true,"address:"value2"}')
print(type(test1_json['address']))
test1_json['address'] = get_local_ipaddress # localhost
test1_json_utf8b = json.dumps(test1_json, separators=(',', ':'), indent=None).encode("utf-8")

# pretty print json
print(json.dumps(json_newconf, separators=(',', ':'), indent=4, sort_keys=True))

# returns first difference index of sorted flat json
def compareJson(jsonb1: bytes, jsonb2: bytes) -> int:
    json1 = json.loads(jsonb1)
    json2 = json.loads(jsonb2)
    sorted_json_str1 = json.dumps(json1, separators=(',', ':'), indent=None, sort_keys=True)
    sorted_json_str2 = json.dumps(json2, separators=(',', ':'), indent=None, sort_keys=True)
    sort_json1 = json.loads(sorted_json_str1)
    sort_json2 = json.loads(sorted_json_str2)
    for i in range(0,len(sort_json1)):
        if (sort_json1[i] != sort_json2[i]):
            return i
    if len(sort_json2) > len(sort_json1):
        return len(sort_json1)

# returns dictionary of semantic version
# asserts that at most one separating `-` exists.
def parseSemanticVersion(semver_str: str) -> dict:
    if __debug__:
        print("parseSemanticVersion")
    res_dict = {}
    bigsplit = semver_str.split('-')
    assert(len(bigsplit) < 3)
    devversion = None
    if (len(bigsplit) > 1):
        devversion = int(bigsplit[1])
    if (devversion != None):
        res_dict["devversion"] = devversion
    len_bigsplit0 = len(bigsplit[0])
    skip_v_index = 0
    if (bigsplit[0][0] == 'v'):
        skip_v_index = 1
    smallsplit = bigsplit[0][skip_v_index:len_bigsplit0].split('.')
    major = smallsplit[0]
    minor = smallsplit[1]
    bugfix = smallsplit[2]
    res_dict["major"] = major
    res_dict["minor"] = minor
    res_dict["bugfix"] = bugfix
    return res_dict

# taken from https://stackoverflow.com/a/3229493/9306292
def prettyDict(d, indent=0):
   for key, value in d.items():
      print('  ' * indent + str(key))
      if isinstance(value, dict):
         prettyDict(value, indent+1)
      else:
         print('  ' * (indent+1) + str(value))

# do not use xml.dom.minidom, it breaks space and newlines:
# https://bugs.python.org/issue5752
# use instead ElementTree

## parsing standard conform xml (see xmlns, xmlns:xsi, xsi:schemaLocation, and targetNamespace)
##   W3C XML Schema Definition Language (XSD) 1.1 Part 1: Structures
##   most relevant fields: tag, attrib, text, tail
def getPort() -> int:
    tree = ET.parse('test.xml')
    root = tree.getroot()
    xml_port = None
    try:
        # To ensure occurence of exactly 1 element, use
        #   children = findAll(parent)
        #   assert(len(children)) == 1
        #   idea: figure out how to do function chaining in Python
        xml_port = root.find("opt1").find("opt2")
    except (ET.ParseError, AttributeError):
        return -1
    if (__debug__):
        print("xml_port: ", xml_port)

    port = 0
    try:
        port = int(xml_port.text)
    except ValueError:
        print("ValueError")
        return -1
    if (__debug__):
        print("port: ", port)
    return port

# To add new nodes to ElementTree, use (beware that they dont have pretty print):
#newxml_s1 = ET.SubElement(newxml_s2, "slave")
#newxml_s1.text = str(someboolean).lower()   # there is also capitalize()

# requires Python 3.9
# no alternative to `ET.indent(tree, space="    ", level=0)`
# The other options to prettyprint are very broken or not part of Python libstd
# (xml.dom.ext).

## Html GET or POST gives me always Access denied and jenkins has no proper
# description how to access their api or files with bare Python (bruh).
# Workaround: curl -s --user USER:TOKEN

# .strip() is necessary after file read, because Python automatically adds "\n"

## Basic logging of html messages
import requests
import logging
# These two lines enable debugging at httplib level (requests->urllib3->http.client)
# You will see the REQUEST, including HEADERS and DATA, and RESPONSE with HEADERS but without DATA.
# The only thing missing will be the response.body which is not logged.
import http.client as http_client
http_client.HTTPConnection.debuglevel = 1
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

## Better one: wireshark + tracking html messages

## HTML POST file upload with authorization and file renaming
files = [ ('file',('filename_renaming',open(path_file, 'rb'), 'application/octet-stream')) ]
response = requests.request("POST", upload_url,
             headers={'Authorization': ('Bearer ' + token)},
                      #'content-type': 'multipart/form-data'},
             data={},
             files=files)