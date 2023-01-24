
[
  {
    "essential": true,
    "memory": 512,
    "name": "${APP_NAME}",
    "cpu": 256,
    "image": "${REPOSITORY_URL}",
    "portMappings": [
      {
        "containerPort": ${CONTAINER_PORT},
        "hostPort": ${HOST_PORT}
      }
    ],
    "secrets": ${SECRETS},
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${CLOUDWATCH_LOG_GROUP}",
        "awslogs-region": "${AWS_REGION}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
