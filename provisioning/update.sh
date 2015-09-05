#!/bin/sh
/usr/bin/puppet apply --modulepath=/var/src/provisioning/puppet/modules --hiera_config=/var/src/provisioning/puppet/hiera.yaml /var/src/provisioning/puppet/manifests/init.pp