#!/usr/bin/env bash
file="users.yaml"
ded_users=$(yq e '.dedicated-admins[]' $file )
clus_users=$(yq e '.cluster-admins[]' $file )




cluster_ids () {
    clus_id=($(ocm list clusters --parameter search="name like 'mk-___________%'"   | grep -v ID| awk '{print $1}'))

}

cluster_admin (){
        for id in ${clus_id[@]}; do
        get_users=($( ocm get /api/clusters_mgmt/v1/clusters/$id/groups/cluster-admins/users/  | grep -w "id"| sort| awk '{print $2}'))  
                    printf "%s\n" ${get_users[@]} | tr -d '"' >> perm.txt
                    printf "%s\n" $clus_users >> users.txt

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
                    printf "%s\n" ${get_users[@]} | tr -d '"' >> perm.txt
                    printf "%s\n" $clus_users >> users.txt

                    absent=($(comm -3 perm.txt users.txt))
                        for i in ${absent[@]}; do
                        $(ocm delete /api/clusters_mgmt/v1/clusters/$id/groups/cluster-admins/users/$i)
                        echo "removing users $i"
                        done
                    > users.txt && > perm.txt

        done
        rm users.txt && rm perm.txt
}

echo "To add a user input Add, to remove input Remove"
read input

case $input in 
Add)    cluster_ids
        cluster_admin
        echo "Adding user to data plane clusters"
        ;;
Remove) cluster_ids
        remove_cluster_admins
        echo "Removing user from data plane clusters"
        ;;

esac

