# regex_highlight.rb

# Copyright (c) 2013 Les Aker <me@lesaker.org>

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
#   0.0.2 - Cleaned up code

def weechat_init
    Weechat.register(
        'regex_highlight',
        'Les Aker <me@lesaker.org>',
        '0.0.2',
        'MIT',
        'Provides more flexible highlighting rules',
        'unload_script',
        '',
    )
    $Config_Path = Weechat.info_get('weechat_dir', '') + '/regex_highlight.conf'
    load_script
    Weechat::WEECHAT_RC_OK
end

def load_script
    File.exists?($Config_Path) ? load_conf : save_conf

    Weechat.hook_command(
        'regex',
        'Control regex highlights',
        '[save] | [load] | [list] | [[add|del] pattern]',
        'save/load dump to and load from the config file; list shows current patterns; add/del add and remove patterns',
        'save || load || list || add || del',
        'command_handler',
        '',
    )
    Weechat.hook_modifier('weechat_print', 'highlight_check', '')
end

def dump_rules(file, key, rules)
    file << "\\\\#{key}\n"
    rules.each { |rule| file << "#{rule}\n" }
    file << "\n"
end

def save_conf
    $rules ||= Hash.new {|h, k| h[k] = [] }
    open($Config_Path, 'w') do |file|
        rules = $rules.dup
        dump_rules(file, 'ALL', rules.delete('ALL'))
        rules.each { |channel, rules| dump_rules(file, channel, rules) }
    end
    Weechat.print('', "Saved regex_highlight config to #$Config_Path")
end

def load_conf
    $rules = Hash.new {|h, k| h[k] = [] }
    open($Config_Path) do |file|
        key = nil
        file.each_line do |line|
            next if line == "\n"
            line = line.rstrip
            line[0,2] == '\\\\' ? key = line[2..-1] : $rules[key] << line
        end
    end
    Weechat.print('', "Loaded regex_highlight config from #$Config_Path")
end

def command_handler(data, buffer, args)
    case args
        when 'save'
            save_conf
        when 'load'
            load_conf
        when 'list'
            $rules.each do |channel, ruleset|
                Weechat.print('', "Patterns for #{channel}")
                ruleset.each { |rule| Weechat.print('', rule) }
            end
        when /^add #?([\w]+) (.*)/
            if $rules[$1].include? $2
                Weechat.print('', 'That regex is already added')
            else
                Weechat.print('', "Added regex /#$2/ for channel #$1")
                $rules[$1] << $2
            end
        when /^del #?([\w]+) (.*)/
            if $rules[$1].include? $2
                Weechat.print('', "Removed regex /#$2/ for channel #$1")
                $rules[$1].delete($2)
            else
                Weechat.print('', "This regex isn't in the list")
            end
        else
            Weechat.print('', 'Syntax: [save] | [load] | [list] | [[add|del] channel pattern]')
    end
    Weechat::WEECHAT_RC_OK
end

def highlight_check(data, modifier, modifier_data, string)
    return string unless modifier_data.match(/irc;\w+\.[#\w]+;.+/)

    data = modifier_data.split(';')
    tags = data[2].split(',')
    server, _, channel = data[1].partition('.')

    $rules.each do |rule_channel, ruleset|
        next unless rule_channel == 'ALL' or rule_channel == channel
        ruleset.each do |rule|
            next unless string.match(rule)

            tags[1] = 'notify_highlight' if tags[1] == 'notify_message'
            new_tags = tags.join(',')
            buffer = Weechat.info_get('irc_buffer', "#{server},#{channel}")

            Weechat.print_date_tags(buffer, 0, new_tags, string)
            return ''
        end
    end

    string
end

