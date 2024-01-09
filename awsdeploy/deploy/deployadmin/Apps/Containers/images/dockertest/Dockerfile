#revised starting from AWS Example found here:
#https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/
#https://medium.com/cloud-security/container-security-450c784c0a60

# Define global args
ARG FUNCTION_DIR="/home/functions/"
ARG DISTRO_VERSION="2023.09.12.10"
ARG ARCHITECTURE="arm64"
ARG TODO_FIX_DEBUG_AND_CREDS

FROM public.ecr.aws/lambda/provided:al2.${DISTRO_VERSION}-${ARCHITECTURE}

#update the container and install git
RUN yum update -y
RUN yum install git -y
RUN yum install unzip -y
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN yum remove unzip -y
RUN yum install python3-pip -y
RUN pip3 --version
#RUN pip3 install --user git-remote-codecommit
RUN yum remove python3-pip -y
RUN yum install jq -y

# Include global arg in this stage of the build
ARG FUNCTION_DIR

# Copy the funtion script to the container
COPY include/functions/* ${FUNCTION_DIR}

# Set working directory to function root directory
WORKDIR ${FUNCTION_DIR}

#grant permissions to execute files in the function directory
RUN chmod -R 755 ${FUNCTION_DIR}

#copy the scripts with bash runtime code and common functions
COPY include/entry.sh /
COPY include/rie-bash.sh /
COPY include/errors.sh / 
COPY include/credentials.sh /
COPY include/init.sh /
COPY include/function_name.sh /
COPY include/secrets.sh /
COPY creds.sh / 
COPY include/validate.sh /

#grant permission to execute the common scripts
RUN chmod 755 /entry.sh
RUN chmod 755 /rie-bash.sh
RUN chmod 755 /errors.sh
RUN chmod 755 /credentials.sh
RUN chmod 755 /init.sh
RUN chmod 755 /function_name.sh
RUN chmod 755 /secrets.sh
RUN chmod 755 /creds.sh
RUN chmod 755 /validate.sh

#set the entry point
ENTRYPOINT [ "/entry.sh" ]

#pass in the function handler as parameter
CMD [ "functions.handler" ]
