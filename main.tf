module "rg" {
  source       = "./modules/resource_group"
  project_name = var.project_name
  location     = var.location
  tags         = var.tags
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = module.rg.name
  location            = var.location
  address_space       = var.address_space
  project_name        = var.project_name
  tags                = var.tags
}

module "nsg" {
  source              = "./modules/nsg"
  resource_group_name = module.rg.name
  resource_group_id   = module.rg.id
  location            = var.location
  address_space       = var.address_space
  subnet_ids          = module.networking.subnet_ids
  tags                = var.tags
}

module "sql" {
  source              = "./modules/sql"
  resource_group_name = module.rg.name
  location            = var.location
  address_space       = var.address_space
  project_name        = var.project_name
  sql_allowed_subnet_ids = {
    web = module.networking.web_subnet_id
  }
  tags                = var.tags
}

module "appservice" {
  source              = "./modules/app_service"
  resource_group_name = module.rg.name
  location            = var.location
  address_space       = var.address_space
  project_name        = var.project_name
  web_subnet_id       = module.networking.web_subnet_id
  admin_ssh_public_key = var.vm_admin_ssh_public_key
  tags                = var.tags
}

module "github_runner" {
  source                    = "./modules/github_runner"
  project_name              = var.project_name
  resource_group_name       = module.rg.name
  location                  = var.location
  runner_subnet_id          = module.networking.runner_subnet_id
  admin_username            = var.runner_admin_username
  admin_ssh_public_key      = var.vm_admin_ssh_public_key
  runner_vm_size            = var.runner_vm_size
  github_repo_url           = var.github_repo_url
  runner_registration_token = var.runner_registration_token
  tags                      = var.tags
}

module "appgateway" {
  source              = "./modules/application_gateway"
  resource_group_name = module.rg.name
  location            = var.location
  address_space       = var.address_space
  project_name        = var.project_name
  app_gateway_subnet_id = module.networking.app_gateway_subnet_id
  backend_ip_addresses = [module.appservice.private_ip_address]
  tags                = var.tags
}

module "vpngateway" {
  source              = "./modules/vpn_gateway"
  resource_group_name = module.rg.name
  location            = var.location
  address_space       = var.address_space
  project_name        = var.project_name
  vnet_id             = module.networking.vnet_id
  gateway_subnet_id   = module.networking.gateway_subnet_id
  tags                = var.tags
}