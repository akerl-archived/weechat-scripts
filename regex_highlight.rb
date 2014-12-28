# regex_highlight.rb
# rubocop:disable Metrics/LineLength, Style/GlobalVars, Style/Documentation

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
#   0.0.2 - Cleaned up code
#   0.1.0 - Classified, cleaned up bugs

require 'yaml'

class RegexConfig
  attr_reader :path, :rules

  HELPTEXT = '[save] | [reload] | [list] | [[add|del] channel pattern]'

  def initialize
    @path = Weechat.info_get('weechat_dir', '') + '/regex_highlight.conf'
    @rules = Hash.new { |h, k| h[k] = [] }
    reload if File.exist?(@path)
    load_hooks
  end

  def command_hook(_, _, args)
    case args
    when /^(save|reload|list)$/ then send(args.to_sym)
    when /^add #?(?<channel>[\w]+) (?<regex>.*)/
      add Regexp.last_match['channel'], Regexp.last_match['regex']
    when /^del #?(?<channel>[\w]+) (?<regex>.*)/
      remove Regexp.last_match['channel'], Regexp.last_match['regex']
    else
      Weechat.print('', "Syntax: #{HELPTEXT}")
    end
    Weechat::WEECHAT_RC_OK
  end

  def highlight_hook(_, _, modifier_data, string)
    return string unless modifier_data.match(/irc;\w+\.[#\w]+;.+/)
    server, channel, tags = parse_modifiers(modifier_data)
    return string unless match channel, string

    new_tags = tags.join(',').sub 'notify_message', 'notify_highlight'
    buffer = Weechat.info_get('irc_buffer', "#{server},#{channel}")
    Weechat.print_date_tags(buffer, 0, new_tags, string)
    ''
  end

  private

  def load_hooks
    Weechat.hook_command(
      'regex',
      'Control regex highlights',
      HELPTEXT,
      'save/load dump to and load from the config file; list shows current patterns; add/del add and remove patterns',
      'save || reload || list || add %(irc_channels) %- %S || del %(irc_channels) %- %S',
      'command_hook',
      ''
    )
    Weechat.hook_modifier('weechat_print', 'highlight_hook', '')
  end

  def parse_modifiers(modifiers)
    data = modifiers.split ';'
    tags = data.last.split ','
    server, channel = data[1].split '.', 2
    [server, channel, tags]
  end

  def save
    File.open(@path, 'w') { |fh| fh << @rules.to_yaml }
    Weechat.print('', "Saved regex_highlight config to #{@path}")
  end

  def reload
    @rules.clear
    @rules.merge! File.open(@path) { |file| YAML.load file }
    Weechat.print('', "Loaded regex_highlight config from #{@path}")
  end

  def list
    Weechat.print('', 'No rules loaded') if @rules.empty?
    @rules.each do |channel, ruleset|
      Weechat.print('', "Patterns for #{channel}")
      ruleset.each { |rule| Weechat.print('', rule) }
    end
  end

  def add(channel, regex)
    if @rules[channel].include? regex
      Weechat.print('', "Regex already configured for ##{channel}: #{regex}")
    else
      @rules[channel] << regex
      Weechat.print('', "Added regex for ##{channel}: #{regex}")
    end
  end

  def remove(channel, regex)
    if @rules[channel].include? regex
      @rules[channel].delete(regex)
      Weechat.print('', "Removed regex for channel ##{channel}: #{regex}")
    else
      Weechat.print('', "This regex isn't in the list")
    end
  end

  def match(channel, string)
    @rules.each do |rule_channel, ruleset|
      next unless ['ALL', channel].include? rule_channel
      next unless ruleset.find { |rule| string.match rule }
      return true
    end
    false
  end
end

def weechat_init
  Weechat.register(
    'regex_highlight',
    'Les Aker <me@lesaker.org>',
    '0.1.0',
    'MIT',
    'Provides more flexible highlighting rules',
    '', ''
  )
  $Regex_Highlight = RegexConfig.new
  Weechat::WEECHAT_RC_OK
end

require 'forwardable'
extend Forwardable
def_delegators :$Regex_Highlight, :highlight_hook, :command_hook
