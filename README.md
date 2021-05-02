# WebLogic Deployment Demo

This repository implements a showcase how to run the WebLogic server in a Docker container and deploy a WAR file at runtime.

For deploying a WAR file to WebLogic the following three steps are required:

1. Build a Java Web Application as WAR file
1. Copy the WAR file to the system/container which hosts a WebLogic server
1. Deploy the WAR file to the WebLogic server

This repository brings along all components to build a WAR file and run WebLogic in a Docker container:

1. Example Java Web Application, see [/ExampleApp](ExampleApp)
1. Docker-Compose file to run WebLogic in a Docker container

In order to pull the WebLogic Docker image from Docker Hub you need to accept the licence agreement on Docker Hub.
After accepting the license agreement the public WebLogic image becomes available to you:

```sh
docker login
docker pull store/oracle/weblogic:12.2.1.4-dev
```

## Option A) Fast track

If you want to run this showcase quickly you can use the [Docker-Compose file](docker-compose.yaml) to build the [ExampleApp](ExampleApp) and start up WebLogic in a Docker container.
The ExampleApp.war is copied into the Docker container as **/usr/app/ExampleApp.war**.

```sh
docker-compose build
docker-compose up -d
```

To deploy the WAR file please use the script in this repository:

```sh
./deployExampleApp
```

Afterwards you will see the ExampleApp listed as deployment in the WebLogic Console (the admin credentials can be found here [/properties/domain.properties](properties/domain.properties)):

[https://localhost:9002/console](https://localhost:9002/console)

The example app runs on port 7001:

[http://localhost:7001/ExampleApp](http://localhost:7001/ExampleApp)

## Option B) The journey is the reward

If you want to see all necessary steps to deploy a WAR file to WebLogic the following step-by-step description guides you through the process how to deploy WAR files to WebLogic while runtime.

### Build WAR file

The [ExampleApp](ExampleApp) which is part of this repository is a Maven project. When building it a WAR file becomes generated at package phase:

```sh
cd ExampleApp/
./mvnw clear package
cd ..
```

### Run WebLogic and mount the WAR file

Using the following Docker run command, WebLogic is started up in a Docker container.

```sh
docker run --name weblogic_deployment_demo -d -p 7001:7001 -p 9002:9002 -e DOMAIN_NAME=base_domain \
  -v $PWD/properties:/u01/oracle/properties \
  -v $PWD/ExampleApp/target/ExampleApp-0.0.1-SNAPSHOT.war:/usr/app/ExampleApp.war \
  store/oracle/weblogic:12.2.1.4-dev
```

The command above mounts the previously build WAR file in the WebLogic container here: **/usr/app/ExampleApp.war**.

### Deploy the WAR file

There are three ways to deploy WAR files by script to WebLogic. One way is to use WebLogic's REST API. The following API call will deploy the WAR file (replace **USER** and **PASSWORD**):

```sh
curl -v --insecure --user <USER>:<PASSWORD> -H X-Requested-By:MyClient -H Content-Type:application/json \
     -d "{ name: 'ExampleApp', sourcePath: '/usr/app/ExampleApp.war', targets: [ { identity: [ 'servers', 'AdminServer' ] } ] }" \
     -X POST https://localhost:9002/management/weblogic/latest/edit/appDeployments
```

As described under "Option A", you can check the deployment state using the WebLogic Console or running the example app in a browser.

## References

* Docker Image: [https://github.com/oracle/docker-images/tree/main/OracleWebLogic/dockerfiles/12.2.1.4](https://github.com/oracle/docker-images/tree/main/OracleWebLogic/dockerfiles/12.2.1.4)
* WebLogic API documentation for deploying WAR files: [https://docs.oracle.com/en/middleware/standalone/weblogic-server/14.1.1.0/wlrer/op-management-weblogic-version-edit-appdeployments-x-operations-1.html](https://docs.oracle.com/en/middleware/standalone/weblogic-server/14.1.1.0/wlrer/op-management-weblogic-version-edit-appdeployments-x-operations-1.html)
* WebLogic CLI dcumentation for depoying WAR files with weblogic.Deployer [https://docs.oracle.com/cd/E13222_01/wls/docs90/deployment/wldeployer.html](https://docs.oracle.com/cd/E13222_01/wls/docs90/deployment/wldeployer.html)
