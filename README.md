This repository is deprecated, we're migrating to https://github.com/LIS/LISAv2.

# azure-linux-automation
Automation tools for testing Linux images on Microsoft Azure
## Overview
Azure automation is the project for primarily running the Test Suite in the Windows Azure environment to test the Linux Agent for Windows Azure. Azure automation project is a collection of PowerShell, BASH and python scripts. The test ensures the functionality of Windows Azure Linux Agent and Windows Azure support for different Linux distributions. This test suite focuses on the Build Verification Tests (BVTs), Azure VNET Tests and Network tests. The test environment is composed of a Windows Machine (With Azure PowerShell SDK) and the Virtual Machines on Azure that perform the actual tests.
## <a id="prepare"></a>Prepare Your Machine for Automation Cycle
### Prerequisite
1.  You must have a Windows Machine with PowerShell. Tested Platforms:

          a.  Windows 7x64
          b.  Windows 8x64
          c.  Server 2008
          d.  Server 2012
          e.  Server 2012 R2
          
2.  You must be connected to Internet.
3.  You must have a valid Windows Azure Subscription.

          a.  Subscription Name
          b.  Subscription ID
          
### Download Latest Automation Code
1.  Checkout from https://github.com/Azure/azure-linux-automation.git

### Download Latest Azure PowerShell
1.	Download Web Platform Installer from : http://go.microsoft.com/fwlink/p/?linkid=320376&clcid=0x409 
2.	Start Web Platform Installer and select Azure PowerShell and proceed for Azure PowerShell Installation.

### Authenticate Your Machine with Your Azure Subscription
There are two ways to authenticate your machine with your subscription.

1.	Azure AD method

      This creates a 12 Hours temporary session in PowerShell, in that session, you are allowed to run Windows Azure Cmdlets to control / use your subscription. After 12 hours you will be asked to enter username and password of your subscription. This may create problems long running automations, hence we use certificate method.

