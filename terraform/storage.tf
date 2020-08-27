resource "google_storage_bucket" "backup" {
  name               = "backup-data-kefa-uk"
  location           = "europe-west2"
  bucket_policy_only = true
  versioning {
    enabled = true
  }
  storage_class      = "STANDARD"
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
      num_newer_versions = 1
    }
  }
  lifecycle_rule {
    action {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = 30
    }
  }
}

resource "google_service_account" "backup-runner-service-account" {
  account_id   = "backup-runner"
  display_name = "Service account for running backups"
}

resource "google_storage_bucket_iam_member" "backup-runner-binding" {
  bucket = google_storage_bucket.backup.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backup-runner-service-account.email}"
}
