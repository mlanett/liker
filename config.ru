$: << File.expand_path("../lib", __FILE__)

require File.dirname(__FILE__) + '/lib/liker' # Bundler and App

# Note: if you see an error like "undefined method associate_callback_target",
# then uninstall and reinstall eventmachine to get the native extensions compiled correctly.
Liker::App.run!
