# Terraform AWS Infrastructure Portfolio

本リポジトリは、Terraform と GitHub Actions を用いて  
AWS 上に本番想定の Web アプリケーション基盤を Terraform により IaC 化したポートフォリオです。  
設計・構築・運用・CI/CD・証明書・DNS・CDN までを一通り網羅しており、  
IaC + 承認制デプロイで再現しています。

コスト最適化のため、通常時は `terraform destroy` 済みとしており、  
必要に応じていつでもフル環境を再構築できる構成になっています。

---

## 🏗️ 構成概要

### クラウド / IaC
- クラウド: **AWS（ap-northeast-1 / Tokyo）**
- Infrastructure as Code: **Terraform**
- ステート管理: **S3 Backend + DynamoDB Lock**

### CI/CD
- **GitHub Actions**
- **OIDC（AssumeRole による一時認証）**
- **PR 時：terraform plan 自動実行 + コメント出力**
- **main マージ後：GitHub Environments 承認制 terraform apply**

### ネットワーク
- **VPC（3AZ）**
- **Public / Private Subnet 分離**
- **Internet Gateway / NAT Gateway**
- **VPC Endpoint（ECR / Logs）**

### コンピュート
- **ECS Fargate（コンテナ Web アプリケーション）**
- **EC2 + Auto Scaling Group（VM ベース Web アプリケーション）**
- **ECR（Docker イメージ管理）**

### ロードバランシング / CDN
- **Application Load Balancer（ECS / EC2 両対応）**
- **CloudFront**
- **S3（OAC + Public Access Block）**

### データベース
- **RDS（MySQL）**

### DNS / 証明書
- **Route53**
- **ACM（ap-northeast-1 / us-east-1）**

### セキュリティ
- **AWS WAF（CloudFront / ALB に適用）**
- **IAM（最小権限設計）**
- **Security Group による通信制御**
- **SSM Parameter Store（SecureString による機密情報管理）**

### 監視 / 運用
- **CloudWatch Alarms**
  - ALB 5xx
  - ECS CPU
  - RDS CPU
- **SNS 通知連携**

---

## 📁 ディレクトリ構成

```text
.
├── .github/
│   └── workflows/
│       └── terraform.yml        # Terraform CI/CD（Plan / Apply 承認制）

├── modules/
│   ├── acm/                     # ACM（Tokyo / us-east-1）
│   ├── alb/                     # Application Load Balancer
│   ├── asg/                     # Auto Scaling Group
│   ├── cdn/                     # CloudFront
│   ├── ec2/                     # EC2（Web 用）
│   ├── ecr/                     # Elastic Container Registry
│   ├── ecs/                     # ECS Fargate
│   ├── iam/                     # IAM Role / Instance Profile
│   ├── monitoring/              # CloudWatch Alarm
│   ├── rds/                     # RDS MySQL
│   ├── route53/                 # Route53 DNS
│   ├── s3/                      # S3（CDN Origin）
│   ├── security_group/          # Security Group
│   ├── sns/                     # SNS 通知
│   ├── ssm/                     # SSM Parameter Store
│   ├── vpc/                     # VPC / Subnet / NAT / IGW
│   └── waf/                     # AWS WAF

├── vpc_endpoint/                # VPC Endpoint（ECR / Logs）

├── backend.tf                   # Terraform Backend（S3 + DynamoDB）
├── main.tf                      # ルートモジュール
├── variables.tf                 # 共通変数定義
├── outputs.tf                   # 共通 Outputs
├── terraform.tfvars             # 環境別変数
├── user_data.sh                 # EC2 UserData
├── .terraform.lock.hcl
└── .gitignore
