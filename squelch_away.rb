# squelch_away.rb

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

$history = {}
Away_Codes = [301, 305, 306, 'away']

def weechat_init
    Weechat.register(
        'squelch_away',
        'Les Aker <me@lesaker.org>',
        '0.0.1',
        'MIT',
        'Squelch repetitive away messages',
        'unload_script',
        '',
    )
    load_script
    Weechat::WEECHAT_RC_OK
end

def load_script
    open('/home/akerl/b.txt', 'a') { |file| file << "shit\n" }
    Away_Codes.each { |code| Weechat.hook_modifier("irc_in_#{code}", 'squelch_check', '') }
end

def squelch_check(data, modifier, modifier_data, string)
    open('/home/akerl/b.txt', 'a') do |file|
        file << "DATA: #{data}\n"
        file << "MODIFIER: #{modifier}\n"
        file << "MOD_DATA: #{modifier_data}\n"
        file << "STRING: #{string}\n"
    end
    string
end
