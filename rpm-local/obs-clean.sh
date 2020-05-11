#!/bin/sh -x
# After osc checkout, clean out all tarballs and .osc dirs
cd spec
rm -f $(find -name '*.tar.*') $(find -name '*.zip')
rm -rf $(find -name '.osc')
