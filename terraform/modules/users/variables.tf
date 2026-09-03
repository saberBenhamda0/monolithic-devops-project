variable "users" {
  type = map(object({
    given_name   = string
    family_name  = string
    display_name = string
    user_name    = string
    email        = string
  }))

  description = "A map containing user properties"
}

/*
users = {
  user1 = {
    given_name   = "John"
    family_name  = "Doe"
    display_name = "John Doe"
    user_name    = "johndoe"
    email        = "john.doe@example.com"
  }

  user2 = {
    given_name   = "Jane"
    family_name  = "Smith"
    display_name = "Jane Smith"
    user_name    = "janesmith"
    email        = "jane.smith@example.com"
  }
}
*/