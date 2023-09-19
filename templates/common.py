# import sys
# import threading
# import _thread
import copy # control copy behavior of python
import datetime as dt
import http.client as http_client
import json
import logging
import math
import os
import requests
import signal
import subprocess # control external process within python
import sys
import time
import traceback
import urllib.parse
import urllib.request
import functools

from typing import Optional, Tuple, List, IO
import xml.etree.ElementTree as ET

signal_was_handled = False
cleanup_was_called = False
url = "localhost"
logindata = b"password123"
json_newconf = {"testjson":[{"t1":1,"t2":2},{"t1":11,"t2":12}]}
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

test1_json = json.loads('{"key1":true,"address":"value2"}')
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
    return -1

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
    if (devversion is not None):
        res_dict["devversion"] = devversion
    len_bigsplit0 = len(bigsplit[0])
    skip_v_index = 0
    if (bigsplit[0][0] == 'v'):
        skip_v_index = 1
    smallsplit = bigsplit[0][skip_v_index:len_bigsplit0].split('.')
    major = smallsplit[0]
    minor = smallsplit[1]
    bugfix = smallsplit[2]
    res_dict["major"] = int(major)
    res_dict["minor"] = int(minor)
    res_dict["bugfix"] = int(bugfix)
    return res_dict

# taken from https://stackoverflow.com/a/3229493/9306292
def prettyDict(d, indent=0):
   for key, value in d.items():
      print('  ' * indent + str(key))
      if isinstance(value, dict):
         prettyDict(value, indent+1)
      else:
         print('  ' * (indent+1) + str(value))

# SHENNANIGAN do not use xml.dom.minidom, it breaks space and newlines:
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
        xml_port = root.find("opt1").find("opt2") # type: ignore
    except (ET.ParseError, AttributeError):
        return -1
    if (__debug__):
        print("xml_port: ", xml_port)

    port = 0
    try:
        port = int(xml_port.text) # type: ignore
    except ValueError:
        print("ValueError")
        return -1
    if (__debug__):
        print("port: ", port)
    return port

def queryXmlField(xml_path: str):
    tree = ET.parse(xml_path)
    root = tree.getroot()
    version_query = root.findall("./field1/field2/version")
    assert(len(version_query) == 1)
    curr_version = int(version_query[0].text[4:]) # type: ignore
    _ = curr_version

# To add new nodes to ElementTree, use (beware that they dont have pretty print):
#newxml_s1 = ET.SubElement(newxml_s2, "slave")
#newxml_s1.text = str(someboolean).lower()   # there is also capitalize()

# requires Python 3.9
# no alternative to `ET.indent(tree, space="    ", level=0)`
# The other options to prettyprint are very broken or not part of Python libstd
# (xml.dom.ext).

def writeFile(tree: object, filepath: str, use_bom: bool):
    with open(filepath, 'wb') as file:
        if (True is use_bom):
            file.write('<?xml version="1.0" encoding="UTF-8"?>\n\n'.encode('utf-8'))
        tree.write(file, encoding='utf-8') # type: ignore

## Html GET or POST gives me always Access denied and jenkins has no proper
# description how to access their api or files with bare Python (bruh).
# Workaround: curl -s --user USER:TOKEN

# SHENNANIGAN
# .strip() is necessary after file read, because Python automatically adds "\n"

## Basic logging of html messages
# -- import requests
# -- import logging
# These two lines enable debugging at httplib level (requests->urllib3->http.client)
# You will see the REQUEST, including HEADERS and DATA, and RESPONSE with HEADERS but without DATA.
# The only thing missing will be the response.body which is not logged.
# -- import http.client as http_client
http_client.HTTPConnection.debuglevel = 1
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

## Better one: wireshark + tracking html messages

## HTML POST file upload with authorization and file renaming
path_file = "some/path"
upload_url = "localhost:123"
token = "passwordtoken"
files = [ ('file',('filename_renaming',open(path_file, 'rb'), 'application/octet-stream')) ]
response = requests.request("POST", upload_url,
             headers={'Authorization': ('Bearer ' + token)},
                      #'content-type': 'multipart/form-data'},
             data={},
             files=files)

## Get if port is used without psutils (doing reliably requires Kernel module)
netstat_out = subprocess.run(["netstat", "-tupln", "-W"], check=True, capture_output=True)
port_table = netstat_out.stdout.decode("utf-8").split("\n")
header_split = port_table[1].split(' ')
assert header_split[3] == "Local", "3rd split in header is not 'Local'"
assert header_split[4] == "Address", "4rd split in header is not 'Address'"
for line in range(2,len(port_table)):
  if port_table[line] == '':
    continue
  data_split = port_table[line].split()
  addr_split = data_split[3].split(':')
  assert len(addr_split) > 0, "splitting broken, port detection failed"
  #assert len(addr_split) > 1, print(addr_split)
  port = addr_split[len(addr_split)-1]
  print(port)


