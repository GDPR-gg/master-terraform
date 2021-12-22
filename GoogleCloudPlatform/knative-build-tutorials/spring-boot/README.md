<walkthrough-author name="David Gageot" repositoryUrl="https://github.com/GoogleCloudPlatform/knative-build-tutorials" email="dgageot@google.com" tutorialName="knative-build-spring-boot"></walkthrough-author>

# Knative Build - Java application

The previous tutorial taught you how to build and push a Docker image from a Dockerfile,
using Knative Build and Kaniko.

Let's try something different and build a [Java Spring Boot web application](https://github.com/dgageot/hello-jib),
without Docker. It will still produce a Docker image at the end, though.

## What am I going to learn?

 1. You are going to use Knative Build with [Jib](https://github.com/GoogleContainerTools/jib),
another open-source project from Google. Jib is a maven and gradle plugin that knows how to produce a Docker image
from Java sources. It's easy to use as a Knative Build step.

 2. You will learn how to decrease the build duration by configuring a build cache.

**Time to complete:** <walkthrough-tutorial-duration duration="5"></walkthrough-tutorial-duration>

**Are you ready?** Then click the `Continue` button to get started....

## Jib and Knative Build

<walkthrough-spotlight-pointer spotlightId="devshell-web-editor-button">Open the file editor</walkthrough-spotlight-pointer>.
Here's the Kubernetes <walkthrough-editor-open-file filePath="knative-build-tutorials/spring-boot/build.yaml">yaml manifest</walkthrough-editor-open-file>
to express such a build:

```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: jib
spec:
  serviceAccountName: knative-build
  source:
    git:
      url: https://github.com/dgageot/hello-jib.git
      revision: master
  steps:
  - name: build-and-push
    image: gcr.io/cloud-builders/mvn
    args: ["compile", "jib:build", "-Dimage=gcr.io/[PROJECT-NAME]/hello-jib"]
```

**Git source**

Like for the previous tutorial, the build reads the sources from a [git repository](https://github.com/dgageot/hello-jib).

**Maven**

This time, we are using [Maven](https://maven.apache.org/) to do the actual build.
We use the `gcr.io/cloud-builders/mvn` image that is one of the Google
[curated images](https://github.com/GoogleCloudPlatform/cloud-builders).

From the arguments, Maven knows it has to compile the Java sources and then call Jib
to produce a Docker image.

```yaml
- name: build-and-push
  image: gcr.io/cloud-builders/mvn
  args: ["compile", "jib:build", "-Dimage=gcr.io/[PROJECT-NAME]/hello-jib"]
```

**Service Account**

Once the image is built, it'll be pushed to [Google Container Registry](https://cloud.google.com/container-registry/),
so, we are going to reuse the `knative-build` service account we've setup
for previous tutorial.

**Click the `Continue` button to run the build...**

## Run the Build

Before we run the build, you need to edit <walkthrough-editor-open-file filePath="knative-build-tutorials/spring-boot/build.yaml">spring-boot/build.yaml</walkthrough-editor-open-file> and replace `[PROJECT-NAME]`
with your project name.

Let's run the build:

```bash
kubectl apply -f spring-boot/build.yaml
```

The build is running:

```bash
kubectl get builds
```

Tail the logs with:

```bash
logs jib
```

**Congratulations! You built your first Java Application with Knative Build.**

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

**Continue to next step, to improve the build file...**

## Clean builds are slow

If you run the build a second time, you'll see that it downloads lots of files
that were already downloaded the first time. It's because Maven is starting
the build from the sources and nothing else.

That makes the build more reproducible but also slower.

Most of the time, it's safe to share the artifacts that Maven downloads across builds.
And it usually makes a build much faster.

**We need a cache**

Because Knative Build is native to Kubernetes, it can leverage [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
to share a cache across builds. All we have to do is make some changes to the `build.yaml`.

**Click the `Continue` button to configure this cache...**

## Update the Build manifest

We are going to use a more elaborate version of the Build manifest that looks like that:

```yaml
apiVersion: build.knative.dev/v1alpha1
kind: Build
metadata:
  name: jib-cache
spec:
  serviceAccountName: knative-build
  source:
    git:
      url: https://github.com/dgageot/hello-jib.git
      revision: master
 
  steps:
  - name: build-and-push
    image: gcr.io/cloud-builders/mvn
    args: ["compile", "jib:build", "-Dimage=gcr.io/[PROJECT-NAME]/hello-jib"]
    volumeMounts:
    - name: mvn-cache
      mountPath: /root/.m2

  volumes:
  - name: mvn-cache
    persistentVolumeClaim:
      claimName: cache
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: cache
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 8Gi
```

This configuration does two things:

 + It creates a Persistent Volume to be shared by builds
 + It mounts this volume in `/root/.m2` during a build so that files written there will be available to next build.

**Continue to next step, to give it a try...**

## Run with a cache

*Warning*: don't forget to replace `[PROJECT-NAME]` with you actual
project name in
<walkthrough-editor-open-file filePath="knative-build-tutorials/spring-boot/build-cache.yaml">spring-boot/build-cache.yaml</walkthrough-editor-open-file>

Let's run the build:

```bash
kubectl apply -f spring-boot/build-cache.yaml
```

The build is running:

```bash
kubectl get builds
```

Tail the logs with:

```bash
logs jib-cache
```

You should still see the files being downloaded but let's
run the same build a second time.

```bash
kubectl delete build jib-cache
```

```bash
kubectl apply -f spring-boot/build-cache.yaml
```

```bash
logs jib-cache
```

Now, the build should be a bit faster and you see in the logs that no file
was downloaded from Maven Central!

**The more dependencies your application has, the bigger the gain.**

## Congratulations!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Amazing! You've used a cache to make your builds much faster.
You are an expert user now!

If you'd like to learn more about Knative Build, go check out the documentation
[here](https://github.com/knative/docs/tree/master/build).

**Have fun!**

<walkthrough-footnote>
Copyright 2018 Google LLC All Rights Reserved. Licensed under the Apache
License, Version 2.0 (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0.
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.
</walkthrough-footnote>