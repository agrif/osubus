#!/usr/bin/python

import os, os.path
from pysqlite2 import dbapi2 as sqlite3

files = os.listdir('incoming')
for fname in files:
	fname = os.path.join('incoming', fname)
	conn = sqlite3.connect(fname)
	c = conn.cursor()
	c.execute("SELECT name, value FROM meta")
	date = ""
	version = ""
	for i in c.fetchall():
		if i[0] == 'version':
			version = i[1]
		if i[0] == 'date':
			date = i[1]

	c.close()
	conn.close()

	os.system("mv %s cabs.db.%s" % (fname, version))

files = os.listdir(".")
f = open("databases", "w")
for fname in files:
	if not fname.startswith("cabs.db"):
		continue
	conn = sqlite3.connect(fname)
	c = conn.cursor()
	c.execute("SELECT name, value FROM meta")
	date = ""
	version = ""
	for i in c.fetchall():
		if i[0] == 'version':
			version = i[1]
		if i[0] == 'date':
			date = i[1]

	c.close()
	conn.close()

	f.write("%s %s http://osubus.gamma-level.com/updates/%s\n" % (version, date, fname))
	
f.close()
