import os
from mininet.net import Mininet
from mininet.topo import Topo
from mininet.log import setLogLevel, info
from mininet.cli import CLI
from mininet.node import RemoteController

from p4_mininet import P4Switch, P4Host

import argparse
from time import sleep

parser = argparse.ArgumentParser(description='Mininet demo')
parser.add_argument('--behavioral-exe', help='Path to behavioral executable',
                    type=str, action="store", required=True)
parser.add_argument('--thrift-port', help='Thrift server port for table updates',
                    type=int, action="store", default=9090)
parser.add_argument('--num-hosts', help='Number of hosts to connect to switch',
                    type=int, action="store", default=2)
parser.add_argument('--mode', choices=['l2', 'l3'], type=str, default='l3')
parser.add_argument('--json', help='Path to JSON config file',
                    type=str, action="store", required=True)
parser.add_argument('--pcap-dump', help='Dump packets on interfaces to pcap files',
                    type=str, action="store", required=False, default=False)


args = parser.parse_args()


class SingleSwitchTopo(Topo):
    def __init__(self, sw_path, json_path, thrift_port, pcap_dump, **opts):
        Topo.__init__(self, **opts)

        switch1 = self.addSwitch('s1', sw_path = sw_path, json_path = json_path, thrift_port = thrift_port,cls = P4Switch ,pcap_dump = pcap_dump)
        switch2 = self.addSwitch('s2', sw_path = sw_path, json_path = json_path, thrift_port = thrift_port + 1,cls = P4Switch ,pcap_dump = pcap_dump)
        switch3 = self.addSwitch('s3', sw_path = sw_path, json_path = json_path, thrift_port = thrift_port + 2,cls = P4Switch ,pcap_dump = pcap_dump)
        switch4 = self.addSwitch('s4', sw_path = sw_path, json_path = json_path, thrift_port = thrift_port + 3,cls = P4Switch ,pcap_dump = pcap_dump)
	switch5 = self.addSwitch('s5', sw_path = sw_path, json_path = json_path, thrift_port = thrift_port + 4,cls = P4Switch ,pcap_dump = pcap_dump)
	switch6 = self.addSwitch('s6', sw_path = sw_path, json_path = json_path, thrift_port = thrift_port + 5,cls = P4Switch ,pcap_dump = pcap_dump)
        
        host1 = self.addHost('h1', mac = '00:00:00:00:00:01')
        host2 = self.addHost('h2', mac = '00:00:00:00:00:02')
	host3 = self.addHost('h3', mac = '00:00:00:00:00:03')
	host4 = self.addHost('h4', mac = '00:00:00:00:00:04')

	self.addLink(switch1, switch2, port1 = 1, port2 = 1)
	self.addLink(switch1, switch5, port1 = 2, port2 = 4)
	self.addLink(switch1, switch3, port1 = 3, port2 = 1)
	self.addLink(switch1, host1, port1 = 4, port2 = 0)
	self.addLink(switch1, host2, port1 = 5, port2 = 0)

	self.addLink(switch4, switch2, port1 = 1, port2 = 2)
	self.addLink(switch4, switch6, port1 = 2, port2 = 4)
	self.addLink(switch4, switch3, port1 = 3, port2 = 2)
	self.addLink(switch4, host3, port1 = 4, port2 = 0)
	self.addLink(switch4, host4, port1 = 5, port2 = 0)

	self.addLink(switch5, switch2, port1 = 1, port2 = 3)
	self.addLink(switch5, switch6, port1 = 2, port2 = 2)
	self.addLink(switch5, switch3, port1 = 3, port2 = 3)

	self.addLink(switch6, switch2, port1 = 1, port2 = 4)
	self.addLink(switch6, switch3, port1 = 3, port2 = 4)

        



