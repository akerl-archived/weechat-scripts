# pushover.rb
# rubocop:disable Style/LineLength, Style/GlobalVars
#
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

require 'net/https'

DEFAULTS = {
  userkey: nil,
  appkey: nil,
  devicename: nil,
  interval: '20', # seconds
  priority: '1',
  onlywhenaway: 0,
  enabled: 1,
}
URL = URI.parse('https://api.pushover.net/1/messages.json')

class PushoverConfig
  def initialize
    @queue = []
    @health_check = 200
    @rate_calc = 0
    load_options
    load_hooks
  end

  def command_hook(_, _, args)
    case args
    when 'enable' then enable!
    when 'disable' then disable!
    when /^set (?<option>\w+) (?<value>[\w]+)/
      set Regexp.last_match['option'], Regexp.last_match['value']
    else
      Weechat.print('', "Syntax: #{completion_text}")
    end
    Weechat::WEECHAT_RC_OK
  end

  def message_hook(_, buffer, _, _, visible, hilight, prefix, message)
    unless Weechat.config_string_to_boolean(@options[:enabled]).to_i.zero?
      return Weechat::WEECHAT_RC_OK
    end
    unless Weechat.config_string_to_boolean(@options[:onlywhenaway]).to_i.zero?
      away_msg = Weechat.buffer_get_string buffer, 'localvar_away'
      return Weechat::WEECHAT_RC_OK if away_msg && away_msg.length > 0
    end

    buffer_type = Weechat.buffer_get_string buffer, 'localvar_type'
    privmsg = (buffer_type == 'private')

    buffer_name = Weechat.buffer_get_string buffer, 'full_name'
    @queue << [buffer_name, privmsg, "<#{prefix}> #{message}"]
  end

  def timer_hook(*_)
    return Weechat::WEECHAT_RC_OK if @queue.empty?
    @health_check = -5 unless [0, 200].include? @health_check 
    if @health_check < 0
      @health_check += 1
      return Weechat::WEECHAT_RC_OK
    end
    coalesce_messages if @rate_calc < 0
    send_messages
  end

  private

  def coalesce_messages
    # Dummy method for now
  end

  def send_messages
    remaining = @queue.drop_while do |message|
      send_message *message, priority
    rescue
      false
    end
  end

  def send_message
  end

  def set(option, value)
    unless @options.keys.include? option.to_sym
      Weechat.print '', "Available options: #{@options.keys.join ', '}"
    else
      @options[option.to_sym] = value
      Weechat.print '', "Pushover: set #{option} to #{value}"
      reload_hooks if [:interval].include? option.to_sym
    end
  end

  def load_options
    DEFAULTS.each do |key, default|
      value = Weechat.config_get_plugin key
      value ||= default
      instance_variable_set "@#{key}".to_sym, value
    end
  end

  def load_hooks
    @hooks = {
      command: Weechat.hook_command(
        'pushover',
        'Control Pushover options',
        'set OPTION VALUE', '',
        "#{completion_text}",
        'command_hook', ''
      ),
      message: Weechat.hook_print '', 'irc_privmsg', '', 1, 'message_hook', '',
      timer: Weechat.hook_timer @options[:interval].to_i * 1000, 0, 0, 'timer_hook', ''
    }
  end

  def reload_hooks
    @hooks.each_value { |x| Weechat.unload x } if @hooks
    load_hooks
  end

  def completion_text
    "set #{@options.join ' || set '}"
  end

  def 
end

def weechat_init
  Weechat.register(
    'pushover',
    'Les Aker <me@lesaker.org>',
    '0.0.1',
    'MIT',
    'Send hilight notifications via Pushover',
    '',
    ''
  )
  $config = PushoverConfig.new
  Weechat::WEECHAT_RC_OK
end

require 'forwardable'
extend Forwardable
def_delegators :$config, :message_hook, :command_hook, :timer_hook