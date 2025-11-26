############################################
# CloudWatch Alarm - ALB 5xx エラー監視
############################################
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {

  # アラーム名（例: tastylog-dev-alb-5xx）
  alarm_name = "${var.project}-${var.env}-alb-5xx"

  # しきい値を超えた場合にアラーム状態とする
  comparison_operator = "GreaterThanThreshold"

  # 何回連続でしきい値を超えたらアラームとするか
  evaluation_periods = 2

  # 監視対象メトリクス
  metric_name = "HTTPCode_ELB_5XX_Count"
  namespace   = "AWS/ApplicationELB"

  # 評価間隔（秒）
  period = 60

  # メトリクスの集計方法（合計値）
  statistic = "Sum"

  # しきい値（60秒あたり 10 件以上の 5xx）
  threshold = 10

  # 対象となる ALB を特定
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  # アラームの説明
  alarm_description = "ALB で 5xx エラーが一定回数を超過"

  # データ欠損時は異常扱いにしない
  treat_missing_data = "notBreaching"

  # アラーム発生時の通知先（SNS）
  alarm_actions = [var.sns_topic_arn]

  # 復旧時の通知先（SNS）
  ok_actions = [var.sns_topic_arn]
}

############################################
# CloudWatch Alarm - ECS CPU 使用率監視
############################################
resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {

  # アラーム名（例: tastylog-dev-ecs-cpu-high）
  alarm_name = "${var.project}-${var.env}-ecs-cpu-high"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  # 監視対象メトリクス
  metric_name = "CPUUtilization"
  namespace   = "AWS/ECS"

  period    = 60
  statistic = "Average"

  # CPU 使用率が 80% を超えたらアラート
  threshold = 80

  # 対象 ECS サービスを特定
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_description  = "ECS の CPU 使用率が高騰"
  treat_missing_data = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}

############################################
# CloudWatch Alarm - RDS CPU 使用率監視
############################################
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {

  # アラーム名（例: tastylog-dev-rds-cpu-high）
  alarm_name = "${var.project}-${var.env}-rds-cpu-high"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2

  # 監視対象メトリクス
  metric_name = "CPUUtilization"
  namespace   = "AWS/RDS"

  period    = 60
  statistic = "Average"

  # CPU 使用率が 75% を超えたらアラート
  threshold = 75

  # 対象 RDS インスタンスを特定
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_description  = "RDS の CPU 使用率が高騰"
  treat_missing_data = "notBreaching"

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}