## Naive way to open next free file to write logs
def openLogHandle(log_dir: str, proc_name: str) -> IO[str]:
    if not os.path.exists(log_dir):
        os.mkdir(log_dir)
    i: int  = 0
    path: str = os.path.join(log_dir, proc_name+str(i)+".log")
    while os.path.exists(path):
        i += 1
        path = os.path.join(log_dir, proc_name+str(i)+".log")
    print("new file: ", path)
    return open(path, 'w+')

def unpackoperator():
  carCompany = ['Audi','BMW','Lamborghini']
  print(*carCompany)
  techStackOne = {"React": "Facebook", "Angular" : "Google", "dotNET" : "Microsoft"}
  techStackTwo = {"dotNET" : "Microsoft"}
  mergedStack = {**techStackOne, **techStackTwo}
  print(mergedStack)


## read config file json
def readWconf(filepath: str) -> dict:
  fh = os.open(filepath, os.O_RDONLY)
  fcontent = os.read(fh, 100000)
  os.close(fh)
  json1 = json.loads(fcontent)
  return json1

## write config file json
def writeWconf(conf: dict, filepath, **fmt) -> int:
  defaultFmt = { 'indent': 2, 'sort_keys': True, 'ensure_ascii': False }
  fmt = { **defaultFmt, **fmt }
  with open(filepath, 'w+', encoding='utf-8') as fph:
      json.dump(conf, fph, ensure_ascii=fmt['ensure_ascii'], indent=fmt['indent'], sort_keys=fmt['sort_keys'])
  return 0

def firstkey(current: dict) -> object:
    #list(current.keys())[0] # arbitrary position
    return next(iter(current)) #most efficient
def firstval(current: dict) -> object:
    # list(current.values())[0]
    return next(iter(current.values()))
def firstkeyval(current: dict) -> object:
    return next(iter(current.items())) # return next(iter(req.viewitems()))

# SHENNANIGAN Dictionary is missing this common method
def is_subdict(small: dict, big: dict) -> bool:
    """
    Test, if 'small' is subdict of 'big'
    Example: big = {'pl' : 'key1': {'key2': 'value2'}}
    Then small = {'pl' : 'key1': {'key2': 'value2'}, 'otherkey'..} matches,
    but small = {'pl' : 'key1': {'key2': 'value2', 'otherkey'..}}
    or small = {'pl' : 'key1': {'key2': {'value2', 'otherkey'..}}} not.
    """
    # since python3.9:
    # return big | small == big
    # also:
    # return {**big, **small} == big
    return dict(big, **small) == big

# SHENNANIGAN Dictionary is missing this common method
def has_fieldsvals(small: dict, big: dict) -> bool:
    """
    Test, if 'small' has all values of of 'big'
    Example: big = {'pl' : 'key1': {'key2': 'value2'}}
    Then small = {'pl' : 'key1': {'key2': 'value2'}, 'otherkey'..} matches,
    small = {'pl' : 'key1': {'key2': 'value2', 'otherkey'..}} matches,
    and small = {'pl' : 'key1': {'key2': {'value2', 'otherkey'..}}} matches.
    """
    for key, value in small.items():
        if key in big:
            if isinstance(small[key], dict):
                if not has_fieldsvals(small[key], big[key]):
                    return False
            elif value != big[key]:
                return False
        else:
            return False
    return True

def merge_1lvldicts(alpha: dict = {}, beta: dict = {}) -> dict:
    return dict(list(alpha.items()) + list(beta.items()))

# SHENNANIGAN Dictionary is missing this common method
def merge_dicts(alpha: dict = {}, beta: dict = {}) -> dict:
    """
    Recursive merge dicts. Not multi-threading safe.
    """
    return _merge_dicts_aux(alpha, beta, copy.copy(alpha))
def _merge_dicts_aux(alpha: dict = {}, beta: dict = {}, result: dict = {}, path: Optional[List[str]] = None) -> dict:
    if path is None:
        path = []
    for key in beta:
        if key not in alpha:
            result[key] = beta[key]
        else:
            if isinstance(alpha[key], dict) and isinstance(beta[key], dict):
                # key value is dict in A and B => merge the dicts
                _merge_dicts_aux(alpha[key], beta[key], result[key], path + [str(key)])
            elif alpha[key] == beta[key]:
                # key value is same in A and B => ignore
                pass
            else:
                # key value differs in A and B => raise error
                err: str = f"Conflict at {'.'.join(path + [str(key)])}"
                raise Exception(err)
    return result

