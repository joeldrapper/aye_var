# AyeVar 🏴‍☠️

Arrr, this gem be mighty fresh an’ experimental, me hearties! Th’ API be liable to shift with th’ tides.

## What does it do?

It prevents ye from usin’ undefined instance variables by transformin’ yer code as it be loaded, savvy?

## Setup

Add this treasure to yer gemfile, arr!

```ruby
gem "aye_var", require: false
```

Then require an’ initialize it in yer vessel as early as possible, ye hear? If ye be usin’ Bootsnap, it should be right after Bootsnap, or I’ll make ye walk th’ plank!

```ruby
require "aye_var"

AyeVar.init(include: ["#{Dir.pwd}/**/*"])
```

Ye can pass in an array o’ globs to `include:` an’ `exclude:`, ye bilge rat!
