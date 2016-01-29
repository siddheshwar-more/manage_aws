require 'open-uri'
module Chef
  module Aws
    module Ec2
      def ec2
        begin
          require 'aws-sdk'
        rescue LoadError
          Chef::Log.error("Missing gem 'aws-sdk'. Use the default aws recipe to install it first.")
        end

        @@ec2 ||= create_aws_interface(::Aws::EC2::Client)
      end

      def create_aws_interface(aws_interface)
        region = query_aws_region
        # todo use enycrpted db
        creds = ::Aws::Credentials.new(node['aws_access_key'], node['aws_secret_access_key'])
        aws_interface.new(credentials: creds, region: region)
      end

      # determine the AWS region of the node
      # Priority: User set node attribute -> ohai data -> us-east-1
      def query_aws_region
        region = node['aws']['region']

        if region.nil?
          if node.attribute?('ec2')
            region = instance_availability_zone
            region = region[0, region.length - 1]
          else
            region = 'us-east-1'
          end
        end
        region
      end

      def test_hello
        puts "Hello world"
      end
      
      def instance_availability_zone
        @@instance_availability_zone ||= query_instance_availability_zone
      end

      # fetch the availability zone from the metadata endpoint
      def query_instance_availability_zone
        availability_zone = open('http://169.254.169.254/latest/meta-data/placement/availability-zone/', options = { proxy: false }, &:gets)
        fail 'Cannot find availability zone!' unless availability_zone
        Chef::Log.debug("Instance's availability zone is #{availability_zone}")
        availability_zone
      end
    end
  end
end
