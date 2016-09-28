# squelch_away.rb
# rubocop:disable Metrics/LineLength, Style/GlobalVars

# Copyright (c) 2014 Les Aker <me@lesaker.org>

# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Changelog:
#   0.0.1 - Initial functionality
#   0.1.0 - Fixed functionality, cleaned style

MATCHER = /^\x1905--\t\x1928\[\x1914(?<name>\S+)\x1928\] \x1901is away: (?<msg>.*)$/

$squelch_away_seen = {}

def weechat_init
  Weechat.register(
    'squelch_away',
    'Les Aker <me@lesaker.org>',
    '0.1.0',
    'MIT',
    'Squelch repetitive away messages',
    '',
    ''
  )
  load_script
end

def load_script
  Weechat.hook_modifier 'weechat_print', 'squelch_check', ''
  Weechat::WEECHAT_RC_OK
end

def squelch_check(_, _, mod_data, line)
  return line if mod_data =~ /_/
  result = line.match MATCHER
  return line unless result
  already_seen?(result['name'], result['msg']) ? '' : line
end

def already_seen?(name, msg)
  return true if $squelch_away_seen[name] == msg
  $squelch_away_seen[name] = msg
  false
end
