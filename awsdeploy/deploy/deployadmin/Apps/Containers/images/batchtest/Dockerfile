FROM public.ecr.aws/amazonlinux/amazonlinux:2023

#update the container and install packages
RUN yum update -y
RUN yum install git -y
RUN yum install unzip -y
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install
RUN yum remove unzip -y
RUN yum install python3-pip -y
RUN pip3 --version
RUN pip3 install --user setuptools
RUN pip3 install --user git-remote-codecommit
RUN yum remove python3-pip -y
RUN yum install jq -y


WORKDIR /job
COPY include/* /job
RUN chmod -R 755 /job

ENTRYPOINT ["/job/run.sh"]


