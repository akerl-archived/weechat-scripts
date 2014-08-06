# tmux_track.rb
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

TMUX_DEFAULTS = {
  interval: 5
}

##
# Handler for tracking tmux
class TmuxTracker
  def initialize
    load_options
    load_hooks
    timer_hook
  end

  def timer_hook(*_)
    if ENV['TMUX']
      socket = ENV['TMUX'].split(',').first
      File.executable?(socket) ? attached : detached
    else
      attached
    end
    Weechat::WEECHAT_RC_OK
  end

  private

  def update(state)
    Weechat.config_set_plugin 'attached', state
  end

  def attached
    update '1'
  end

  def detached
    update '0'
  end

  def load_options
    @options = TMUX_DEFAULTS.dup
    @options.each_key do |key|
      value = Weechat.config_get_plugin key.to_s
      @options[key] = value if value
      Weechat.config_set_plugin key.to_s, @options[key]
    end
  end

  def load_hooks
    @hook = Weechat.hook_timer(
      @options[:interval].to_i * 1000, 0, 0, 'timer_hook', ''
    )
  end
end

def weechat_init
  Weechat.register(
    'tmux_tracker', 'Les Aker <me@lesaker.org>',
    '0.0.1', 'MIT',
    'Update weechat variable based on tmux state',
    '', ''
  )
  $Tmux = TmuxTracker.new
  Weechat::WEECHAT_RC_OK
end

require 'forwardable'
extend Forwardable
def_delegators :$Pushover, :timer_hook
