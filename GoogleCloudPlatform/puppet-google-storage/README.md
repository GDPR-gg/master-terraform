# Google Cloud Storage Puppet Module

[![Puppet Forge](http://img.shields.io/puppetforge/v/google/gstorage.svg)](https://forge.puppetlabs.com/google/gstorage)

#### Table of Contents

1. [Module Description - What the module does and why it is useful](
    #module-description)
2. [Setup - The basics of getting started with Google Cloud Storage](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](
   #reference)
    - [Classes](#classes)
    - [Bolt Tasks](#bolt-tasks)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module Description

This Puppet module manages the resource of Google Cloud Storage.
You can manage its resources using standard Puppet DSL and the module will,
under the hood, ensure the state described will be reflected in the Google
Cloud Platform resources.

## Setup

To install this module on your Puppet Master (or Puppet Client/Agent), use the
Puppet module installer:

    puppet module install google-gstorage

Optionally you can install support to _all_ Google Cloud Platform products at
once by installing our "bundle" [`google-cloud`][bundle-forge] module:

    puppet module install google-cloud

Since this module depends on the `googleauth` and `google-api-client` gems,
you will also need to install those, with

    /opt/puppetlabs/puppet/bin/gem install googleauth google-api-client

If you prefer, you could also add the following to your puppet manifest:

		package { [
				'googleauth',
				'google-api-client',
			]:
				ensure   => present,
				provider => puppet_gem,
		}

## Usage

### Credentials

All Google Cloud Platform modules use an unified authentication mechanism,
provided by the [`google-gauth`][] module. Don't worry, it is automatically
installed when you install this module.

```puppet
gauth_credential { 'mycred':
  path     => $cred_path, # e.g. '/home/nelsonjr/my_account.json'
  provider => serviceaccount,
  scopes   => [
    'https://www.googleapis.com/auth/devstorage.full_control',
  ],
}
```

Please refer to the [`google-gauth`][] module for further requirements, i.e.
required gems.

### Examples

#### `gstorage_bucket`

```puppet
# This is a simple example of a bucket creation/ensure existence. If you want a
# more thorough setup of its ACL please refer to 'examples/bucket~acl.pp'
# manifest.
gstorage_bucket { 'puppet-storage-module-test':
  ensure     => present,
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### `gstorage_bucket_access_control`

```puppet
# Bucket Access Control requires a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource
gstorage_bucket_access_control { 'user-nelsona@google.com':
  bucket     => 'puppet-storage-module-test',
  entity     => 'user-nelsona@google.com',
  role       => 'WRITER',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### `gstorage_object_access_control`

```puppet
# Object Access Control requires a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource.  The object does not have to exist.
gstorage_object_access_control { 'user-nelsona@google.com':
  bucket     => 'puppet-storage-module-test',
  object     => 'acl-controlled-file.txt'
  entity     => 'user-nelsona@google.com',
  role       => 'WRITER',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### `gstorage_default_object_acl`

```puppet
# Default Object ACLs require a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource
gstorage_default_object_acl { 'user-nelsona@google.com':
  bucket     => 'puppet-storage-module-test',
  entity     => 'user-nelsona@google.com',
  role       => 'READER',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```


### Classes

#### Public classes

* [`gstorage_bucket`][]:
    The Buckets resource represents a bucket in Google Cloud Storage. There is
    a single global namespace shared by all buckets. For more information, see
    Bucket Name Requirements.
    Buckets contain objects which can be accessed by their own methods. In
    addition to the acl property, buckets contain bucketAccessControls, for
    use in fine-grained manipulation of an existing bucket's access controls.
    A bucket is always owned by the project team owners group.
* [`gstorage_bucket_access_control`][]:
    The BucketAccessControls resource represents the Access Control Lists
    (ACLs) for buckets within Google Cloud Storage. ACLs let you specify who
    has access to your data and to what extent.
    There are three roles that can be assigned to an entity:
    READERs can get the bucket, though no acl property will be returned, and
    list the bucket's objects.  WRITERs are READERs, and they can insert
    objects into the bucket and delete the bucket's objects.  OWNERs are
    WRITERs, and they can get the acl property of a bucket, update a bucket,
    and call all BucketAccessControls methods on the bucket.  For more
    information, see Access Control, with the caveat that this API uses
    READER, WRITER, and OWNER instead of READ, WRITE, and FULL_CONTROL.
* [`gstorage_object_access_control`][]:
    The ObjectAccessControls resources represent the Access Control Lists
    (ACLs) for objects within Google Cloud Storage. ACLs let you specify
    who has access to your data and to what extent.
    There are two roles that can be assigned to an entity:
    READERs can get an object, though the acl property will not be revealed.
    OWNERs are READERs, and they can get the acl property, update an object,
    and call all objectAccessControls methods on the object. The owner of an
    object is always an OWNER.
    For more information, see Access Control, with the caveat that this API
    uses READER and OWNER instead of READ and FULL_CONTROL.
* [`gstorage_default_object_acl`][]:
    The ObjectAccessControls resources represent the Access Control Lists
    (ACLs) for objects within Google Cloud Storage. ACLs let you specify
    who has access to your data and to what extent.
    There are two roles that can be assigned to an entity:
    READERs can get an object, though the acl property will not be revealed.
    OWNERs are READERs, and they can get the acl property, update an object,
    and call all objectAccessControls methods on the object. The owner of an
    object is always an OWNER.
    For more information, see Access Control, with the caveat that this API
    uses READER and OWNER instead of READ and FULL_CONTROL.

### About output only properties

Some fields are output-only. It means you cannot set them because they are
provided by the Google Cloud Platform. Yet they are still useful to ensure the
value the API is assigning (or has assigned in the past) is still the value you
expect.

For example in a DNS the name servers are assigned by the Google Cloud DNS
service. Checking these values once created is useful to make sure your upstream
and/or root DNS masters are in sync.  Or if you decide to use the object ID,
e.g. the VM unique ID, for billing purposes. If the VM gets deleted and
recreated it will have a different ID, despite the name being the same. If that
detail is important to you you can verify that the ID of the object did not
change by asserting it in the manifest.

### Parameters

#### `gstorage_bucket`

The Buckets resource represents a bucket in Google Cloud Storage. There is
a single global namespace shared by all buckets. For more information, see
Bucket Name Requirements.

Buckets contain objects which can be accessed by their own methods. In
addition to the acl property, buckets contain bucketAccessControls, for
use in fine-grained manipulation of an existing bucket's access controls.

A bucket is always owned by the project team owners group.


#### Example

```puppet
# This is a simple example of a bucket creation/ensure existence. If you want a
# more thorough setup of its ACL please refer to 'examples/bucket~acl.pp'
# manifest.
gstorage_bucket { 'puppet-storage-module-test':
  ensure     => present,
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### Reference

```puppet
gstorage_bucket { 'id-of-resource':
  acl                           => [
    {
      bucket       => reference to gstorage_bucket,
      domain       => string,
      email        => string,
      entity       => string,
      entity_id    => string,
      id           => string,
      role         => 'OWNER', 'READER' or 'WRITER',
      project_team => {
        team           => 'editors', 'owners' or 'viewers',
        project_number => string,
      },
    },
    ...
  ],
  cors                          => [
    {
      max_age_seconds => integer,
      method          => [
        string,
        ...
      ],
      origin          => [
        string,
        ...
      ],
      response_header => [
        string,
        ...
      ],
    },
    ...
  ],
  default_object_acl            => [
    {
      bucket       => reference to gstorage_bucket,
      domain       => string,
      email        => string,
      entity       => string,
      entity_id    => string,
      generation   => integer,
      id           => string,
      object       => string,
      role         => 'OWNER' or 'READER',
      project_team => {
        team           => 'editors', 'owners' or 'viewers',
        project_number => string,
      },
    },
    ...
  ],
  id                            => string,
  lifecycle                     => {
    rule => [
      {
        action    => {
          storage_class => string,
          type          => 'Delete' or 'SetStorageClass',
        },
        condition => {
          age_days              => integer,
          created_before        => time,
          is_live               => boolean,
          matches_storage_class => [
            string,
            ...
          ],
          num_newer_versions    => integer,
        },
      },
      ...
    ],
  },
  location                      => string,
  logging                       => {
    log_bucket        => string,
    log_object_prefix => string,
  },
  metageneration                => integer,
  name                          => string,
  owner                         => {
    entity    => string,
    entity_id => string,
  },
  predefined_default_object_acl => 'authenticatedRead', 'bucketOwnerFullControl', 'bucketOwnerRead', 'private', 'projectPrivate' or 'publicRead',
  storage_class                 => 'MULTI_REGIONAL', 'REGIONAL', 'STANDARD', 'NEARLINE', 'COLDLINE' or 'DURABLE_REDUCED_AVAILABILITY',
  time_created                  => time,
  updated                       => time,
  versioning                    => {
    enabled => boolean,
  },
  website                       => {
    main_page_suffix => string,
    not_found_page   => string,
  },
  project_number                => integer,
  project                       => string,
  credential                    => reference to gauth_credential,
}
```

##### `acl`

  Access controls on the bucket.

##### acl[]/bucket
Required.  The name of the bucket.

##### acl[]/domain
Output only.  The domain associated with the entity.

##### acl[]/email
Output only.  The email address associated with the entity.

##### acl[]/entity
Required.  The entity holding the permission, in one of the following forms:
  user-userId
  user-email
  group-groupId
  group-email
  domain-domain
  project-team-projectId
  allUsers
  allAuthenticatedUsers
  Examples:
  The user liz@example.com would be user-liz@example.com.
  The group example@googlegroups.com would be
  group-example@googlegroups.com.
  To refer to all members of the Google Apps for Business domain
  example.com, the entity would be domain-example.com.

##### acl[]/entity_id
  The ID for the entity

##### acl[]/id
Output only.  The ID of the access-control entry.

##### acl[]/project_team
  The project team associated with the entity

##### acl[]/project_team/project_number
  The project team associated with the entity

##### acl[]/project_team/team
  The team.

##### acl[]/role
  The access permission for the entity.

##### `cors`

  The bucket's Cross-Origin Resource Sharing (CORS) configuration.

##### cors[]/max_age_seconds
  The value, in seconds, to return in the Access-Control-Max-Age
  header used in preflight responses.

##### cors[]/method
  The list of HTTP methods on which to include CORS response
  headers, (GET, OPTIONS, POST, etc) Note: "*" is permitted in the
  list of methods, and means "any method".

##### cors[]/origin
  The list of Origins eligible to receive CORS response headers.
  Note: "*" is permitted in the list of origins, and means "any
  Origin".

##### cors[]/response_header
  The list of HTTP headers other than the simple response headers
  to give permission for the user-agent to share across domains.

##### `default_object_acl`

  Default access controls to apply to new objects when no ACL is
  provided.

##### default_object_acl[]/bucket
Required.  The name of the bucket.

##### default_object_acl[]/domain
Output only.  The domain associated with the entity.

##### default_object_acl[]/email
Output only.  The email address associated with the entity.

##### default_object_acl[]/entity
Required.  The entity holding the permission, in one of the following forms:
  * user-{{userId}}
  * user-{{email}} (such as "user-liz@example.com")
  * group-{{groupId}}
  * group-{{email}} (such as "group-example@googlegroups.com")
  * domain-{{domain}} (such as "domain-example.com")
  * project-team-{{projectId}}
  * allUsers
  * allAuthenticatedUsers

##### default_object_acl[]/entity_id
Output only.  The ID for the entity

##### default_object_acl[]/generation
Output only.  The content generation of the object, if applied to an object.

##### default_object_acl[]/id
Output only.  The ID of the access-control entry.

##### default_object_acl[]/object
  The name of the object, if applied to an object.

##### default_object_acl[]/project_team
Output only.  The project team associated with the entity

##### default_object_acl[]/project_team/project_number
  The project team associated with the entity

##### default_object_acl[]/project_team/team
  The team.

##### default_object_acl[]/role
Required.  The access permission for the entity.

##### `lifecycle`

  The bucket's lifecycle configuration.
  See https://developers.google.com/storage/docs/lifecycle for more
  information.

##### lifecycle/rule
  A lifecycle management rule, which is made of an action to take
  and the condition(s) under which the action will be taken.

##### lifecycle/rule[]/action
  The action to take.

##### lifecycle/rule[]/action/storage_class
  Target storage class. Required iff the type of the
  action is SetStorageClass.

##### lifecycle/rule[]/action/type
  Type of the action. Currently, only Delete and
  SetStorageClass are supported.

##### lifecycle/rule[]/condition
  The condition(s) under which the action will be taken.

##### lifecycle/rule[]/condition/age_days
  Age of an object (in days). This condition is satisfied
  when an object reaches the specified age.

##### lifecycle/rule[]/condition/created_before
  A date in RFC 3339 format with only the date part (for
  instance, "2013-01-15"). This condition is satisfied
  when an object is created before midnight of the
  specified date in UTC.

##### lifecycle/rule[]/condition/is_live
  Relevant only for versioned objects.  If the value is
  true, this condition matches live objects; if the value
  is false, it matches archived objects.

##### lifecycle/rule[]/condition/matches_storage_class
  Objects having any of the storage classes specified by
  this condition will be matched. Values include
  MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD,
  and DURABLE_REDUCED_AVAILABILITY.

##### lifecycle/rule[]/condition/num_newer_versions
  Relevant only for versioned objects. If the value is N,
  this condition is satisfied when there are at least N
  versions (including the live version) newer than this
  version of the object.

##### `location`

  The location of the bucket. Object data for objects in the bucket
  resides in physical storage within this region. Defaults to US. See
  the developer's guide for the authoritative list.

##### `logging`

  The bucket's logging configuration, which defines the destination
  bucket and optional name prefix for the current bucket's logs.

##### logging/log_bucket
  The destination bucket where the current bucket's logs should be
  placed.

##### logging/log_object_prefix
  A prefix for log object names.

##### `metageneration`

  The metadata generation of this bucket.

##### `name`

  The name of the bucket

##### `owner`

  The owner of the bucket. This is always the project team's owner
  group.

##### owner/entity
  The entity, in the form project-owner-projectId.

##### owner/entity_id
Output only.  The ID for the entity.

##### `storage_class`

  The bucket's default storage class, used whenever no storageClass is
  specified for a newly-created object. This defines how objects in the
  bucket are stored and determines the SLA and the cost of storage.
  Values include MULTI_REGIONAL, REGIONAL, STANDARD, NEARLINE, COLDLINE,
  and DURABLE_REDUCED_AVAILABILITY. If this value is not specified when
  the bucket is created, it will default to STANDARD. For more
  information, see storage classes.

##### `versioning`

  The bucket's versioning configuration.

##### versioning/enabled
  While set to true, versioning is fully enabled for this bucket.

##### `website`

  The bucket's website configuration, controlling how the service
  behaves when accessing bucket contents as a web site. See the Static
  Website Examples for more information.

##### website/main_page_suffix
  If the requested object path is missing, the service will ensure
  the path has a trailing '/', append this suffix, and attempt to
  retrieve the resulting object. This allows the creation of
  index.html objects to represent directory pages.

##### website/not_found_page
  If the requested object path is missing, and any mainPageSuffix
  object is missing, if applicable, the service will return the
  named object from this bucket as the content for a 404 Not Found
  result.

##### `project`

  A valid API project identifier.

##### `predefined_default_object_acl`

  Apply a predefined set of default object access controls to this
  bucket.
  Acceptable values are:
  - "authenticatedRead": Object owner gets OWNER access, and
  allAuthenticatedUsers get READER access.
  - "bucketOwnerFullControl": Object owner gets OWNER access, and
  project team owners get OWNER access.
  - "bucketOwnerRead": Object owner gets OWNER access, and project
  team owners get READER access.
  - "private": Object owner gets OWNER access.
  - "projectPrivate": Object owner gets OWNER access, and project team
  members get access according to their roles.
  - "publicRead": Object owner gets OWNER access, and allUsers get
  READER access.


##### Output-only properties

* `id`: Output only.
  The ID of the bucket. For buckets, the id and name properities are the
  same.

* `project_number`: Output only.
  The project number of the project the bucket belongs to.

* `time_created`: Output only.
  The creation time of the bucket in RFC 3339 format.

* `updated`: Output only.
  The modification time of the bucket in RFC 3339 format.

#### `gstorage_bucket_access_control`

The BucketAccessControls resource represents the Access Control Lists
(ACLs) for buckets within Google Cloud Storage. ACLs let you specify who
has access to your data and to what extent.

There are three roles that can be assigned to an entity:

READERs can get the bucket, though no acl property will be returned, and
list the bucket's objects.  WRITERs are READERs, and they can insert
objects into the bucket and delete the bucket's objects.  OWNERs are
WRITERs, and they can get the acl property of a bucket, update a bucket,
and call all BucketAccessControls methods on the bucket.  For more
information, see Access Control, with the caveat that this API uses
READER, WRITER, and OWNER instead of READ, WRITE, and FULL_CONTROL.


#### Example

```puppet
# Bucket Access Control requires a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource
gstorage_bucket_access_control { 'user-nelsona@google.com':
  bucket     => 'puppet-storage-module-test',
  entity     => 'user-nelsona@google.com',
  role       => 'WRITER',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### Reference

```puppet
gstorage_bucket_access_control { 'id-of-resource':
  bucket       => reference to gstorage_bucket,
  domain       => string,
  email        => string,
  entity       => string,
  entity_id    => string,
  id           => string,
  role         => 'OWNER', 'READER' or 'WRITER',
  project_team => {
    team           => 'editors', 'owners' or 'viewers',
    project_number => string,
  },
  project      => string,
  credential   => reference to gauth_credential,
}
```

##### `bucket`

Required.  The name of the bucket.

##### `entity`

Required.  The entity holding the permission, in one of the following forms:
  user-userId
  user-email
  group-groupId
  group-email
  domain-domain
  project-team-projectId
  allUsers
  allAuthenticatedUsers
  Examples:
  The user liz@example.com would be user-liz@example.com.
  The group example@googlegroups.com would be
  group-example@googlegroups.com.
  To refer to all members of the Google Apps for Business domain
  example.com, the entity would be domain-example.com.

##### `entity_id`

  The ID for the entity

##### `project_team`

  The project team associated with the entity

##### project_team/project_number
  The project team associated with the entity

##### project_team/team
  The team.

##### `role`

  The access permission for the entity.


##### Output-only properties

* `domain`: Output only.
  The domain associated with the entity.

* `email`: Output only.
  The email address associated with the entity.

* `id`: Output only.
  The ID of the access-control entry.

#### `gstorage_object_access_control`

The ObjectAccessControls resources represent the Access Control Lists
(ACLs) for objects within Google Cloud Storage. ACLs let you specify
who has access to your data and to what extent.

There are two roles that can be assigned to an entity:

READERs can get an object, though the acl property will not be revealed.
OWNERs are READERs, and they can get the acl property, update an object,
and call all objectAccessControls methods on the object. The owner of an
object is always an OWNER.
For more information, see Access Control, with the caveat that this API
uses READER and OWNER instead of READ and FULL_CONTROL.

#### Reference Guides
* [API Reference](https://cloud.google.com/storage/docs/json_api/v1/objectAccessControls)
* [Official Documentation](https://cloud.google.com/storage/docs/access-control/create-manage-lists)

#### Example

```puppet
# Object Access Control requires a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource.  The object does not have to exist.
gstorage_object_access_control { 'user-nelsona@google.com':
  bucket     => 'puppet-storage-module-test',
  object     => 'acl-controlled-file.txt'
  entity     => 'user-nelsona@google.com',
  role       => 'WRITER',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### Reference

```puppet
gstorage_object_access_control { 'id-of-resource':
  bucket       => reference to gstorage_bucket,
  domain       => string,
  email        => string,
  entity       => string,
  entity_id    => string,
  generation   => integer,
  id           => string,
  object       => string,
  role         => 'OWNER' or 'READER',
  project_team => {
    team           => 'editors', 'owners' or 'viewers',
    project_number => string,
  },
  project      => string,
  credential   => reference to gauth_credential,
}
```

##### `bucket`

Required.  The name of the bucket.

##### `entity`

Required.  The entity holding the permission, in one of the following forms:
  * user-{{userId}}
  * user-{{email}} (such as "user-liz@example.com")
  * group-{{groupId}}
  * group-{{email}} (such as "group-example@googlegroups.com")
  * domain-{{domain}} (such as "domain-example.com")
  * project-team-{{projectId}}
  * allUsers
  * allAuthenticatedUsers

##### `object`

Required.  The name of the object, if applied to an object.

##### `role`

Required.  The access permission for the entity.


##### Output-only properties

* `domain`: Output only.
  The domain associated with the entity.

* `email`: Output only.
  The email address associated with the entity.

* `entity_id`: Output only.
  The ID for the entity

* `generation`: Output only.
  The content generation of the object, if applied to an object.

* `id`: Output only.
  The ID of the access-control entry.

* `project_team`: Output only.
  The project team associated with the entity

##### project_team/project_number
  The project team associated with the entity

##### project_team/team
  The team.

#### `gstorage_default_object_acl`

The ObjectAccessControls resources represent the Access Control Lists
(ACLs) for objects within Google Cloud Storage. ACLs let you specify
who has access to your data and to what extent.

There are two roles that can be assigned to an entity:

READERs can get an object, though the acl property will not be revealed.
OWNERs are READERs, and they can get the acl property, update an object,
and call all objectAccessControls methods on the object. The owner of an
object is always an OWNER.
For more information, see Access Control, with the caveat that this API
uses READER and OWNER instead of READ and FULL_CONTROL.


#### Example

```puppet
# Default Object ACLs require a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource
gstorage_default_object_acl { 'user-nelsona@google.com':
  bucket     => 'puppet-storage-module-test',
  entity     => 'user-nelsona@google.com',
  role       => 'READER',
  project    => $project, # e.g. 'my-test-project'
  credential => 'mycred',
}

```

#### Reference

```puppet
gstorage_default_object_acl { 'id-of-resource':
  bucket       => reference to gstorage_bucket,
  domain       => string,
  email        => string,
  entity       => string,
  entity_id    => string,
  generation   => integer,
  id           => string,
  object       => string,
  role         => 'OWNER' or 'READER',
  project_team => {
    team           => 'editors', 'owners' or 'viewers',
    project_number => string,
  },
  project      => string,
  credential   => reference to gauth_credential,
}
```

##### `bucket`

Required.  The name of the bucket.

##### `entity`

Required.  The entity holding the permission, in one of the following forms:
  * user-{{userId}}
  * user-{{email}} (such as "user-liz@example.com")
  * group-{{groupId}}
  * group-{{email}} (such as "group-example@googlegroups.com")
  * domain-{{domain}} (such as "domain-example.com")
  * project-team-{{projectId}}
  * allUsers
  * allAuthenticatedUsers

##### `object`

  The name of the object, if applied to an object.

##### `role`

Required.  The access permission for the entity.


##### Output-only properties

* `domain`: Output only.
  The domain associated with the entity.

* `email`: Output only.
  The email address associated with the entity.

* `entity_id`: Output only.
  The ID for the entity

* `generation`: Output only.
  The content generation of the object, if applied to an object.

* `id`: Output only.
  The ID of the access-control entry.

* `project_team`: Output only.
  The project team associated with the entity

##### project_team/project_number
  The project team associated with the entity

##### project_team/team
  The team.


### Bolt Tasks


#### `tasks/upload.rb`

  Uploads a local file to Google Cloud Storage

This task takes inputs as JSON from standard input.

##### Arguments

  - `name`:
    The name of the remote file to upload

  - `type`:
    The type of the remote file (in MIME notation) (default: 'application/octet-stream')

  - `source`:
    The path to a local file to upload

  - `bucket`:
    The target bucket to write the file to

  - `project`:
    The project that owns the bucket

  - `credential`:
    Path to a service account credentials file


## Limitations

This module has been tested on:

* RedHat 6, 7
* CentOS 6, 7
* Debian 7, 8
* Ubuntu 12.04, 14.04, 16.04, 16.10
* SLES 11-sp4, 12-sp2
* openSUSE 13
* Windows Server 2008 R2, 2012 R2, 2012 R2 Core, 2016 R2, 2016 R2 Core

Testing on other platforms has been minimal and cannot be guaranteed.

## Development

### Automatically Generated Files

Some files in this package are automatically generated by
[Magic Modules][magic-modules].

We use a code compiler to produce this module in order to avoid repetitive tasks
and improve code quality. This means all Google Cloud Platform Puppet modules
use the same underlying authentication, logic, test generation, style checks,
etc.

Learn more about the way to change autogenerated files by reading the
[CONTRIBUTING.md][] file.

### Contributing

Contributions to this library are always welcome and highly encouraged.

See [CONTRIBUTING.md][] for more information on how to get
started.

### Running tests

This project contains tests for [rspec][], [rspec-puppet][] and [rubocop][] to
verify functionality. For detailed information on using these tools, please see
their respective documentation.

#### Testing quickstart: Ruby > 2.0.0

```
gem install bundler
bundle install
bundle exec rspec
bundle exec rubocop
```

#### Debugging Tests

In case you need to debug tests in this module you can set the following
variables to increase verbose output:

Variable                | Side Effect
------------------------|---------------------------------------------------
`PUPPET_HTTP_VERBOSE=1` | Prints network access information by Puppet provier.
`PUPPET_HTTP_DEBUG=1`   | Prints the payload of network calls being made.
`GOOGLE_HTTP_VERBOSE=1` | Prints debug related to the network calls being made.
`GOOGLE_HTTP_DEBUG=1`   | Prints the payload of network calls being made.

During test runs (using [rspec][]) you can also set:

Variable                | Side Effect
------------------------|---------------------------------------------------
`RSPEC_DEBUG=1`         | Prints debug related to the tests being run.
`RSPEC_HTTP_VERBOSE=1`  | Prints network expectations and access.

[magic-modules]: https://github.com/GoogleCloudPlatform/magic-modules
[CONTRIBUTING.md]: CONTRIBUTING.md
[bundle-forge]: https://forge.puppet.com/google/cloud
[`google-gauth`]: https://github.com/GoogleCloudPlatform/puppet-google-auth
[rspec]: http://rspec.info/
[rspec-puppet]: http://rspec-puppet.com/
[rubocop]: https://rubocop.readthedocs.io/en/latest/
[`gstorage_bucket`]: #gstorage_bucket
[`gstorage_bucket_access_control`]: #gstorage_bucket_access_control
[`gstorage_object_access_control`]: #gstorage_object_access_control
[`gstorage_default_object_acl`]: #gstorage_default_object_acl
