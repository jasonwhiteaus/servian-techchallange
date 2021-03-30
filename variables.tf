variable "tc_dbusername" {
    default = "potsgres"
}

variable "tc_dbname" {
    default = "techchallenge"
}

variable "tc_dbport" {
    default = "5432"
}

variable "tc_rds_multiazdeployment" {
    default = true
}

variable "tc_ssm_keylocation" {
    default = "/tc/database/password/master"
}