# digital-apigee

## Goals

The goal is to define an entire life cycle of communication between a Front-End Machine to a DMZ Network Back-End machine passing thru API Gee Proxy and Network Gateway that redirect call to the Service.

Here a simple communication diagram :

<p align="center"><img width="744" height="397" src="/images/arch-simple.png"></p>

Here an APIGee enterprise communication diagram :

<p align="center"><img width="744" height="429" src="/images/arch-enterprise.png"></p>

Here a vertical complete diagram. It specifies the networks related to system actors :

<p align="center"><img width="744" height="690" src="/images/arch-complete-vertical.png"></p>

The players in the architecture are :
* Client System : It can be any application that have to request API Rest Services
* Client Gateway : NGNIX Proxy communicating with your APIGee Proxies
* APIGee Micro-Gateway : Reverse Proxy and API Manager, APIGee Edge Organization Account
* Service Gateway : Buildit Gateway API Rest streaming manager, down-streaming APIGee Proxy requests
* REST API Service: Machine with a sampler pipeline (Jenkins, SonarQube, Sonar PostgreSQL database and Nexus OSS docker containers)

This project realizes a RIG instance on following cloud providers:
* Amazon Web Service

## Technology

Ansible python scripts.


## Issues during the Experience definition

APIGee Gateway limitation for free organization on java-callout feature interrupted the experience, no Edge-Microgateway feature could be tested on a free account.

Reference Topic for the Issue: [Official APIGee Cloud Blog](https://apigee.cloud.answerhub.com/questions/37212/edge-micro-gateway-233-beta-configurations-not-dow.html)


## Implementations

This project has following implementations:

Amazon Web Services
* [ec2](/digitalrig-apigee-riglet/ec2) - Development/Studies RIG, with a sample APIGee Gateway Callback Servers environment

## What is provided with the installation ?

The following resource are provided with the installation :
* APIGee Infrastructure (Test Case scenarios)
* APIGee Architecture set-up
* Pipeline Deployment (Jenkins Pipeline)

## How-to play this project?

Follow the installation guides provided in each implementation.

## License

Copyright (c) 2016-2017 [BuildIt, Inc.](https://medium.com/buildit)

Licensed under the [MIT](/LICENSE) License (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
