FROM amazonlinux:2

RUN yum update -y && yum install -y ruby python3 python3-pip openssh-clients
RUN pip3 install percol
RUN gem install -N inifile aws-sdk
RUN mkdir /app
ADD ec2ssh.rb /app

ENTRYPOINT ["ruby", "/app/ec2ssh.rb"]
