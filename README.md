## Troubleshooting 
`EACCES: permission denied, mkdir '/app/node_modules.cache` is an ongoing [Node and Docker issue](https://github.com/nodejs/docker-node/issues/740). In summary, best practice is to NEVER run node as root as "bad things can happen". It was necessary to also be cognizant of this at the `COPY` layer when copying over `package.json` as well as the app directory using [this syntax](https://docs.docker.com/engine/reference/builder/#copy).


## Docker

if running in development, add `-f Dockerfile.dev`, otherwise it will default to `Dockerfile` for production.
```bash
docker image build -f Dockerfile.dev -t frontend-dev .
docker image build -t frontend-prod .
```

```bash
docker container run -it --rm -p 3000:3000 frontend-dev
docker container run -it --rm -p 3000:3000 frontend-prod
```

## **docker-compose**

after setting up configurations with `docker-compose.yaml`, execute command to build image
```bash
docker-compose --verbose -f docker-compose-dev.yaml build --no-cache
```

spin up container for `client` services:
```bash
docker-compose up client
```
which generates container: 
```bash
$ docker container  ps
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS          PORTS                                       NAMES
IMAGE_ID   frontend_client   "docker-entrypoint.s…"   13 minutes ago   Up 13 minutes   0.0.0.0:3000->3000/tcp, :::3000->3000/tcp   frontend

```

ssh onto container to address vulnerabilities returned after image build, where `client` is the name of the service given in `docker-compose.yaml`:

```bash
docker-compose exec client ash
```


after `npm install`, make note of the security vulnerabilities and audit issues:
```bash
added 1845 packages, and audited 1846 packages in 2m

139 packages are looking for funding
  run `npm fund` for details

84 moderate severity vulnerabilities

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
```

## Test
run NPM test 

```bash
docker container run -it frontend_client yarn test
```

## Steps 

Initial Setup

1. Go to AWS Management Console

2. Search for Elastic Beanstalk in "Find Services"

3. Click the "Create Application" button

4. Enter "docker" for the Application Name

5. Scroll down to "Platform" and select "Docker" from the dropdown list.

6. Change "Platform Branch" to Docker running on 64bit Amazon Linux

7. Click "Create Application"

8. You should see a green checkmark after some time.

9. Click the link above the checkmark for your application. This should open the application in your browser and display a Congratulations message.

Change from Micro to Small instance type:

Note that a t2.small is outside of the free tier. t2 micro has been known to timeout and fail during the build process.

1. In the left sidebar under Docker-env click "Configuration"

2. Find "Capacity" and click "Edit"

3. Scroll down to find the "Instance Type" and change from t2.micro to t2.small

4. Click "Apply"

5. The message might say "No Data" or "Severe" in Health Overview before changing to "Ok"

Add AWS configuration details to .travis.yml file's deploy script

1. Set the region. The region code can be found by clicking the region in the toolbar next to your username.

eg: 'us-east-1'

2. app should be set to the Application Name (Step #4 in the Initial Setup above)

eg: 'docker'

3. env should be set to the lower case of your Beanstalk Environment name.

eg: 'docker-env'

4. Set the bucket_name. This can be found by searching for the S3 Storage service. Click the link for the elasticbeanstalk bucket that matches your region code and copy the name.

eg: 'elasticbeanstalk-us-east-1-923445599289'

5. Set the bucket_path to 'docker'

6. Set access_key_id to $AWS_ACCESS_KEY

7. Set secret_access_key to $AWS_SECRET_KEY

Create an IAM User

1. Search for the "IAM Security, Identity & Compliance Service"

2. Click "Create Individual IAM Users" and click "Manage Users"

3. Click "Add User"

4. Enter any name you’d like in the "User Name" field.

eg: docker-react-travis-ci

5. Tick the "Programmatic Access" checkbox

6. Click "Next:Permissions"

7. Click "Attach Existing Policies Directly"

8. Search for "beanstalk"

9. Tick the box next to "AdministratorAccess-AWSElasticBeanstalk"

10. Click "Next:Tags"

11. Click "Next:Review"

12. Click "Create user"

13. Copy and / or download the Access Key ID and Secret Access Key to use in the Travis Variable Setup.

Travis Variable Setup

1. Go to your Travis Dashboard and find the project repository for the application we are working on.

2. On the repository page, click "More Options" and then "Settings"

3. Create an AWS_ACCESS_KEY variable and paste your IAM access key from step #13 above.

4. Create an AWS_SECRET_KEY variable and paste your IAM secret key from step #13 above.

Deploying App

1. Make a small change to your src/App.js file in the greeting text.

2. In the project root, in your terminal run:

    git add.
    git commit -m “testing deployment"
    git push origin master

3. Go to your Travis Dashboard and check the status of your build.

4. The status should eventually return with a green checkmark and show "build passing"

5. Go to your AWS Elasticbeanstalk application

6. It should say "Elastic Beanstalk is updating your environment"

7. It should eventually show a green checkmark under "Health". You will now be able to access your application at the external URL provided under the environment name.