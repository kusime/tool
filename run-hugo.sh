cd /home/kusime/Desktop/blog
while true
do
hugo server  --bind 0.0.0.0 --port 80 -D
if [ $? != 0 ]
then
hugo server -D
sleep 1
fi
done
