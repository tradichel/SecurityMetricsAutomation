#revised starting from AWS Example found here:
#https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/
#https://medium.com/cloud-security/container-security-450c784c0a60

# Define global args
ARG FUNCTION_DIR="/home/functions/"
ARG DISTRO_VERSION="2023.09.12.10"
ARG ARCHITECTURE="arm64"

FROM public.ecr.aws/lambda/provided:al2.${DISTRO_VERSION}-${ARCHITECTURE}

#update the container and install git
RUN yum update -y
RUN yum install git -y

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Copy the funtion script to the container
COPY functions/* ${FUNCTION_DIR}

# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

#grant permissions to execute files in the function directory
RUN chmod -R 755 ${FUNCTION_DIR}

#copy the entry script with bash runtime code
COPY entry.sh /
COPY rie-bash.sh /

#grant permission to execute the entry scripts
RUN chmod 755 /entry.sh
RUN chmod 755 /rie-bash.sh

#set the entry point
ENTRYPOINT [ "/entry.sh" ]

#pass in the function handler as parameter
CMD [ "functions.handler" ]



