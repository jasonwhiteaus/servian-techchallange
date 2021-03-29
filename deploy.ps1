WRITE-HOST "Starting Deployment via Terraform"
terraform init
terraform apply -auto-approve
$SUBNETID=$(aws ec2 describe-subnets --filter "Name=tag:Name,Values=TechChallenge-Subnet-0" --query Subnets[0].SubnetId --output text)
WRITE-HOST "Run Task IN ECS Cluster To Create Table and Seed Database"
aws ecs run-task --count 1 --launch-type FARGATE --cluster tc_ecs_cluster --task-definition techchallenge_task_updatedb --count 1 --network-configuration awsvpcConfiguration="{subnets=[$SUBNETID],assignPublicIp=ENABLED}"