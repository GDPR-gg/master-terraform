# Google Cloud Storage Chef Cookbook

This cookbook provides the built-in types and services for Chef to manage
Google Cloud Storage resources, as native Chef types.

## Requirements

### Platforms

#### Supported Operating Systems

This cookbook was tested on the following operating systems:

* RedHat 6, 7
* CentOS 6, 7
* Debian 7, 8
* Ubuntu 12.04, 14.04, 16.04, 16.10
* SLES 11-sp4, 12-sp2
* openSUSE 13
* Windows Server 2008 R2, 2012 R2, 2012 R2 Core, 2016 R2, 2016 R2 Core

## Example

```ruby
gauth_credential 'mycred' do
  action :serviceaccount
  path ENV['CRED_PATH'] # e.g. '/path/to/my_account.json'
  scopes [
    'https://www.googleapis.com/auth/devstorage.full_control'
  ]
end

gstorage_bucket 'storage-bucket' do
  action :create
  project ENV['PROJECT'] # ex: 'my-test-project'
  credential 'mycred'
end
```

## Credentials

All Google Cloud Platform cookbooks use an unified authentication mechanism,
provided by the `google-gauth` cookbook. Don't worry, it is automatically
installed when you install this module.

### Example

```ruby
gauth_credential 'mycred' do
  action :serviceaccount
  path ENV['CRED_PATH'] # e.g. '/path/to/my_account.json'
  scopes [
    'https://www.googleapis.com/auth/devstorage.full_control'
  ]
end

```

For complete details of the authentication cookbook, visit the
[google-gauth][] cookbook documentation.

## Resources

