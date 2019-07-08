#!/bin/bash

# Example usage:
# SSH_KEY_FILE=iobioServers.cer ./deploy_aws.sh

workers=$(./get_aws_addresses.py)

for worker in ${workers}
do
    echo $worker

    echo Copying files to ${worker}
    rsync -av -e "ssh -i ${SSH_KEY_FILE} -oStrictHostKeyChecking=no" --exclude=".git" --delete ./* ubuntu@${worker}:/mnt/data/
    
    echo Starting server
    ssh -i ${SSH_KEY_FILE} ubuntu@${worker} killall node
    ssh -i ${SSH_KEY_FILE} ubuntu@${worker} 'cd /mnt/data; PATH=./tool_bin:$PATH nohup node/bin/node src/index.js > log.out 2> log.err < /dev/null &'
    
    echo Done

done
