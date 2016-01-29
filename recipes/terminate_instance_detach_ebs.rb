#
# Cookbook Name:: manage_aws
# Recipe:: create_ssl_certificate
#
# Copyright 2016, Opcito Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# name tags array - ["testinst1", "testinst2"]
tags = node.tags

instances = []
volume_ids = []

# get instance details
tags.each do |tag|
  resource_name = "#{tags}-ec2-instance"
  ec2_instance "#{resource_name}" do
    action :get_metadata
  end
  instances << resource_name
end

#stop ec2 instance
instances.each do |instance|
  ec2_instance "#{instance}_stop" do
    notifies :stop, "ec2_instance[#{instance}]", :immediately
  end
end

# detach volume
instances.each do |instance|
  ec2_instance "#{instance}_detach_volume' do
    notifies :detach_volume, "ec2_instance[#{instance}]", :immediately
  end

  # get instance obj
  resource = resources(ec2_instance: "#{instance}")
  volume_ids << resource.volume_id
end


#stores volumes id in file for later use
file "#{ENV['HOME']}/volume_ids.txt" do
  content "#{volume_ids.join('\n')}"
  mode '0755'
  owner 'web_admin'
  group 'web_admin'
end

# delete instance
instances.each do |instance|
  ec2_instance "#{instance}_terminate' do
    notifies :terminate, "ec2_instance[#{instance}]", :immediately
  end
end