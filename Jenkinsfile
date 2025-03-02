pipeline {
    agent {
        docker {
            image 'docker:24.0.5-dind' // Replace with the latest DinD image if needed
            args '--privileged -v /var/lib/docker:/var/lib/docker'
        }
    }
    environment {
        DOCKER_CLI_EXPERIMENTAL = 'enabled' // Enables experimental Docker features
        DOCKER_BUILDKIT = '1'              // Enables BuildKit for multi-platform builds
        IMAGE_NAME = 'fkrivsky/readymedia' // Docker image name
        DATE_TAG = sh(script: "date +'%Y-%m-%d'", returnStdout: true).trim() // Current date
    }
    stages {
        stage('Setup Build Environment') {
            steps {
                sh '''
                    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
                '''
            }
        }
        stage('Build and Push Image') {
            steps {
                sh '''
                    docker buildx create --use
                    docker buildx inspect --bootstrap
                    docker buildx build --push \
                    --platform linux/arm/v7,linux/arm64,linux/amd64 \
                    --tag ${IMAGE_NAME}:${DATE_TAG} \
                    --tag ${IMAGE_NAME}:latest \
                    .
                '''
                }
            }
        }
    }
    post {
        always {
            script {
                // Clean up the builder instance to avoid leftover state
                sh 'docker buildx rm || true'
            }
        }
    }
}
