resource "google_sql_database_instance" "database" {
  name             = "database-${random_id.database_postfix.hex}"
  database_version = "POSTGRES_11"
  region           = "us-central1"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}


resource "random_id" "database_postfix" {
  byte_length = 4
}


resource "google_sql_database" "website" {
  name     = "website"
  instance = google_sql_database_instance.database.name
}

resource "google_sql_user" "admin" {
  name     = "admin"
  instance = google_sql_database_instance.database.name
  password = random_password.password.result
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

output "admin_password" {
  value = google_sql_user.admin.password
}