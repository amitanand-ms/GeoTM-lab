Scenario – This lab deploys geographically load balanced solutions with primary and secondary application regions using Traffic Manager. The end goal is the user should always get to its primary region and must get to the secondary region only when primary region application is down. 

Deployment Design.

 ![Alt text](https://github.com/amitanand-ms/GeoTM-lab/blob/main/Picture1.png)



This Script will deploy the resources below. 

Two Resource groups EastusResourcegroup and WestEuropeResourceGroup in regions EastUS and WestEU respectively. 
 
EastusResourcegroup
	Traffic manager as TM1
	Backend VM on Linux (Linuxbackend).
	Public IP assigned to the VM (Linux-pip)
	NSG to allow access to VM (subnetnsg)

WestEuropeResourceGroup
	Traffic Manager GeoTM
	Traffic Manager TM2
	Backend VM on Windows (Winbackend)
	Public IP assigned to VM (win-pip)
	NSG to allow Access (subnetnsg)

Installation steps
Open cloud shell in bash from portal. 
Copy file nestedtm.tf to your cloud shell space. 
Run below commands
1.)	curl http://ipinfo.me
               Save IP address shown by above command to somewhere notepad etc. 
               
2.)	terraform init

3.)	terraform apply 

At this time, it will ask to enter the ip address. Enter the ip address from step 1 here. This IP will be added in nsg rules to allow deployment.

var.srcip
              Enter a value:
       After parsing script, it should give you following prompt, write yes and press enter. 
       
       Do you want to perform these actions?
       Terraform will perform the actions described above.
       Only 'yes' will be accepted to approve.

        Enter a value: 

4.)	Once deployment completes ssh to linux VM in east US region and RDP to windows VM in west EU region. Use username as testadmin and password P@ssw0rd1234!

5.)	Do a nslookup to the fqdn of Geo traffic manager from Westeuropresourcegroup. You should see each VM resolve Geo TM FQDN to different IP based on region. 
