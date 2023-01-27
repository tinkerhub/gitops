[
  {
    "essential": true,
    "name": "${APP_NAME}",
    "image": "${REPOSITORY_URL}",
    "portMappings": [
      {
        "containerPort": ${CONTAINER_PORT},
        "hostPort": ${HOST_PORT}
      }
    ],
    "secrets": ${SECRETS},
    "environment": ${CONTAINER_ENVS},
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
