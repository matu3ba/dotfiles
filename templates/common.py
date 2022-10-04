import os
import sys
import json
import urllib.parse
import urllib.request

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
