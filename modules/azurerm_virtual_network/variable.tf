variable "virtual_network_name" {
    type = string
    }

    variable "virtual_network_location" {
        type = string
    }

    variable "address_space" {
        type = list(string)
    }

    variable "resource_group_name" {
        type = string
}