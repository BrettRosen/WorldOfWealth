#!/bin/sh

#  ci_post_clone.sh
#  World of Wealth
#
#  Created by Brett Rosen on 11/28/23.
#  

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
