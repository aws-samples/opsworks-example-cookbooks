#
# Cookbook Name:: alb_support
# Recipe:: detach_from_alb
#
# Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.
#
ruby_block "detach from ALB" do
  block do
    require "aws-sdk-core"

    raise "alb_helper block not specified in layer JSON" if node[:alb_helper].nil?
    raise "Target Group ARN not specified in layer JSON" if node[:alb_helper][:target_group_arn].nil?

    connection_draining_timeout = node[:alb_helper][:connection_draining_timeout]
    state_check_frequency = node[:alb_helper][:state_check_frequency]

    Chef::Log.info("connection_draining_timeout: #{connection_draining_timeout}")
    Chef::Log.info("state_check_frequency: #{state_check_frequency}")

    stack = search("aws_opsworks_stack").first
    instance = search("aws_opsworks_instance", "self:true").first

    stack_region = stack[:region]
    ec2_instance_id = instance[:ec2_instance_id]
    target_group_arn = node[:alb_helper][:target_group_arn]

    Chef::Log.info("Creating ELB client in region #{stack_region}")
    client = Aws::ElasticLoadBalancingV2::Client.new(region: stack_region)

    target_to_detach = {
      target_group_arn: target_group_arn,
      targets: [ { id: ec2_instance_id } ],
    }

    Chef::Log.info("Deregistering EC2 instance #{ec2_instance_id} from Target Group #{target_group_arn}")
    client.deregister_targets(target_to_detach)

    if connection_draining_timeout == 0
      Chef::Log.info("connection_draining_timeout was set to 0 seconds. execution of shutdown recipes will not be delayed")
    else
      Chef::Log.info("delaying execution recipes until instance is drained from ALB or timeout of #{connection_draining_timeout} seconds elapses")
      start_time = Time.now
      loop do
        response = client.describe_target_health(target_to_detach)
        target_health_state = response[:target_health_descriptions].first[:target_health][:state]
        Chef::Log.info("state of instance in ALB: #{target_health_state}")
        seconds_elapsed = Time.now - start_time
        Chef::Log.info("#{seconds_elapsed} of a maximum #{connection_draining_timeout} seconds elapsed")
        Chef::Log.info("Sleeping #{ state_check_frequency} seconds")
        break if target_health_state == "unused" || seconds_elapsed > connection_draining_timeout
        sleep(state_check_frequency)
      end
    end
  end
  action :run
end
