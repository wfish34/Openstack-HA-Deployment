#!/usr/bin/bash

for i in `more /etc/hosts|grep vm|awk -F " " '{print $2}'`
do
	scp readini.sh $i:/root
	scp cluster_variables.ini $i:/root
	scp /etc/hosts $i:/etc/
	scp vm* $i:/root
done

hacluster_node[1]=$(/usr/bin/bash readini.sh cluster_variables.ini default ha_node1)
hacluster_node[2]=$(/usr/bin/bash readini.sh cluster_variables.ini default ha_node2)
hacluster_node[3]=$(/usr/bin/bash readini.sh cluster_variables.ini default ha_node3)
ha_cluster_node_num=$(/usr/bin/bash readini.sh cluster_variables.ini default ha_cluster_node_num)
master_vm_name=$(/usr/bin/bash readini.sh cluster_variables.ini default master)-vm
master_vm_ip=$(/usr/bin/bash readini.sh cluster_variables.ini $master_vm_name int_ip)

for (( i = 1; i <=$ha_cluster_node_num; i++ ))
do
	echo "beging install memcached on ${hacluster_node[i]}"
	ssh root@${hacluster_node[i]} "yum install -y memcached"
done

echo "create memcached resource on pacemaker cluster"
ssh root@$master_vm_name "pcs resource delete memcached --force"
ssh root@$master_vm_name "pcs resource create memcached systemd:memcached --clone interleave=true"
ssh root@$master_vm_name "pcs status"
