# simple-user-simulation

powershell script to simulate activity by a user

# Why does it exist?

Improve the experience of cybersecurity exercises. The script can be run on multiples VM/PCs to simulate the activity of real users, and generate traffic on the network.

# This set of powershell scripts simulate on W10/W7 the activity of an user

It is strongly recommended you read the documentation in Docs before attempting anything.

# Features

- Run automatically for a specified time
- No-fail policy, the parts of the script can fail (for eg if network is too slow) but whatever can still run will keep running
- Log everthing, logs can be emailed (experimental)
- Run locally or on multiple (networked) machines
- Simulate: Internet Explorer browsing, Typing, accessing a shared drive, open outlook (desktop, tested on W7) and open any (executable) attachment, and any link.
