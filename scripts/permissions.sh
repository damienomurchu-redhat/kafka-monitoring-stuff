#!/usr/bin/env bash

# Add or remove a user in the user.yaml file 
# chmod +x permissions.sh
# ./ permissions.sh
# Input add to add the users or input remove to delete the users

file="users.yaml"
clus_users=$(yq e '.cluster-admins[]' $file )

cluster_ids () {
    clus_id=($(ocm list clusters --parameter search="name like 'mk-___________%'"   | grep -v ID| awk '{print $1}'))

}

add_cluster_admin (){
        for id in ${clus_id[@]}; do
            get_users=($( ocm get /api/clusters_mgmt/v1/clusters/$id/groups/cluster-admins/users/  | grep -w "id"| sort| awk '{print $2}'))  
            printf "%s\n" ${get_users[@]} | tr -d '"' > perm.txt
            printf "%s\n" $clus_users > users.txt
            absent=($(comm -3 perm.txt users.txt))
                for i in ${absent[@]}; do
                    cat << EOF | ocm post /api/clusters_mgmt/v1/clusters/$id/groups/cluster-admins/users/ | jq ' .kind, .href, .id '
                    {"kind":"User","href":"/api/clusters_mgmt/v1/clusters/$id/groups/cluster-admins/users/$i","id":"$i"}
EOF
                done
            > users.txt && > perm.txt
        done
        rm users.txt && rm perm.txt 
}

remove_cluster_admins (){
        for id in ${clus_id[@]}; do
            get_users=($( ocm get /api/clusters_mgmt/v1/clusters/$id/groups/cluster-admins/users/  | grep -w "id"| sort| awk '{print $2}'))  
            printf "%s\n" ${get_users[@]} | tr -d '"' > perm.txt
            printf "%s\n" $clus_users > users.txt
            absent=($(comm -3 perm.txt users.txt))
                for i in ${absent[@]}; 
                do
                    $(ocm delete /api/clusters_mgmt/v1/clusters/$id/groups/cluster-admins/users/$i)
                    echo "Removing user $i from $id"
                done
            > users.txt && > perm.txt
        done
        rm users.txt && rm perm.txt
}

echo "To add a user input add, to remove input remove"
read input
case $input in 
add)    echo "Adding user(s) to data plane clusters"
        cluster_ids
        add_cluster_admin
        ;;
remove) echo "Removing user(s) from data plane clusters"
        cluster_ids
        remove_cluster_admins
        ;;
esac

