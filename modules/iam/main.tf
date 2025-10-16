resource "google_service_account" "this" {
  account_id   = var.service_account.account_id
  display_name = var.service_account.display_name
  project      = var.project_id
}

resource "google_project_iam_member" "role_bindings" {
  for_each = toset(var.roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.this.email}"
}
