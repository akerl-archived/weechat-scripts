weechat-scripts
===============

[![MIT Licensed](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://tldrlegal.com/license/mit-license)

My Weechat scripts

## Scripts

### regex_highlight.rb

This is designed to let Weechat do smarter hilighting, using multiple regexes on a per-channel basis

#### Commands

* `/regex save` -- Saves current regex patterns to config file
* `/regex load` -- Loads regex patterns from file, overwriting any current patterns
* `/regex list` -- Lists currently loaded patterns
* `/regex add <channel> pattern` -- Adds a regex pattern for a channel
* `/regex del <channel> pattern` -- Removes a regex pattern for a channel

### squelch_away.rb

Unlike irssi, Weechat shows every away message it receives from other users. This gets really annoying if you're sending multiple messages to someone. This filteres out repetitive away messages

### pushover.rb

Notification script to send messages as [Pushover](https://pushover.net/) alerts. It is controlled via /pushover.

#### Commands

* `/pushover enable` -- enable message sending
* `/pushover disable` -- disable message sending
* `/pushover set <option> <value>` -- set pushover config option to value

#### Config options

* `userkey` -- User API key from Pushover
* `appkey` -- App API key from Pushover
* `devicename` -- Optional device name, used to send messages only to a specific device on the user's account
* `interval` -- How often to poll for messages to send (default 10 seconds)
* `pm_priority` -- Pushover priority to use for PMs (default 1). To learn more, see [Pushover's docs](https://pushover.net/api#priority)
* `hilight_priority` -- Pushover priority to use for hilights in channels (default 1)
* `onlywhendetached` -- For use with tmux_track.rb, only sends messages when Weechat's tmux window is detached (default 1)
* `enabled` -- Enables notification sending (default 1)

### tmux_track.rb

Helper script to set an internal variable, so other scripts can tell if tmux is attached.

#### Config options

* `interval` -- How often to poll for tmux status (default 5 seconds)

## License

These scripts are released under the MIT License. See the bundled LICENSE file for details.

