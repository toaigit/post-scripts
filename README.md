#  ec2-scripts - for cloudinit (userdata)

*  These scripts can be placed anywhere on your ec2.  In this example, I pull it down in the /tmp/ec2-scripts.git
   * you need to put this code in github/gitlab project called ec2-scripts
   * in your aws userdata do the following
      * cd /tmp
      * git clone https://github.com/toaigit/ec2-scripts.git
   * Your userdata should be able to reference these scripts as /tmp/ec2-scripts/scriptName
*  Look at the ec2-buster for an example of the userdata that will call these commands.
