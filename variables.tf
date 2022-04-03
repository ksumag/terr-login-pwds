variable "DO_token" {
    description = "loggin in DO"
    type = string
    
} 

variable "DO_RSA_rebrain" {
    description = "rebrain access key"
    type = string
    
} 

variable "my_DO_rsa" {
    description = "my access key"
    type = string
    
} 

variable "my-access-key" {
    description = "accsess AWS"
    type = string
    
} 
variable "my-secret-key" {
    description = "secret AWS"
    type = string
    
} 

variable "login" {
  description = "VPS login"
    type = string
}
variable "my_private" {
  description = "my private key"
    type = string
}
variable "devs" {
  type    = list
  default = ["dymon_ksu_at_gmail_com-proxy", "dymon_ksu_at_gmail_com-app2", "dymon_ksu_at_gmail_com-app1", "dymon_ksu_at_gmail_com-db", "dymon_ksu_at_gmail_com-lb" ]
}
variable "region" {
  type = string
}