2.	Certificate Method.

      To learn more about how to configure your PowerShell with your subscription, please visit [here](http://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/#Connect).

### Download Public Utilities
Download Putty executables from http://www.putty.org and keep them in `.\automation_root_folder\tools`. You should have the following utilities:

        •	plink.exe
        •	pscp.exe
        •	putty.exe
        •	puttygen.exe

Download dos2unix executables from http://sourceforge.net/projects/dos2unix/ and keep them in `.\automation_root_folder\tools`. You should have the following utilities:

        •	dos2unix.exe
		
Download 7-zip executable from http://www.7-zip.org/ ( Direct Download Link : http://www.7-zip.org/a/7za920.zip ) and keep them in `.\automation_root_folder\tools`. You should have the following utility:

        •	7za.exe
		
### Update Azure_ICA_all.xml file
1.	Setup Subscription details.

      Go to Config > Azure > General and update following fields :

        a.	SubscriptionID
        b.	SubscriptionName
        c.	CertificateThumbprint (Make sure you have installed a management certificate and can access it via the Azure Management Portal (SETTINGS->MANAGEMENT CERTIFICATES). )
        d.	StorageAccount
        e.	Location
        f.	AffinityGroup (Make sure that you either use <Location> or <AffinityGroup>. Means, if you want to use Location, then AffinityGroup should be blank and vice versa )

  Example :
  ```xml
  <General>
    <SubscriptionID>Your Subscription ID</SubscriptionID>
    <SubscriptionName>Your Subscription Name</SubscriptionName>
    <CertificateThumbprint>Certificate associated with your subscription</CertificateThumbprint>
    <ManagementEndpoint>https://management.core.windows.net</ManagementEndpoint>
    <StorageAccount>your current storage account</StorageAccount>
    <Location>Your preferred location</Location>
    <AffinityGroup></AffinityGroup>
  </General>
  ```
      
2.	Add VHD details in XML File.
    
      Go to Config > Azure > Deployment > Data. Make sure that your "VHD under test" should be present here in one of <Distro>..</Distro> entries. If your VHD is not listed here. Create a new Distro element and add your VHD details.

  Example:
  ```xml
  <Distro>
    <Name>Distro_Name</Name>
    <OsImage>Distro_OS_Image_Name_As_Appearing_under_Azure_OS_Images</OsImage>
  </Distro>
  ```
  
3.  Save file.

### Prepare VHD to work in Azure
`Applicable if you are uploading your own VHD with Linux OS to Azure.`

A VHD with Linux OS must be made compatible to work in Azure environment. This includes –

        1.	Installation of Linux Integration Services to Linux VM (if already not present)
        2.	Installation of Windows Azure Linux Agent to Linux VM (if already not installed.)
        3.	Installation of minimum required packages. (Applicable if you want to run Tests using Automation code)

Please follow the steps mentioned at: 
http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-create-upload-vhd/

### Prepare VHD to work with Automation code.
`Applicable if you are using already uploaded VHD / Platform Image to run automation.`

To run automation code successfully, you need have following packages installed in your Linux VHD.

        1.	iperf
        2.	mysql-server
        3.	mysql-client
        4.	gcc
        5.	gcc-c++
        6.	bind
        7.	bind-utils
        8.	bind9
        9.	python
        10.	python-pyasn1
        11.	python-argparse
        12.	python-crypto
        13.	python-paramiko
        14.	libstdc++6
        15.	psmisc
        16.	nfs-utils
        17.	nfs-common
        18.	tcpdump

### Create SSH Key Pair
`PublicKey.cer – PrivateKey.ppk`

A Linux Virtual machine login can be done with Password authentication or SSH key pair authentication. You must create a Public Key and Private key to run automation successfully. To learn more about how to create SSH key pair, please visit [here](http://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-use-ssh-key/).

After creating Public Key (.cer) and putty compatible private key (.ppk), you must put it in your `automation_root_folder\ssh\` folder and mention their names in Azure XML file.

### VNET Preparation
`Required for executing Virtual Network Tests`

#### Create a Virtual Network in Azure
A virtual network should be created and connected to Customer Network before running VNET test cases. To learn about how to create a virtual network on Azure, please visit [here](https://azure.microsoft.com/documentation/articles/vpn-gateway-site-to-site-create/).

#### Create A customer site using RRAS
Apart from Virtual Network in Azure, you also need a network (composed of Subnets and DNS server) to work as Customer Network. If you don’t have separate network to run VNET, you can create a virtual customer network using RRAS. To learn more, please visit [here](https://msdn.microsoft.com/en-us/library/dn636917.aspx).

## How to Start Automation
Before starting Automation, make sure that you have completed steps in chapter [Prepare Your Machine for Automation Cycle](#prepare)

        1.	Start PowerShell with Administrator privileges
        2.	Navigate to folder where automation code exists
        3.	Issue automation command

#### Automation Cycles Available
        1.	BVT
        2.	NETWORK
        3.	VNET
        4.	E2E-1
        5.  E2E-DISK
        6.	E2E-TIMESYNC
        7.	E2E-TIMESYNC-KERNBANCH
        8.	WORDPRESS1VM
        9.	WORDPRESS4VM
        10.	DAYTRADER1VM
        11.	DAYTRADER4VM
        12. NETPERF
        13. IOPERF-RAID
        14. IOPERF-LVM

#### Supported Azure Mode
        1. AzureServiceManagement, if the value is present in the SupportedExecutionModes tag of the case definition
        2. AzureResourceManager, if the value is present in the SupportedExecutionModes tag of the case definition
        
#### Command to Start any of the Automation Cycle
Run test in ASM mode

        .\AzureAutomationManager.ps1 -xmlConfigFile .\Azure_ICA_ALL.xml -runtests -email –Distro <DistroName> -cycleName <TestCycleToExecute> 
        
Run test in ARM mode

        .\AzureAutomationManager.ps1 -xmlConfigFile .\Azure_ICA_ALL.xml -runtests -email –Distro <DistroName> -cycleName <TestCycleToExecute> -UseAzureResourceManager

#### More Information
For more details, please refer to the documents [here](https://github.com/Azure/azure-linux-automation/tree/master/Documentation).
