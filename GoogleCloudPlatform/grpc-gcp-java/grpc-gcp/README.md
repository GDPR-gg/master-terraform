# gRPC-GCP for Java

grpc-gcp provides gRPC support for Google Cloud Clients.

## Usage

Use Spanner API as an example.

First, Create a json file defining API configuration, with ChannelPoolConfig and MethodConfig.

```json
{
  "channelPool": {
    "maxSize": 3,
    "maxConcurrentStreamsLowWatermark": 0
  },
  "method": [
    {
      "name": [ "google.spanner.v1.Spanner/CreateSession" ],
      "affinity": {
        "command": "BIND",
        "affinityKey": "name"
      }
    },
    {
      "name": [ "google.spanner.v1.Spanner/GetSession" ],
      "affinity": {
        "command": "BOUND",
        "affinityKey": "name"
      }
    },
    {
      "name": [ "google.spanner.v1.Spanner/DeleteSession" ],
      "affinity": {
        "command": "UNBIND",
        "affinityKey": "name"
      }
    }
  ]
}
```

Initialize `GcpManagedChannel` based on this API config file.

```java
String API_CONFIG_FILE = "api_config_file.json"
String SPANNER_TARGET = "spanner.googleapis.com";
...

ManagedChannelBuilder delegateChannelBuilder = ManagedChannelBuilder.forAddress(SPANNER_TARGET, 443);
GcpManagedChannelBuilder gcpBuilder = 
  GcpManagedChannelBuilder.forDelegateBuilder(delegateChannelBuilder)
                          .withApiConfigJsonFile(jsonApiConfig);
ManagedChannel gcpChannel = gcpBuilder.build();
```

Create Cloud API stub using `GcpManagedChannel`.

```java
GoogleCredentials creds = getCreds();
SpannerBlockingStub stub =
    SpannerGrpc.newBlockingStub(gcpChannel)
               .withCallCredentials(MoreCallCredentials.from(creds));
```

## Build from source

Download source.

```sh
git clone https://github.com/GoogleCloudPlatform/grpc-gcp-java.git && cd grpc-gcp-java/grpc-gcp
```

Build project with unit tests.

```sh
./gradlew build
```

## Test

Setup credentials. See [Getting Started With Authentication](https://cloud.google.com/docs/authentication/getting-started) for more details.

```sh
export GOOGLE_APPLICATION_CREDENTIALS=path/to/key.json
```

```sh
export GCP_PROJECT_ID=project_id
```

Run unit tests and integration tests:

```sh
./gradlew allTests
```

## Code Format

Run google-java-format

```sh
./gradlew goJF
```
