variable "app_name" {
  type = string
}

resource "aws_iam_role" "task_execution" {
  name = "${var.app_name}-TaskExecution"
  assume_role_policy = file("./iam/task_execution_role.json")
}

resource "aws_iam_role_policy" "task_execution" {
  role = aws_iam_role.task_execution.id
  policy = file("./iam/task_execution_role_policy.json")

}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

output "iam_role_task_execution_arn" {
  value = aws_iam_role.task_execution.arn
}