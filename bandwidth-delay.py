import os

# h1->h2
os.system('tc qdisc del dev s1-eth2 root')
os.system('tc qdisc del dev s2-eth2 root')
os.system('tc qdisc del dev s1-eth3 root')
os.system('tc qdisc del dev s3-eth2 root')
os.system('tc qdisc del dev s4-eth1 root')

#os.system('tc qdisc add dev s1-eth2 root handle 1:0 htb default 11')
#os.system('tc qdisc add dev s2-eth2 root handle 1:0 htb default 11')
#os.system('tc qdisc add dev s1-eth3 root handle 1:0 htb default 11')
#os.system('tc qdisc add dev s3-eth2 root handle 1:0 htb default 11')
#os.system('tc qdisc add dev s4-eth1 root handle 1:0 htb default 11')

#os.system('tc class add dev s1-eth2 parent 1:0 classid 1:11 htb rate 1mbit ceil 7mbit')
#os.system('tc qdisc add dev s1-eth2 parent 1::11 netem delay 10ms 1ms')
#os.system('tc class add dev s2-eth2 parent 1:0 classid 1:11 htb rate 1mbit ceil 7mbit')
#os.system('tc class add dev s1-eth3 parent 1:0 classid 1:11 htb rate 3mbit ceil 3mbit')
#os.system('tc qdisc add dev s1-eth3 parent 1::11 netem delay 5ms 1ms')
#os.system('tc class add dev s3-eth2 parent 1:0 classid 1:11 htb rate 3mbit ceil 3mbit')
#os.system('tc class add dev s4-eth1 parent 1:0 classid 1:11 htb rate 3mbit ceil 10Mbit')
