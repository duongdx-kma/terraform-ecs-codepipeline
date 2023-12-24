variable username {
  type = string
}

variable db_name {
  type = string
}

variable subnet_ids {
  type = list(string)
}

variable rds_security_group_ids {
  type = list(string)
}

variable rds_credentials_key {
  type = string
}