* [`gstorage_bucket`](#gstorage_bucket) -
    The Buckets resource represents a bucket in Google Cloud Storage. There is
    a single global namespace shared by all buckets. For more information, see
    Bucket Name Requirements.
    Buckets contain objects which can be accessed by their own methods. In
    addition to the acl property, buckets contain bucketAccessControls, for
    use in fine-grained manipulation of an existing bucket's access controls.
    A bucket is always owned by the project team owners group.
* [`gstorage_bucket_access_control`](#gstorage_bucket_access_control) -
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
* [`gstorage_object_access_control`](#gstorage_object_access_control) -
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
* [`gstorage_default_object_acl`](#gstorage_default_object_acl) -
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


### gstorage_bucket
The Buckets resource represents a bucket in Google Cloud Storage. There is
a single global namespace shared by all buckets. For more information, see
Bucket Name Requirements.

Buckets contain objects which can be accessed by their own methods. In
addition to the acl property, buckets contain bucketAccessControls, for
use in fine-grained manipulation of an existing bucket's access controls.

A bucket is always owned by the project team owners group.


#### Example

```ruby
# This is a simple example of a bucket creation/ensure existence. If you want a
# more thorough setup of its ACL please refer to 'examples/bucket~acl.pp'
# manifest.
gstorage_bucket 'storage-module-test' do
  action :create
  project ENV['PROJECT'] # ex: 'my-test-project'
  credential 'mycred'
end

```

#### Reference

```ruby
gstorage_bucket 'id-for-resource' do
  acl                           [
    {
      bucket       reference to gstorage_bucket,
      domain       string,
      email        string,
      entity       string,
      entity_id    string,
      id           string,
      role         'OWNER', 'READER' or 'WRITER',
      project_team {
        team           'editors', 'owners' or 'viewers',
        project_number string,
      },
    },
    ...
  ]
  cors                          [
    {
      max_age_seconds integer,
      method          [
        string,
        ...
      ],
      origin          [
        string,
        ...
      ],
      response_header [
        string,
        ...
      ],
    },
    ...
  ]
  default_object_acl            [
    {
      bucket       reference to gstorage_bucket,
      domain       string,
      email        string,
      entity       string,
      entity_id    string,
      generation   integer,
      id           string,
      object       string,
      role         'OWNER' or 'READER',
      project_team {
        team           'editors', 'owners' or 'viewers',
        project_number string,
      },
    },
    ...
  ]
  id                            string
  lifecycle                     {
    rule [
      {
        action    {
          storage_class string,
          type          'Delete' or 'SetStorageClass',
        },
        condition {
          age_days              integer,
          created_before        time,
          is_live               boolean,
          matches_storage_class [
            string,
            ...
          ],
          num_newer_versions    integer,
        },
      },
      ...
    ],
  }
  location                      string
  logging                       {
    log_bucket        string,
    log_object_prefix string,
  }
  metageneration                integer
  name                          string
  owner                         {
    entity    string,
    entity_id string,
  }
  predefined_default_object_acl 'authenticatedRead', 'bucketOwnerFullControl', 'bucketOwnerRead', 'private', 'projectPrivate' or 'publicRead'
  storage_class                 'MULTI_REGIONAL', 'REGIONAL', 'STANDARD', 'NEARLINE', 'COLDLINE' or 'DURABLE_REDUCED_AVAILABILITY'
  time_created                  time
  updated                       time
  versioning                    {
    enabled boolean,
  }
  website                       {
    main_page_suffix string,
    not_found_page   string,
  }
  project_number                integer
  project                       string
  credential                    reference to gauth_credential
end
```

#### Actions

* `create` -
  Converges the `gstorage_bucket` resource into the final
  state described within the block. If the resource does not exist, Chef will
  attempt to create it.
* `delete` -
  Ensures the `gstorage_bucket` resource is not present.
  If the resource already exists Chef will attempt to delete it.

#### Properties

* `acl` -
  Access controls on the bucket.

* `acl[]/bucket`
  Required. The name of the bucket.

* `acl[]/domain`
  Output only. The domain associated with the entity.

* `acl[]/email`
  Output only. The email address associated with the entity.

* `acl[]/entity`
  Required. The entity holding the permission, in one of the following forms:
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

* `acl[]/entity_id`
  The ID for the entity

* `acl[]/id`
  Output only. The ID of the access-control entry.

* `acl[]/project_team`
  The project team associated with the entity

* `acl[]/project_team/project_number`
  The project team associated with the entity

* `acl[]/project_team/team`
  The team.

* `acl[]/role`
  The access permission for the entity.

* `cors` -
  The bucket's Cross-Origin Resource Sharing (CORS) configuration.

* `cors[]/max_age_seconds`
  The value, in seconds, to return in the Access-Control-Max-Age
  header used in preflight responses.

* `cors[]/method`
  The list of HTTP methods on which to include CORS response
  headers, (GET, OPTIONS, POST, etc) Note: "*" is permitted in the
  list of methods, and means "any method".

* `cors[]/origin`
  The list of Origins eligible to receive CORS response headers.
  Note: "*" is permitted in the list of origins, and means "any
  Origin".

* `cors[]/response_header`
  The list of HTTP headers other than the simple response headers
  to give permission for the user-agent to share across domains.

* `default_object_acl` -
  Default access controls to apply to new objects when no ACL is
  provided.

* `default_object_acl[]/bucket`
  Required. The name of the bucket.

* `default_object_acl[]/domain`
  Output only. The domain associated with the entity.

* `default_object_acl[]/email`
  Output only. The email address associated with the entity.

* `default_object_acl[]/entity`
  Required. The entity holding the permission, in one of the following forms:
  * user-{{userId}}
  * user-{{email}} (such as "user-liz@example.com")
  * group-{{groupId}}
  * group-{{email}} (such as "group-example@googlegroups.com")
  * domain-{{domain}} (such as "domain-example.com")
  * project-team-{{projectId}}
  * allUsers
  * allAuthenticatedUsers

* `default_object_acl[]/entity_id`
  Output only. The ID for the entity

* `default_object_acl[]/generation`
  Output only. The content generation of the object, if applied to an object.

* `default_object_acl[]/id`
  Output only. The ID of the access-control entry.

* `default_object_acl[]/object`
  The name of the object, if applied to an object.

* `default_object_acl[]/project_team`
  Output only. The project team associated with the entity

* `default_object_acl[]/project_team/project_number`
  The project team associated with the entity

* `default_object_acl[]/project_team/team`
  The team.

* `default_object_acl[]/role`
  Required. The access permission for the entity.

* `id` -
  Output only. The ID of the bucket. For buckets, the id and name properities are the
  same.

* `lifecycle` -
  The bucket's lifecycle configuration.
  See https://developers.google.com/storage/docs/lifecycle for more
  information.

* `lifecycle/rule`
  A lifecycle management rule, which is made of an action to take
  and the condition(s) under which the action will be taken.

* `lifecycle/rule[]/action`
  The action to take.

* `lifecycle/rule[]/action/storage_class`
  Target storage class. Required iff the type of the
  action is SetStorageClass.

* `lifecycle/rule[]/action/type`
  Type of the action. Currently, only Delete and
  SetStorageClass are supported.

* `lifecycle/rule[]/condition`
  The condition(s) under which the action will be taken.

* `lifecycle/rule[]/condition/age_days`
  Age of an object (in days). This condition is satisfied
  when an object reaches the specified age.

* `lifecycle/rule[]/condition/created_before`
  A date in RFC 3339 format with only the date part (for
  instance, "2013-01-15"). This condition is satisfied
  when an object is created before midnight of the
  specified date in UTC.

* `lifecycle/rule[]/condition/is_live`
  Relevant only for versioned objects.  If the value is
  true, this condition matches live objects; if the value
  is false, it matches archived objects.

* `lifecycle/rule[]/condition/matches_storage_class`
  Objects having any of the storage classes specified by
  this condition will be matched. Values include
  MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD,
  and DURABLE_REDUCED_AVAILABILITY.

* `lifecycle/rule[]/condition/num_newer_versions`
  Relevant only for versioned objects. If the value is N,
  this condition is satisfied when there are at least N
  versions (including the live version) newer than this
  version of the object.

* `location` -
  The location of the bucket. Object data for objects in the bucket
  resides in physical storage within this region. Defaults to US. See
  the developer's guide for the authoritative list.

* `logging` -
  The bucket's logging configuration, which defines the destination
  bucket and optional name prefix for the current bucket's logs.

* `logging/log_bucket`
  The destination bucket where the current bucket's logs should be
  placed.

* `logging/log_object_prefix`
  A prefix for log object names.

* `metageneration` -
  The metadata generation of this bucket.

* `name` -
  The name of the bucket

* `owner` -
  The owner of the bucket. This is always the project team's owner
  group.

* `owner/entity`
  The entity, in the form project-owner-projectId.

* `owner/entity_id`
  Output only. The ID for the entity.

* `project_number` -
  Output only. The project number of the project the bucket belongs to.

* `storage_class` -
  The bucket's default storage class, used whenever no storageClass is
  specified for a newly-created object. This defines how objects in the
  bucket are stored and determines the SLA and the cost of storage.
  Values include MULTI_REGIONAL, REGIONAL, STANDARD, NEARLINE, COLDLINE,
  and DURABLE_REDUCED_AVAILABILITY. If this value is not specified when
  the bucket is created, it will default to STANDARD. For more
  information, see storage classes.

* `time_created` -
  Output only. The creation time of the bucket in RFC 3339 format.

* `updated` -
  Output only. The modification time of the bucket in RFC 3339 format.

* `versioning` -
  The bucket's versioning configuration.

* `versioning/enabled`
  While set to true, versioning is fully enabled for this bucket.

* `website` -
  The bucket's website configuration, controlling how the service
  behaves when accessing bucket contents as a web site. See the Static
  Website Examples for more information.

* `website/main_page_suffix`
  If the requested object path is missing, the service will ensure
  the path has a trailing '/', append this suffix, and attempt to
  retrieve the resulting object. This allows the creation of
  index.html objects to represent directory pages.

* `website/not_found_page`
  If the requested object path is missing, and any mainPageSuffix
  object is missing, if applicable, the service will return the
  named object from this bucket as the content for a 404 Not Found
  result.

* `project` -
  A valid API project identifier.

* `predefined_default_object_acl` -
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

#### Label
Set the `b_label` property when attempting to set primary key
of this object. The primary key will always be referred to by the initials of
the resource followed by "_label"

### gstorage_bucket_access_control
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

```ruby
# Bucket Access Control requires a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource
gstorage_bucket_access_control 'user-nelsona@google.com' do
  action :create
  bucket 'storage-module-test'
  entity 'user-nelsona@google.com'
  role 'WRITER'
  project ENV['PROJECT'] # ex: 'my-test-project'
  credential 'mycred'
end

```

#### Reference

```ruby
gstorage_bucket_access_control 'id-for-resource' do
  bucket       reference to gstorage_bucket
  domain       string
  email        string
  entity       string
  entity_id    string
  id           string
  role         'OWNER', 'READER' or 'WRITER'
  project_team {
    team           'editors', 'owners' or 'viewers',
    project_number string,
  }
  project      string
  credential   reference to gauth_credential
end
```

#### Actions

* `create` -
  Converges the `gstorage_bucket_access_control` resource into the final
  state described within the block. If the resource does not exist, Chef will
  attempt to create it.
* `delete` -
  Ensures the `gstorage_bucket_access_control` resource is not present.
  If the resource already exists Chef will attempt to delete it.

#### Properties

* `bucket` -
  Required. The name of the bucket.

* `domain` -
  Output only. The domain associated with the entity.

* `email` -
  Output only. The email address associated with the entity.

* `entity` -
  Required. The entity holding the permission, in one of the following forms:
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

* `entity_id` -
  The ID for the entity

* `id` -
  Output only. The ID of the access-control entry.

* `project_team` -
  The project team associated with the entity

* `project_team/project_number`
  The project team associated with the entity

* `project_team/team`
  The team.

* `role` -
  The access permission for the entity.

#### Label
Set the `bac_label` property when attempting to set primary key
of this object. The primary key will always be referred to by the initials of
the resource followed by "_label"

### gstorage_object_access_control
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

```ruby
# Object Access Control requires a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource.  The object in question does not
# need to exist for the creation to succeed.
gstorage_object_access_control 'user-nelsona@google.com' do
  action :create
  bucket 'storage-module-test'
  object 'example-object-controlled-by-acl'
  entity 'user-nelsona@google.com'
  role 'WRITER'
  project 'google.com:graphite-playground'
  credential 'mycred'
end

```

#### Reference

```ruby
gstorage_object_access_control 'id-for-resource' do
  bucket       reference to gstorage_bucket
  domain       string
  email        string
  entity       string
  entity_id    string
  generation   integer
  id           string
  object       string
  role         'OWNER' or 'READER'
  project_team {
    team           'editors', 'owners' or 'viewers',
    project_number string,
  }
  project      string
  credential   reference to gauth_credential
end
```

#### Actions

* `create` -
  Converges the `gstorage_object_access_control` resource into the final
  state described within the block. If the resource does not exist, Chef will
  attempt to create it.
* `delete` -
  Ensures the `gstorage_object_access_control` resource is not present.
  If the resource already exists Chef will attempt to delete it.

#### Properties

* `bucket` -
  Required. The name of the bucket.

* `domain` -
  Output only. The domain associated with the entity.

* `email` -
  Output only. The email address associated with the entity.

* `entity` -
  Required. The entity holding the permission, in one of the following forms:
  * user-{{userId}}
  * user-{{email}} (such as "user-liz@example.com")
  * group-{{groupId}}
  * group-{{email}} (such as "group-example@googlegroups.com")
  * domain-{{domain}} (such as "domain-example.com")
  * project-team-{{projectId}}
  * allUsers
  * allAuthenticatedUsers

* `entity_id` -
  Output only. The ID for the entity

* `generation` -
  Output only. The content generation of the object, if applied to an object.

* `id` -
  Output only. The ID of the access-control entry.

* `object` -
  Required. The name of the object, if applied to an object.

* `project_team` -
  Output only. The project team associated with the entity

* `project_team/project_number`
  The project team associated with the entity

* `project_team/team`
  The team.

* `role` -
  Required. The access permission for the entity.

#### Label
Set the `oac_label` property when attempting to set primary key
of this object. The primary key will always be referred to by the initials of
the resource followed by "_label"

### gstorage_default_object_acl
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

```ruby
# Default Object ACL requires a bucket. Please ensure its existence with
# the gstorage_bucket { ... } resource
gstorage_default_object_acl 'user-nelsona@google.com' do
  action :create
  bucket 'storage-module-test'
  entity 'user-nelsona@google.com'
  role 'WRITER'
  project 'google.com:graphite-playground'
  credential 'mycred'
end

```

#### Reference

```ruby
gstorage_default_object_acl 'id-for-resource' do
  bucket       reference to gstorage_bucket
  domain       string
  email        string
  entity       string
  entity_id    string
  generation   integer
  id           string
  object       string
  role         'OWNER' or 'READER'
  project_team {
    team           'editors', 'owners' or 'viewers',
    project_number string,
  }
  project      string
  credential   reference to gauth_credential
end
```

#### Actions

* `create` -
  Converges the `gstorage_default_object_acl` resource into the final
  state described within the block. If the resource does not exist, Chef will
  attempt to create it.
* `delete` -
  Ensures the `gstorage_default_object_acl` resource is not present.
  If the resource already exists Chef will attempt to delete it.

#### Properties

* `bucket` -
  Required. The name of the bucket.

* `domain` -
  Output only. The domain associated with the entity.

* `email` -
  Output only. The email address associated with the entity.

* `entity` -
  Required. The entity holding the permission, in one of the following forms:
  * user-{{userId}}
  * user-{{email}} (such as "user-liz@example.com")
  * group-{{groupId}}
  * group-{{email}} (such as "group-example@googlegroups.com")
  * domain-{{domain}} (such as "domain-example.com")
  * project-team-{{projectId}}
  * allUsers
  * allAuthenticatedUsers

* `entity_id` -
  Output only. The ID for the entity

* `generation` -
  Output only. The content generation of the object, if applied to an object.

* `id` -
  Output only. The ID of the access-control entry.

* `object` -
  The name of the object, if applied to an object.

* `project_team` -
  Output only. The project team associated with the entity

* `project_team/project_number`
  The project team associated with the entity

* `project_team/team`
  The team.

* `role` -
  Required. The access permission for the entity.

#### Label
Set the `doa_label` property when attempting to set primary key
of this object. The primary key will always be referred to by the initials of
the resource followed by "_label"

[google-gauth]: https://supermarket.chef.io/cookbooks/google-gauth
