# Be sure to restart your server when you modify this file.

Paperclip.options[:command_path] = "/usr/bin/"

# Fixes Issues with Spoof File Checks #1429.
# See https://github.com/thoughtbot/paperclip/issues/1429#issuecomment-34390771
require 'paperclip/media_type_spoof_detector'
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end