### SHENNANIGAN tuples and dicts are annoying to differentiate
# dictionary
dict1 = {
    "m1": "cp",
    "m2": "cp"
}
# tuple
tup1 = {
    "m1": "cp",
    "m2": "cp"
},

# at least getting the intention correct, but python is still unhelpful with error message
dict2 = dict({
    "m1": "cp",
    "m2": "cp"
})
# tuple
tup2 = tuple({
    "m1": "cp",
    "m2": "cp"
}),

def getLastListOptindex(timeline_msg: list) -> Optional[int]:
  return len(timeline_msg) - 1 if timeline_msg else None

# SHENNANIGAN stack trace formatting is inefficient and one can not use g[f|F] to jump to location
# function to write status + trace to variable
def getStackTrace() -> str:
    return repr(traceback.format_stack())

def strlen(s: Optional[str]) -> Optional[int]:
  if s is None:
    return None
  return len(s)

# open mypy issue to annotate module info
def getModuleInfo(module: object):
  return getattr(module, 'runTest')

# use mypy and charliermarsh/ruff + editor integration
# for ruff: --line-length 120
# for mypy: just works

# https://stackoverflow.com/questions/65747247/how-to-print-file-path-and-line-number-while-program-execution
# https://note.nkmk.me/en/python-script-file-path/

# function to wait for event 12 ms
def waitForEvent() -> int:
  condition: bool = True # placeholder
  waiting_ms: int = 12_000 # 12s = 12_000ms
  start_ms: int = time.time_ns() // 1_000_000
  approx_end_ms: int = start_ms + waiting_ms
  now_ms: int = start_ms
  statvar: int = 0
  while now_ms  < approx_end_ms:
    if condition is True:
      statvar = 2
      break
    now_ms = time.time_ns() // 1_000_000
  if statvar == 2:
    return 0
  else:
    return 1

iso8601datetimefmt: str = '%Y-%m-%dT%H:%M:%S.%fZ'
def fmtDateNow() -> Tuple[str, str]:
  dt_from = dt.datetime.now(dt.timezone.utc)
  dt_to = dt_from + dt.timedelta(seconds=300)
  from_str = dt_from.strftime("%Y-%m-%dT%H:%M:%SZ")
  to_str = dt_to.strftime("%Y-%m-%dT%H:%M:%SZ")
  return (from_str, to_str)
# from typing import Tuple

datetimefmt_s: str = '%Y-%m-%dT%H:%M:%SZ'
datetimefmt_ms: str = '%Y-%m-%dT%H:%M:%S.%fZ'
utc = dt.timezone.utc

def parseTimestamp(timestamp: float) -> dt.datetime:
  return dt.datetime.fromtimestamp(timestamp, tz=utc)
def parseStr_s(datetime_str: str) -> dt.datetime:
  return dt.datetime.strptime(datetime_str, datetimefmt_s)
def parseStr_ms(datetime_str: str) -> dt.datetime:
  return dt.datetime.strptime(datetime_str, datetimefmt_ms)
def print_s(dt_in: dt.datetime) -> str:
    return dt_in.strftime(datetimefmt_s)
def print_ms(dt_in: dt.datetime) -> str:
    return dt_in.strftime(datetimefmt_ms)

# ignore ruff lints with at end eof line:
# noqa: F821
# ignore mypy lints with at end eof line:
# type: ignore

def expectEq(self, actual: object, expected: object, context: str = "") -> int:
    if actual != expected:
        if context != "":
            print(context)
        print("FAIL: actual:", actual, "expected:", expected)
        return 1
    return 0

def expectInRange(self, actual: object, low: object, high: object, context: str = "") -> int:
    assert isinstance(actual, float) or isinstance(actual, int)
    assert isinstance(low, float) or isinstance(low, int)
    assert isinstance(high, float) or isinstance(high, int)
    if not (low <= actual and actual <= high):
        if context != "":
            print(context)
        print("FAIL:", actual, "not in between [", low, ",", high, "]")
        return 1
    return 0

def expectEquation(self, is_true: bool, actual: object) -> int:
    if is_true is False:
        print("FAIL: equation false, actual:", actual)
        return 1
    return 0

