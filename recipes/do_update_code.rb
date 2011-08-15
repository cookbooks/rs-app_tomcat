# Cookbook Name:: app_tomcat
# Recipe:: do_update_code
#
# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Check that we have the required attributes set
raise "You must provide a URL to your application code repository" if ("#{node[:tomcat][:code][:url]}" == "")
raise "You must provide a destination for your application code." if ("#{node[:tomcat][:docroot]}" == "")

# Warn about missing optional attributes
Chef::Log.warn("WARNING: You did not provide credentials for your code repository -- assuming public repository.") if ("#{node[:tomcat][:code][:credentials]}" == "")
Chef::Log.info("You did not provide branch informaiton -- setting to default.") if ("#{node[:tomcat][:code][:branch]}" == "")


# delete docroot in order for repo_git_pull to work correctly
directory "#{node[:tomcat][:docroot]}" do
  recursive true
  action :delete
end

# grab application source from remote repository
repo_git_pull "Get Repository" do
  url    node[:tomcat][:code][:url]
  branch node[:tomcat][:code][:branch]
  dest   node[:tomcat][:docroot]
  cred   node[:tomcat][:code][:credentials]
end

# Set code ownership
bash "chown_home" do
  code <<-EOH
    chown -R #{node[:tomcat][:app_user]}:#{node[:tomcat][:app_user]} #{node[:tomcat][:docroot]}
  EOH
end
