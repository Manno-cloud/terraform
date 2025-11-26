variable "vpc_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "security_groups" {
  description = "複数の SG（本体のみ）を作る"
  type = map(object({
    description = string
    # ルールはモジュール外で作るので不要
  }))
}