# SHENNANIGAN: Mixed " and ' strings are invalid json
# Dict -> str is inconsistent to json -> str, so workaround with
# dict_asjson_lower = str(dict1).replace("'", '"')
def combineDictsFromStr():
  dict1 = {"t1":"val1","t2arr":[{"t2_int":0,"t2_str":"12.0"}], \
    "t3int":30}
  dict1_str_raw = str(dict1)
  dict1_str = dict1_str_raw.replace("'", '"')
  dict2_str = '{"anotherone":"yes", '
  dict2_str +=  '"t3int":30,"t4str":'
  dict2_str += dict1_str + '}'
  dict2 = json.loads(dict2_str)
  _ = dict2

def fstrings():
  variable = 10 # formatters: s(tring),d(integer),n(umber),e(xponent notation), f(ixedpoint notation), %(percentage)
  print(f"Numeric {variable =}")
  print(f"without formatting {variable}")
  print(f"with formatting {variable:d}")
  print(f"with formatting {variable:n}")
  print(f"with spacing {variable:10d}\n")
  variable = math.pi
  print(f"with formatting {variable:e}")
  print(f"with formatting {variable:f}")

  variable = 1200356.8796
  print(f"Numeric {variable =}")
  print(f"2 decimal places {variable:.2f}")
  print(f"and comma {variable:,.2f}")
  print(f"and forced plus sign{variable:+,.2f}")

  # for debugging
  print(f"{variable=}")

# SHENNANIGAN os.kill() does not call registered cleanup function `atexit.register(exit_cleanup)`
# by deamonzed threads. Must store pids of child processes and clean them explicitly or
# signal main thread via
def signalMainThread(self) -> None:
    pass
    # before Python 3.10: _thread.interrupt_main()
    # since Python 3.10: _thread.interrupt_main(signum=signal.SIGKILL)

# related: installing signal handler for SIGINT
def cleanup():
  global cleanup_was_called
  cleanup_was_called = True
  pass
def handle_sigint(signalnum, frame):
  global signal_was_handled
  if signal_was_handled: sys.exit(1) # exit early on signal within signal
  signal_was_handled = True
  if cleanup_was_called is False:
    cleanup()
    sys.exit(1) # signal intention to exit to interpreter for exit_cleanup to be run
signal.signal(signal.SIGINT, handle_sigint)

# PERF
# O(1) lookup structure in Python via seq_no being index into storage_msg.
# See also https://wiki.python.org/moin/TimeComplexity and DOD (most simple
# version is append-only list). Incorrect type notations for understandability.
# msg = { "somejson": "something" }        # msg format
# lookup = hashmap(seq_no, seq_ind_list)   # hashmap of sequence number -> index into storage_msg
# timeline = list((seq_no, msg))           # (seq_no, msg) is a tuple
# storage_msg: list = list()               # list of messages

# SHENNANIGAN
# readline() with timeout io file api is broken, see https://github.com/python/cpython/issues/51571
# Workaround
# * 1. Read from Kernel structure and append chunk-wise to buffer from socket until stop event.
# * 2. After each read, try line = readline() from the buffer and remove the line on success.
# * 3. On failure of reading line, continue with 1.
# * 4. Teardown should also use readSocket to read all Kernel memory, if a stop was signaled.
# Note: utf-8 decoding must also be done and select or an equivalent should be used to check,
# if data for reading exists.

# store function (partial evaluated) and expand it upon call ie list of arguments, ie
# to store functions and arguments to execute at later point
print_with_hello = functools.partial(print, "Hello")
print_with_hello("World", 123, "blabla")
print_with_hello()

# Store function and call at later point:
def fn1(arg: int) -> int:
  return 1
def fn2(arg: int) -> int:
  return 2
flist = [ fn1, fn2 ]
flist[0](1)

def run_cleanupfn(cleanup_args: list) -> None:
  for i in range(0, len(cleanup_args)):
    fn = cleanup_args[0]
    args = cleanup_args[1:]
    fn[i][0](*args)

def isLocalHost(arg: str) -> bool:
  """
  Quick and dirty check for localhost. Note that the network prefix is missing
  """
  if arg == "localhost" or arg == "127.0.0.1" or arg == "::1" or arg == "0:0:0:0:0:0:0:1" \
      or arg == "0000:0000:0000:0000:0000:0000:0000:0001": return True
  else: return False

# SHENNANIGAN
# Generic module annotation is not allowed in mypy without explicit docs for
# possible error messages + solution patterns. The following does not work:
#   from typing import ModuleType
#   def check_fn(module: ModuleType) -> int:
#     if str(type(module)) != "<class 'module'>": return 1
#     return 0
# 'module: object' is the closest we can get as simple annotation

def check_fn(fn: list) -> int:
  if not callable(fn[0]): return 1
  return 0
