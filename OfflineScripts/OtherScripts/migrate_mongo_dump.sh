export name="10_27_2015"
cd ~/Documents/Resume/ppk/
#ssh -i resume-ravi ubuntu@ec2-54-176-82-198.us-west-1.compute.amazonaws.com 'tar -czf - /home/ubuntu/backup_data/$name'
scp -C -r -i resume-ravi ubuntu@ec2-54-215-25-61.us-west-1.compute.amazonaws.com:/home/ubuntu/backup_data/$name ./
unzip $name.zip
mongo futura --eval "db.dropDatabase()"
mongorestore --db=futura ./$name/futura/