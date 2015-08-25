require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

use_inline_resources
# support whyrun
def whyrun_supported?
  true
end

# loading current resource
  def load_current_resource
  @current_resource = Chef::Resource::AixSysdumpdev.new(@new_resource.name)

so = shell_out("lsvg -l rootvg|awk '/sysdump/{print $1}' ")
if so.exitstatus != 0
 @current_resource.exists = false
  raise("sysdumpdev : Error , no sysdump device found in rootvg, please create one first." )
  Chef::Log.debug(""sysdumpdev: There is no sysdump device")
  Chef::Log.debug(so.stdout)
else
   Chef::Log.debug("sysdumpdev: There is a sysdump device")
  @current_resource.exists = true
end


# estimate dump size
action :estimate do
  so = shell_out("sysdumpdev -e")
  if so.exitstatus != 0 || !so.stderr.empty?
    raise("sysdumpdev : error estimating dump size")
  end
end

# list sysdump properties
action :list do
  so = shell_out("sysdumpdev -l")
  if so.exitstatus != 0 || !so.stderr.empty?
    raise("sysdumpdev : error listing  sysdump properties")
  end
end

# displays last dump stats
action :dumpstats do
  so = shell_out("sysdumpdev -L")
  if so.exitstatus != 0 || !so.stderr.empty?
    raise("sysdumpdev : error listing previous dump stats")
  end
end

# Change primary sysdump device
action :primary do
  # the command will always begin with "sysdumpdev
  string_shell_out="sysdumpdev "
  converge_by("sysdumpdev : setting primary dump device")

  # setting -p if set_default is true
  if @new_resource.set_default
    string_shell_out = string_shell_out << "-P "
  end
  # check if  attribute exists for current device, if not raising error
  if @new_resource.device.exists do
    string_shell_out= string_shell_out << "-p" @new_resource.device
    so = shell_out(string_shell_out)
    # if the command fails raise and exception
    if so.exitstatus != 0
        raise "sysdumpdev: #{string_shell_out} failed"
    end
  else
    Chef::Log.debug("sysdumpdev : no device specified")
end


# Change secondary sysdump device
action :secondary do
  # the command will always begin with "sysdumpdev
  string_shell_out="sysdumpdev "
  converge_by("sysdumpdev : setting secondary dump device")

  # setting -p if set_default is true
  if @new_resource.set_default
    string_shell_out = string_shell_out << "-P "
  end
  # check if  attribute exists for current device, if not raising error
  if @new_resource.device.exists do
    string_shell_out= string_shell_out << "-s" @new_resource.device
    so = shell_out(string_shell_out)
    # if the command fails raise and exception
    if so.exitstatus != 0
        raise "sysdumpdev: #{string_shell_out} failed"
    end
  else
    Chef::Log.debug("sysdumpdev : no device specified")
end
