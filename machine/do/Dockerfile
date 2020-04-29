FROM golang:1.14.2-buster AS build
# Install pulumi binaries and plugins.
RUN curl -fsSL https://get.pulumi.com | sh && \
    /root/.pulumi/bin/pulumi plugin install resource digitalocean v1.7.0
COPY . /go/src/github.com/darkowlzz/remotedev/machine/do
WORKDIR /go/src/github.com/darkowlzz/remotedev/machine/do
RUN GOOS=linux GOARCH=amd64 go build -v -o $(basename $(pwd))

FROM ubuntu:eoan
# Copy pulumi and go. The presence of go is checked by pulumi even when using a
# precompiled pulumi go program.
COPY --from=build /root/.pulumi/bin/* /usr/local/bin/
COPY --from=build /usr/local/go/bin/go /usr/local/bin/
# Update any old certs in the image and copy pulumi plugins.
RUN apt-get update -y && \
    apt-get install ca-certificates openssh-client -y && \
    mkdir -p /root/.pulumi/plugins
COPY --from=build /root/.pulumi/plugins/ /root/.pulumi/plugins/

# COPY the pulumi go program.
COPY --from=build /go/src/github.com/darkowlzz/remotedev/machine/do /usr/local/bin/

ENTRYPOINT ["bash"]
