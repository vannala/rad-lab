/**
 * Copyright 2022 Google LLC
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

data "google_compute_network" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.network_name
}

data "google_compute_subnetwork" "default" {
  count   = var.create_network ? 0 : 1
  project = local.project.project_id
  name    = var.subnet_name
  region  = var.region
}

module "hpc_slurm_network" {
  count   = var.create_network ? 1 : 0
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id   = local.project.project_id
  network_name = format("%s-%s", var.network_name, local.random_id)
  routing_mode = "GLOBAL"
  description  = "VPC Network created via Terraform."

  subnets = [{
    subnet_name           = var.subnet_name
    subnet_region         = var.region
    subnet_ip             = var.ip_cidr_range
    description           = "Subnetwork inside the *HPC Slurm* network, created via Terraform."
    subnet_private_access = true
  }]

  depends_on = [
    google_project_service.enabled_services
  ]
}
