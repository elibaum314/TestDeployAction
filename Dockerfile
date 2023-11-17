FROM node:lts

USER root
COPY . . 
WORKDIR /NetSuite21


RUN apt update 
RUN apt install openjdk-17-jdk -y

RUN npm i -g --unsafe-perm --acceptSuiteCloudSDKLicense @oracle/suitecloud-cli