#!/usr/bin/python

import sys, re

rus_counters = "./rus_counters.txt"
eng_counters = "./eng_counters.txt"
default_first = "(PDH-CSV 4.0) (E. Africa Standard Time)(-180)"

rus = {}
eng = {}

with open(rus_counters) as rusfile, open(eng_counters) as engfile:
	rus_content = rusfile.readlines()
	i = 0
	while i < len(rus_content) - 1:
		rus[rus_content[i+1].strip()] = rus_content[i].strip()
		i += 2

	eng_content = engfile.readlines()
	i = 0
	while i < len(eng_content) - 1:
		eng[eng_content[i].strip()] = eng_content[i+1].strip()
		i += 2

input_file = sys.argv[1]
with open(input_file) as inp:
	lines = inp.readlines()
	
header = lines[0]

print("Before: ")
print(header)

# "(PDH-CSV 4.0) (" and others corrupted first field processing

firstField = re.match('\"(.+\s\()\",.+', header)
if firstField:
	header = header.replace(firstField.group(1), default_first)
else:
	if all(ord(char) < 128 for char in header):
		print("Here is nothing to change...")
		sys.exit(0)

		
result = re.findall(r'\\\\[^\\]+\\([^\\\(]+)(\([^\\]+\))?\\([^\"]+)\"', header)
for item in result:
	if (item[2] in rus):
		header = re.sub(r"\\" + re.escape(item[2]) + "([\\\)\(\s\"])", r"\\" + eng[rus[item[2]]] + "\\1", header)
	else:
		print("warning: '%s' not found in dictionary!" % (item[2]))

	if (item[0] in rus):
		header = re.sub(r"\\" + re.escape(item[0]) + "([\\\)\(\s\"])", r"\\" + eng[rus[item[0]]] + "\\1", header)
	else:
		print("warning: '%s' not found in dictionary!" % (item[0]))

print("After: ")
print(header)

lines[0] = header
		
with open(input_file, mode = "w") as out:
	out.writelines(lines)
