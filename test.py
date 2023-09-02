#!/usr/bin/python3 python

import sys
from ctypes import *

form = sys.stdin.read().rstrip()
input_string = c_char_p(bytes(form, "utf8"))

so = CDLL("libsci.so")
isolate = c_void_p()
isolatethread = c_void_p()
so.graal_create_isolate(None, byref(isolate), byref(isolatethread))

eval_string = so.eval_string
eval_string.restype = c_char_p

result = eval_string(isolatethread, input_string).decode()

print("\nInput: '%s'" % form)
print("Result: '%s'" % result)
