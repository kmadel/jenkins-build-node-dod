# Docker image for basic Jenkins slave with Docker-On-Docker
# Map the hosts docker.sock to when running this container: -v /var/run/docker.sock:/var/run/docker.sock

FROM java:8-jdk
MAINTAINER Kurt Madel <kmadel@cloudbees.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    curl \
    ntp \
    ntpdate

# Create docker group
RUN groupadd -g 1001 jenkins
RUN groupadd docker

# Create Jenkins user
RUN useradd -u 1000 -g 1001 jenkins -d /home/jenkins
RUN echo "jenkins:jenkins" | chpasswd

# Make directories for [slaves] remote FS root, ssh privilege separation directory
RUN mkdir -p /home/jenkins /var/run/sshd

# Set permissions
RUN chown -R jenkins:jenkins /home/jenkins 

RUN curl -sSL https://get.docker.com/ | sh

#allow jenkins user to use docker, seems to be multiple permutations of group mapped to docker socket
RUN groupadd -g 999 hostdocker && usermod -aG hostdocker jenkins
RUN usermod -aG docker jenkins
RUN usermod -aG users jenkins

EXPOSE 22
ENTRYPOINT ["/usr/sbin/sshd", "-D"]
CMD ["-p 22"]