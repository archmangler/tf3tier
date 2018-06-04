output "elb_address" {
  value = "${aws_elb.web.dns_name}"
}

output "web_addresses" {
  value = "${aws_instance.web.*.public_ip}"
}

#output "db_addresses" {
#  value = "${aws_instance.rdb.private_ip}"
#}

#output "app_addresses" {
#  value = "${aws_instance.app.private_ip}"
#}

output "public_subnet_ids" {
  value = "${module.vpc.public_subnet_ids}"
}
