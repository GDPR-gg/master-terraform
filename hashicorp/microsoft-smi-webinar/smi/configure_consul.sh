#! /bin/bash


acl=$(consul acl token create -description "read/write access for the consul-smi-controller" -policy-name global-management | sed -E -n 's/SecretID: *(\S*)/\1/p')

kubectl create secret generic consul-smi-acl-token --from-literal=token=${acl}
