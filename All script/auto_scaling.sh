auto_scaling_break_fix () {
    ##start time=current time + 5 minutes##
    start_time=`date --date='+5 minutes' +"%Y-%m-%dT%H:%M:%SZ" -u`
    echo "Start Time is $start_time"
    group_name="ec2-asg-diaas-ref-ecs-cluster"
    echo "Auto Group Name is $group_name"
    region="us-east-2"
    aws_profile="default"
    ##action get from parameter either start or stop##
    action="$1"
    if [ $action = "start" ]
    then
        action_name="start-env"
        echo "Schehuled Action Name is $action_name"
        min_size="1"
        echo "Min Size is $min_size"
        max_size="2"
        echo "Max Size is $max_size"
        desire_capacity="1"
        echo "Desire Capacity is $desire_capacity"
    elif [ $action = "stop" ]
    then
        action_name="stop-env"
        echo "Schehuled Action Name is $action_name"
        min_size="0"
        echo "Min Size is $min_size"
        max_size="0"
        echo "Max Size is $max_size"
        desire_capacity="0"
        echo "Desire Capacity is $desire_capacity"
    fi
    ##aws command to create scheduled action##
    aws autoscaling --profile $aws_profile put-scheduled-update-group-action --auto-scaling-group-name $group_name --scheduled-action-name $action_name --start-time "$start_time"  --min-size $min_size --max-size $max_size --desired-capacity $desire_capacity --region $region
    echo "Scheduled Action $action_name has been created successfully"
}

auto_scaling_preprod () {
    ##start time=current time + 5 minutes##
    start_time=`date --date='+5 minutes' +"%Y-%m-%dT%H:%M:%SZ" -u`
    echo "Start Time is $start_time"
    group_name="ec2-asg-aig-psup-ecs-cluster"
    echo "Auto Group Name is $group_name"
    region="ap-southeast-2"
    aws_profile="default"
    ##action get from parameter either start or stop##
    action="$1"
    if [ $action = "start" ]
    then
        action_name="start-env"
        echo "Schehuled Action Name is $action_name"
        min_size="2"
        echo "Min Size is $min_size"
        max_size="2"
        echo "Max Size is $max_size"
        desire_capacity="3"
        echo "Desire Capacity is $desire_capacity"
    elif [ $action = "stop" ]
    then
        action_name="stop-env"
        echo "Schehuled Action Name is $action_name"
        min_size="0"
        echo "Min Size is $min_size"
        max_size="0"
        echo "Max Size is $max_size"
        desire_capacity="0"
        echo "Desire Capacity is $desire_capacity"
    fi
    ##aws command to create scheduled action##
    aws autoscaling --profile $aws_profile put-scheduled-update-group-action --auto-scaling-group-name $group_name --scheduled-action-name $action_name --start-time "$start_time"  --min-size $min_size --max-size $max_size --desired-capacity $desire_capacity --region $region
    echo "Scheduled Action $action_name has been created successfully"
}