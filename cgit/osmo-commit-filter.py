#!/usr/bin/env python3
# (C) Harald Welte <laforge@gnumonks.org>

# This is a python script intended to be used as a commit-filter of
# cgit.  It recognizes certain patterns (such as a gerrit Change-Id, or
# Related/Closed redmine issues.

GERRIT_URL = 'https://gerrit.osmocom.org/q/%s'
REDMINE_OS_URL = 'https://osmocom.org/issues/%s'
REDMINE_SYS_URL = 'https://projects.sysmocom.de/redmine/issues/%s'
RT_URL = 'https://rt.sysmocom.de/TicketDisplay.html?id=%s'

import re
import sys
import html

def hyperlink(txt, url):
    return '<a href="%s">%s</a>' % (url, html.escape(txt))

def chgid_repl(matchobj):
    chg_id = matchobj.group(1)
    url = GERRIT_URL % html.escape(chg_id)
    return hyperlink(chg_id, url)

def relates_repl(matchobj):
    def process_item(x):
        def repl_os(m):
            url = REDMINE_OS_URL % html.escape(m.group(1))
            return hyperlink(m.group(0), url)
        def repl_sys(m):
            url = REDMINE_SYS_URL % html.escape(m.group(1))
            return hyperlink(m.group(0), url)
        def repl_rt(m):
            url = RT_URL % html.escape(m.group(1))
            return hyperlink(m.group(0), url)
        x = re.sub(r"OS#(\d+)", repl_os, x)
        x = re.sub(r"SYS#(\d+)", repl_sys, x)
        x = re.sub(r"RT#(\d+)", repl_rt, x)
        return x
    line = matchobj.group(3)
    related_ids = [x.strip() for x in line.split(',')]
    extd_ids = [process_item(x) for x in related_ids]
    return '%s: %s' % (matchobj.group(1), ', '.join(extd_ids))

for line in sys.stdin:
    line = re.sub(r"(I\w{40})", chgid_repl, line)
    line = re.sub(r"^((Relate|Close|Fixe)[ds]): (.*)$", relates_repl, line)
    sys.stdout.write(line)

