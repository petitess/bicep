### Multiple availability sets
[What is an availability set?](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)

An availability set is a logical grouping of VMs that allows Azure to understand how your application is built to provide for redundancy and availability. We recommended that two or more VMs are created within an availability set to provide for a highly available application and to meet the 99.95% Azure SLA. There is no cost for the Availability Set itself, you only pay for each VM instance that you create.