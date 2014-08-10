#!/usr/bin/env python3
# Count open tabs from a firefox profile
# Working directory is the root of a Firefox profile.
import json
j = json.loads(open("sessionstore.js", 'rb').read().decode('utf-8'))
def info_for_tab(tab):
    try:
        return (tab['entries'][0]['url'], tab['entries'][0]['title'])
    except IndexError:
        return None
    except KeyError:
        return None
def tabs_from_windows(window):
    return list(map(info_for_tab, window['tabs']))
all_tabs = list(map(tabs_from_windows, j['windows']))
print('{wins} win, {tabs} total tabs'.format(wins=len(all_tabs), tabs=sum(map(len, all_tabs))))
