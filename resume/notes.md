## Where I've worked
* Dfinity STIFTUNG: 2022 (sept) - now
* Sotex Solutions: 2021 (may) - 2022 (sept) - I was outsorced to Schneider Electric in Seville.

## What I've worked on
DFINITY: [SRE]
* Developed a service discovery component for enumerating machines in different environments which can be used for other purposes, like quering, monitoring and so on. This saved a lot of time for others and gave us quite an easy time when developing new things as we can just build something on top of it. Stack: Rust, Docker, Python, Bazel, Kubernetes.
* Developed core log fetching logic for different environments and different scales. Used scalable tech and deployed it as an aggregated service which the whole company relies on to know what's happening on the network. Stack: Rust, Python, Docker, Bazel, Kubernetes, Kibana, Elasticsearch, Vector.dev
* Developed a lot of additional tooling for interacting with the network that is used by community almost daily. Stack: Python, Rust, Golang.
* Saved a lot of money by migrating observability stack from cloud to on-premise kubernetes clusters. Stack: AWS, GCP, On-prem machines Kubernetes.
* Automated our heavily manual release processes by building a release controller which has allowed us to hit our goals of releasing every week in previous years. Stack: Apache Airflow, Python, Kubernetes.
* Been involved with the community on the forum and in regular monthly meetings with them to give progress updates and gather feedback.
* Worked a lot on a utility which allows easy enrollment in oncall duties in the company, severily cutting down the overhead of oncall schedules and post mortem meetings. Stack: Jira Service Management, OpsGenie, Pagerduty, Python
* Worked a lot on automating observability in system tests that are used by all of the developers. Stack: Grafana, Prometheus, VictoriaMetrics, Vector, Rust, Golang.

DFINITY: [SWE]
* Numerous features that focus on allowing our Node Providers (the backbone of our network) to have easier time when managing their tech. Developed a small observability platform that can be deployed on small machines (raspberry pies) and allow the node providers to act when their hardware is not operating well, cutting their losses and making our network way more resiliant. Stack: Ansible, Python, Vagrant.
* Developed the main tool used for composing a secure and decentralized network allowing the community to repeat the steps we took in order to reach certain topologies and ensure that the decentralization is at its best at all times possible. Stack: python.
* Contributed to a number of really important canisters (decentralized Apps) that run on our network on which the community relies, like "Registry canister" (containing all of the information about the network linking the physical and digital world), or the "Node rewards canister" (responsible for paying out rewards to the node providers based on the quality of service they provide to the network). Stack: Rust.
* Contributed to the disaster recovery strategies by implementing ways to restore a network if it stalls. Stack: Rust, Python, AWS, Cloudflare R2.
* Contributed to the testing drivers that are used among developers to ensure the quality of the software before it reaches production. Stack: Haskel, Rust, Golang, Bazel.
* Implemented very important feature for the node providers that allowed them to replace faulty nodes which cut down operation and maintenance costs from days to minutes. Stack: Rust.
* Implemented very important feature for migrating node operators which allowed the users to rotate private keys used for managing nodes which hardened security. Previously it was needed for the node to be removed and reinstalled and now it takes seconds. Stack: Rust.
* Worked on a NNS recovery which made our network resiliant to failures and solved the issue of breaking the network if its brain stalls. Joint work with other teams and was responsible for designing parts of the system related to process orchestration. Massive improvement. Stack: Rust.

Sotex: [SWE]
* Worked on a bunch of microservices that have a job to handle big loads of events, aggregate them and process them in near real time. These included smart metering solutions and a billing detemrinant module. Stack: .NET, Mssql, Docker, Kubernetens, NServiceBus.
* Developed fully automated ways of deploying whole environments with Terraform, allowing developers to quickly test things or spawn new environments for clients. Stack: Terraform, Github Actions, Azure DevOps.
* Refactored a lot of code to facilitate using of Docker and repeatable software. Focused internal developer experience a lot from the start. Stack: .NET, Docker, Mssql, Kafka.
* Heaviliy improved new developer onboarding process because I worked in a team that frequently rotated developers around projects. Stack: Bash, Docker, Azure Entra.
* Closly worked on the architecture planning with a Solution Architect giving useful insights in scallability and how we can trasition to what we have now to something we need in the future.

Sotex-box [SWE]:
* Founding engineer for a product that will deliver ads to poor bandwidth networks in Serbia. Stack: .NET, Postgres, AWS, Pulumi, Flutter.
* Played all of the roles in the software development journey, from a Solution Architect, across development and devops to sales and marketing.
* Developed a solution that can scale to 10k devices (TVs and/or computers) playing ads simultaniously under severe budget restrictions. The whole solution costs 40$ a month and generates ~5000$ a month.

## Interests
I am very interested in distributed software, security, internal development experience and testing. 

## Trivia
* I like leetcode
* I like gym and sports
* I am a good public speaker and enjoy working in teams. Generally love working from the office.
* Eager to learn a lot.
