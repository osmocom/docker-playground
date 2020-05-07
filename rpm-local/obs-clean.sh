#!/bin/sh -x
# After osc checkout, clean out all tarballs and .osc dirs
rm $(find -name '*.tar.*') $(find -name '*.zip')
rm -r $(find -name '.osc')
