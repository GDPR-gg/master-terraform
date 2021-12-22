# blobstore-scala-filesystem

This is a simple example command line client that creates a container and test blob in a filesystem [BlobStore](http://jclouds.apache.org/start/blobstore/) using Scala. This example uses [scala-arm](https://github.com/jsuereth/scala-arm) to manage the [BlobStoreContext](http://javadocs.jclouds.cloudbees.net/org/jclouds/blobstore/BlobStoreContext.html)

## Build

Ensure that [sbt is installed](http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html). Tested with 0.12.2

## Run

Run `sbt` from the root of your project and invoke
```
run <basedir> <containername> <blobname>
```
where <em>basedir</em> is a directory in which the container will be created. E.g. if your basedir is `/home/blobstore` and you want to store _myblob_ in _mycontainer_, run
```
run /home/blobstore mycontainer myblob
```

## License

Copyright (C) 2009-2014 The Apache Software Foundation

Licensed under the Apache License, Version 2.0
