data "azurerm_resource_group" "udacity" {
  name     = "Regroup_8yq8EI3apd"
}

resource "azurerm_container_group" "udacity" {
  name                = "udacity-continst"
  location            = data.azurerm_resource_group.udacity.location
  resource_group_name = data.azurerm_resource_group.udacity.name
  ip_address_type     = "Public"
  dns_name_label      = "udacity-ali-azure"
  os_type             = "Linux"

  container {
    name   = "azure-container-app"
    image  = "docker.io/tscotto5/azure_app:1.0"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      "AWS_S3_BUCKET"       = "udacity-ali-aws-s3-bucket",
      "AWS_DYNAMO_INSTANCE" = "udacity-ali-aws-dynamodb"
    }
    ports {
      port     = 3000
      protocol = "TCP"
    }
  }
  tags = {
    environment = "udacity"
  }
}

####### Your Additions Will Start Here ######

# Azure SQL Server — referenced by the AWS ECS app as AZURE_SQL_SERVER
resource "azurerm_mssql_server" "udacity" {
  name                         = "udacity-ali-azure-sql"
  resource_group_name          = data.azurerm_resource_group.udacity.name
  location                     = data.azurerm_resource_group.udacity.location
  version                      = "12.0"
  administrator_login          = "udacity"
  administrator_login_password = "Azure#2024Cloud!"

  tags = {
    environment = "udacity"
  }
}

resource "azurerm_mssql_database" "udacity" {
  name      = "udacity-db"
  server_id = azurerm_mssql_server.udacity.id
  sku_name  = "Basic"

  tags = {
    environment = "udacity"
  }
}

# Dotnet Container App — referenced by the AWS ECS app as AZURE_DOTNET_APP
# Using a Container Instance instead of App Service (App Service quota is restricted in the Udacity lab)
resource "azurerm_container_group" "dotnet_app" {
  name                = "udacity-ali-azure-dotnet-app"
  location            = data.azurerm_resource_group.udacity.location
  resource_group_name = data.azurerm_resource_group.udacity.name
  ip_address_type     = "Public"
  dns_name_label      = "udacity-ali-dotnet"
  os_type             = "Linux"

  container {
    name   = "dotnet-app"
    image  = "mcr.microsoft.com/dotnet/samples:aspnetapp"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  tags = {
    environment = "udacity"
  }
}