def main():
    topo = SingleSwitchTopo(args.behavioral_exe, args.json, args.thrift_port, args.pcap_dump)
    net = Mininet(topo = topo, host = P4Host, controller = None)
    net.start()

    net.get('h1').cmd('ip -4 addr del 10.0.0.1/8 dev eth0')
    net.get('h1').cmd('ip -4 addr add 192.108.1.1/24 dev eth0')
    net.get('h1').cmd('ip -4 route add 192.108.2.1 dev eth0')
    net.get('h1').cmd('ip -4 route add 192.108.3.1 dev eth0')
    net.get('h1').cmd('ip -4 route add 192.108.4.1 dev eth0')
    
    net.get('h2').cmd('ip -4 addr del 10.0.0.2/8 dev eth0')
    net.get('h2').cmd('ip -4 addr add 192.108.2.1/24 dev eth0')
    net.get('h2').cmd('ip -4 route add 192.108.1.1 dev eth0')
    net.get('h2').cmd('ip -4 route add 192.108.3.1 dev eth0')
    net.get('h2').cmd('ip -4 route add 192.108.4.1 dev eth0')

    net.get('h3').cmd('ip -4 addr del 10.0.0.3/8 dev eth0')
    net.get('h3').cmd('ip -4 addr add 192.108.3.1/24 dev eth0')
    net.get('h3').cmd('ip -4 route add 192.108.1.1 dev eth0')
    net.get('h3').cmd('ip -4 route add 192.108.2.1 dev eth0')
    net.get('h3').cmd('ip -4 route add 192.108.4.1 dev eth0')

    net.get('h4').cmd('ip -4 addr del 10.0.0.4/8 dev eth0')
    net.get('h4').cmd('ip -4 addr add 192.108.4.1/24 dev eth0')
    net.get('h4').cmd('ip -4 route add 192.108.1.1 dev eth0')
    net.get('h4').cmd('ip -4 route add 192.108.2.1 dev eth0')
    net.get('h4').cmd('ip -4 route add 192.108.3.1 dev eth0')


    net.get('h1').cmd('ip -6 addr add 2001::1/64 dev eth0')
    net.get('h1').cmd('ip -6 route add 2002::1 dev eth0')
    net.get('h1').cmd('ip -6 route add 2003::1 encap seg6 mode inline segs abcd:1234:1:1:: dev eth0')
    net.get('h1').cmd('ip -6 route add 2004::1 encap seg6 mode inline segs abcd:1234:1:1:1:2:3:4 dev eth0')
    net.get('h1').cmd('ip sr tunsrc set 2001::1')
    net.get('h1').cmd('ip -6 route add abcd:1234:1:1:: via 2003::1 dev eth0')
    net.get('h1').cmd('ip -6 route add abcd:1234:1:1:1:2:3:4 via 2004::1 dev eth0')
    
    net.get('h2').cmd('ip -6 addr add 2002::1/64 dev eth0')
    net.get('h2').cmd('ip -6 route add 2001::1 dev eth0')
    net.get('h2').cmd('ip -6 route add 2003::1 dev eth0')
    net.get('h2').cmd('ip -6 route add 2004::1 dev eth0')
    
    net.get('h3').cmd('ip -6 addr add 2003::1/64 dev eth0')
    net.get('h3').cmd('ip -6 route add 2001::1 encap seg6 mode inline segs abcd:1234:1:1:: dev eth0')
    net.get('h3').cmd('ip -6 route add 2002::1 dev eth0')
    net.get('h3').cmd('ip -6 route add 2004::1 dev eth0')
    net.get('h3').cmd('ip sr tunsrc set 2003::1')
    net.get('h3').cmd('ip -6 route add abcd:1234:1:1:: via 2001::1 dev eth0')
   
    net.get('h4').cmd('ip -6 addr add 2004::1/64 dev eth0')
    net.get('h4').cmd('ip -6 route add 2001::1 encap seg6 mode inline segs abcd:1234:1:1:1:2:3:4 dev eth0')
    net.get('h4').cmd('ip -6 route add 2002::1 dev eth0')
    net.get('h4').cmd('ip -6 route add 2003::1 dev eth0')
    net.get('h4').cmd('ip sr tunsrc set 2004::1')
    net.get('h4').cmd('ip -6 route add abcd:1234:1:1:1:2:3:4 via 2001::1 dev eth0')


    sleep(1)

    print('\033[0;32m'),
    print "Gotcha!"
    print('\033[0m')

    CLI(net)
    try:
        net.stop()
    except:
        print('\033[0;31m'),
        print('Stop error! Trying sudo mn -c')
        print('\033[0m')
        os.system('sudo mn -c')
        print('\033[0;32m'),
        print ('Stop successfully!')
        print('\033[0m')

if __name__ == '__main__':
    setLogLevel('info')
    main()

    


