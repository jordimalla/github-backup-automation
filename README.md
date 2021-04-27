# github-backup-automation

This project is basing on this [koddr/github-backup-automation](https://github.com/koddr/github-backup-automation)

I only add two thinghs:
- In the Dokerfile: I Add a few lines to load my python script for send an alert message when the copy finished.
- In the entrypoint.sh: I Add a few lines to send the message at copy finish.
