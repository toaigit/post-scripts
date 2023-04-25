#  post-scripts - for cloudinit (userdata)

*  These scripts can be placed anywhere on your ec2.  In this example, I pull it down in the /tmp/post-scripts.git
   * you need to put this code in github/gitlab project called post-scripts
   * in your aws userdata do the following
      * cd /tmp
      * git clone https://github.com/toaigit/post-scripts.git
   * Your userdata should be able to reference these scripts as /tmp/post-scripts/scriptName
      * runeip-v2 will attach your eip to the ec2
      * runcmd-v2 will attach your pre-created ebs volumes
      * runadduser-v2 will create your team members unix account on the ec2.
      * install.python will install python, flask and apache
      * install.nodejs will install nodejs, express and apache
*  NOTE: Any credential file in this folders are for your reference to try out.  You should not place any credential, certificates in your public repos.
