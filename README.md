# IPRelayUpdateAutomation

<!-- Create a Bulleted list in md. PowerShelll script starts the process. creaters IP.txt file, and copis file toeach server. It then starts the task on the server. importRealyListUpdate.vbs sits on each server and imports the ip.txt file, and updates the SMTP relay server list. xml file is a copy of the scheduled task in Task scheduler. -->

<!-- TOC -->

- [IPRelayUpdateAutomation](#iprelayupdateautomation)
  - [Overview](#overview)
  - [Features](#features)
  - [How to Use](#how-to-use)
  - [Requirements](#requirements)


<!-- /TOC -->

## Overview

This script was created to automate the process of updating the SMTP relay list on our servers. It is a PowerShell script that creates a text file with the IP addresses of the SMTP relays, copies the file to each server, and starts the task on the server. The task runs a VBScript that imports the IP.txt file, and updates the SMTP relay server list.
The VBScript was adapted from [How to import a list of IP addresses into a Microsoft SMTP relay server](https://dailysysadmin.com/KB/Article/2168/how-to-import-a-list-of-ip-addresses-into-a-microsoft-smtp-relay-server/)

## Features

- Creates an update text file with allowed IP addresses.
- Copies the file to each server
- Starts the task on the server

## How to set up
- On each SMTP server
    - Put a copy of the importRelayList-Update.vbs
    - Use the UpdateSMTPRelay.xml templat to create a scheduled task to run the VBScript
- On you jumpbox or automation server
    - Put the ProvisionAndDeprovisionSMTP.ps1
    - Update notated locations in the script for your environment

## How to Use

1. Run the PowerShell script with parameters IpAddress, SubnetMask, and AddOrRemove
example
```powershell
.\ProvisionAndDeprovisionSMTP.ps1 -IpAddress "192.100.10.5" -SubnetMask "255.255.255.255" -AddOrRemove Add
```
2. The PowerShell script will create the IP.txt file, copy it to each server, and start the task on the server
3. The task starts script importRelayList-Update.vbs that imports the updated IP.txt file, and replaces the existing allowed IP relay list.

## Requirements

- PowerShell v3 or higher

