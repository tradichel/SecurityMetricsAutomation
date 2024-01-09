#revised starting from AWS Example found here:
#https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/
#https://medium.com/cloud-security/container-security-450c784c0a60

# Define global args
ARG FUNCTION_DIR="job"
ARG LAMBDA_DIR="lambda"
ARG INCLUDE_DIR="include"
ARG DISTRO_VERSION="2023.09.12.10"
ARG ARCHITECTURE="arm64"

FROM public.ecr.aws/lambda/provided:al2.${DISTRO_VERSION}-${ARCHITECTURE}

#update the container and install git
RUN yum update -y
RUN yum install git -y
RUN yum install unzip -y
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN yum install which -y
RUN yum remove unzip -y
RUN yum install python3-pip -y
RUN pip3 --version
RUN pip3 install setuptools
RUN pip3 install git-remote-codecommit
RUN yum remove python3-pip -y
RUN yum install jq -y

# Include global arg in this stage of the build
ARG FUNCTION_DIR
ARG LAMBDA_DIR
ARG INCLUDE_DIR

WORKDIR /${FUNCTION_DIR}
COPY ${FUNCTION_DIR}/* /${FUNCTION_DIR}/
RUN chmod -R 755 /${FUNCTION_DIR}

RUN git config --system credential.helper '!aws codecommit credential-helper $@'
RUN git config --system credential.UseHttpPath true

COPY ${LAMBDA_DIR}/* /${LAMBDA_DIR}/
RUN chmod -R 755 /${LAMBDA_DIR}

COPY ${INCLUDE_DIR}/* /${INCLUDE_DIR}/
RUN chmod -R 755 /${INCLUDE_DIR}

ENTRYPOINT ["/lambda/entry.sh" ]

#may be extraneous the way I currently have this configured
CMD [ "job.run" ]

