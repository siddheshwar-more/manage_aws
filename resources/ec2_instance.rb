actions :get_metadata, :stop, :detach_volume, :terminate
default_action :get_metadata

attribute :instance_id, :kind_of => String 
attribute :volume_id, :kind_of => String 
attribute :tag_name, :kind_of => String 
attribute :private_ip, :kind_of => String 

