/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


output "feed_create" {
  description = "Feed gcloud command."
  value       = <<END
gcloud asset feeds create ${var.name} \
  --pubsub-topic ${google_pubsub_topic.feed_output.id} \
  --asset-types k8s.io/Namespace,container.googleapis.com/Cluster \
  --content-type resource \
  --organization ${var.org_id}
  END
}




