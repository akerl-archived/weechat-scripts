weechat-scripts
===============

[![MIT Licensed](http://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://tldrlegal.com/license/mit-license)

My Weechat scripts

## Scripts

### regex_highlight

This is designed to let Weechat do smarter hilighting, using multiple regexes on a per-channel basis

It is controlled via `/regex`, and stores your hilight configuration in its own file.

### squelch_away

Unlike irssi, Weechat shows every away message it receives from other users. This gets really annoying if you're sending multiple messages to someone. This is going to filter out repeated messages using some kind of timer. Right now it doesn't work.

### pushover

Notification script to send messages as [Pushover](https://pushover.net/) alerts. It is controlled via /pushover.

### tmux_track

Helper script to set an internal variable, so other scripts can tell if tmux is attached.

## License

These scripts are released under the MIT License. See the bundled LICENSE file for details.

