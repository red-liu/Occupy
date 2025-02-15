#!/bin/bash 

# spawn instance and store id
instance_id=$(aws ec2 run-instances --image-id ami-ee6da48e --security-group-ids sg-890a37ed --count 1 --instance-type r3.large --key-name rstudio --instance-initiated-shutdown-behavior stop --query 'Instances[0].{d:InstanceId}' --output text)

# wait until instance is up and running
aws ec2 wait instance-running --instance-ids $instance_id

#add name tag
aws ec2 create-tags --resources $instance_id --tags Key=Name,Value=Occupy

#monitor usage
aws cloudwatch put-metric-alarm --alarm-name cpu-mon --alarm-description "Alarm when CPU drops below 2 over 10 minutes%" --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 2 --comparison-operator LessThanThreshold  --dimensions Name=InstanceId,Value=$instance_id --evaluation-periods 2 --alarm-actions arn:aws:sns:us-west-2:477056371121:Instance_is_idle --unit Percent

# retrieve public dns
dns=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[*].Instances[*].PublicDnsName' --output text | grep a)

#Wait for port to be ready, takes about a minute.
sleep 60

# copy over Job.bash to instance
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i '/c/Users/Ben/.ssh/rstudio.pem' /c/Users/Ben/Documents/Occupy/Amazon/Job.bash ubuntu@$dns:~

# run job script on instance, don't wait for finish and disconnect terminal
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i "/c/Users/Ben/.ssh/rstudio.pem" ubuntu@$dns "nohup ./Job.bash" &
