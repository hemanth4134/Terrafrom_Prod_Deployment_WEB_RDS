                         Route 53
                            |
                       CloudFront
                            |
                           WAF
                            |
                    Application LB
                    /             \
             Public AZ-A       Public AZ-B
                  |                 |
                  +-------+---------+
                          |
                    Private Subnets
                    /              \
                 ECS-A            ECS-B
                  |                 |
                  +-------+---------+
                          |
                     RDS PostgreSQL
                     Multi-AZ
                          
                    ECS Task Role
                          |
                    Least Privilege
                          |
                         S3
                          
                    CloudWatch
                    /        \
                 Logs       Metrics
