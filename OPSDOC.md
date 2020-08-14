# Nexus Repository Installer

The purpose of this repository is to create Deb and Rpm packages of Nexus. 



## Where?

| What?           | Location                                                     |
| --------------- | ------------------------------------------------------------ |
| Source Code     | https://github.com/sonatype-nexus-community/nexus-repository-installer |
| CI              | https://circleci.com/gh/sonatype-nexus-community/nexus-repository-installer |
| Production Apt  | https://repo.sonatype.com/repository/community-apt-hosted/   |
| Development Apt | https://nx-staging.sonatype.com/repository/community-apt-hosted/ |
| Production Yum  | https://repo.sonatype.com/repository/community-yum-hosted/   |
| Development Yum | https://nx-staging.sonatype.com/repository/community-yum-hosted/ |



## How?

The jobs are run via CircleCI. Below will be a sample overview of the build process. The trigger to run the job in CircleCI is done via scheduled trigger. This trigger runs and checks the latest version from https://download.sonatype.com. This is run daily on the master branch only.



### Workflows

---

### manual_deploy

1. runs the build job
2. waits for approval after the build to continue
3. continues with deployment

### check_for_new_releases

This is essentially the daily trigger.



### Jobs

---

### build

1. scm checkout
2. setup docker environment
3. executes a makefile to build the packages (deb and rpm)



### build_and_deploy

This runs the same steps as *build* with the addition of deploying the packages to both the development and production repositories as listed above.

1. deploys rpm to staging
2. deploys deb to staging
3. deploys rpm to production
4. deploys deb to staging



