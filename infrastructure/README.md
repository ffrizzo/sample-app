# Sample Go Application

This repository contains the infrastructure to deploy the sample application.


### How to execute it

To deploy the infrastructure we need to create resources on right order. The correct order is described bellow

1. **ecr** creates the ecr repository
2. **vpc** creates the vpc/subnets and other components for nertwork
3. **app** creates ALB and ECS to deploy application
