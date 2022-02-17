#include <core.p4>
#include <v1model.p4>



//Headers


typedef bit<48> MacAddress;
typedef bit<32> IPv4Address;
typedef bit<128> IPv6Address;


header Ethernet_h {
    MacAddress dstAddr;
    MacAddress srcAddr;
    bit<16>   etherType;
}


header Arp_h {
    bit<16>   htype;
    bit<16>   ptype;
    bit<8>    hlen;
    bit<8>    plen;
    bit<16>   oper;
}


header Arp_IPv4_h {
    MacAddress sha;
    IPv4Address spa;
    MacAddress tha;
    IPv4Address tpa;
}


header IPv4_h {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    IPv4Address srcAddr;
    IPv4Address dstAddr;
}


header IPv6_h {
    bit<4>    version;
    bit<8>    class;
    bit<20>   flowlabel;
    bit<16>   payloadlength;
    bit<8>    nextheader;
    bit<8>    hoplimit;
    IPv6Address srcAddr;
    IPv6Address dstAddr;
}


header Srh_h {
    bit<8> nextheader;
    bit<8> hdrextlen;
    bit<8> routingtype;
    bit<8> segmentleft;
    bit<8> lastentry;
    bit<8> flags;
    bit<16> tag;
    //varbit<2560> segmentlist;//at most 20 SIDs, only used for sending
}


header Srh_Address_h {
    IPv6Address dstAddr;
}


header Srh_BDD_h {
    bit<16>    loc_b;
    bit<16>    loc_n;
    bit<16>    demand_1;
    bit<16>    demand_2;
    bit<32>    bandwidth;
    bit<32>    delay;
}


header ICMPv6_h {
    bit<8>    type;
    bit<8>    code;
    bit<16>   checksum;
}


header ICMPv6_Neighbor_h {
    bit<32>      flags;      //(r,s,o,)reserved
    IPv6Address  targetAddr;
    bit<8>       type;
    bit<8>       length;
    MacAddress   srcAddr;
}


header ICMPv6_Echo_h {
    bit<16>       identifier;
    bit<16>       sequenceNumber;
    bit<56>       echoData;
}


struct metadata {
    bit<9>        sid_enable;     
    bit<9> 	  route_type;
}


struct headers {
    Ethernet_h         ethernet;
    Arp_h              arp;
    Arp_IPv4_h         arp_ipv4;
    IPv4_h             ipv4;  
    IPv6_h             ipv6;
    Srh_h              srh;
    Srh_Address_h      srh_address;
    Srh_BDD_h          srh_bdd;
    ICMPv6_h           icmpv6;
    ICMPv6_Neighbor_h  icmpv6_neigh;
    ICMPv6_Echo_h      icmpv6_echo;
    
}




//Parser

parser Ay_Parser(packet_in pkt,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
     
    const bit<16> ARP_HTYPE_ETHERNET = 0x0001;
    const bit<16> ARP_PTYPE_IPV4 = 0x0800;
    const bit<8> ARP_HLEN_ETHERNET = 6;
    const bit<8> ARP_PLEN_IPV4 = 4;


    state start {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            0x0806 : parse_arp;
	    0x0800 : parse_ipv4;
	    0x86DD : parse_ipv6;
            default : accept;
        }
    }


    state parse_arp {
        pkt.extract(hdr.arp);
	transition select(hdr.arp.htype,
	  		  hdr.arp.ptype,
			  hdr.arp.hlen,
			  hdr.arp.plen) {
	    (ARP_HTYPE_ETHERNET,
    	     ARP_PTYPE_IPV4,
	     ARP_HLEN_ETHERNET,
	     ARP_PLEN_IPV4) : parse_arp_ipv4;
	    default : accept;
	}
    }


    state parse_arp_ipv4 {
	pkt.extract(hdr.arp_ipv4);
	transition accept;
    }


    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }


    state parse_ipv6 {
        pkt.extract(hdr.ipv6);
        transition select(hdr.ipv6.nextheader) {
	    43 : parse_srh;
	    58 : parse_icmpv6;
  	    default : accept;
	}
    }


    state parse_srh {
	pkt.extract(hdr.srh);
        transition parse_srh_address;
    }


    state parse_srh_address {
	pkt.extract(hdr.srh_address);
        transition parse_srh_bdd;
    }


    state parse_srh_bdd {
	pkt.extract(hdr.srh_bdd);
	transition select(hdr.srh.nextheader) {
	    58 : parse_icmpv6;
  	    default : accept;
	}
    }


    state parse_icmpv6 {
	pkt.extract(hdr.icmpv6);
	transition select(hdr.icmpv6.type) {
	    135 : parse_icmpv6_neigh;
	    136 : parse_icmpv6_neigh;
	    128 : parse_icmpv6_echo;
	    129 : parse_icmpv6_echo;
	    default : accept;
	}
    }


    state parse_icmpv6_neigh {
        pkt.extract(hdr.icmpv6_neigh);
        transition accept;
    }


    state parse_icmpv6_echo {
        pkt.extract(hdr.icmpv6_echo);
        transition accept;
    }

    
    
}



//Checksum

control Ay_VerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply { 
	/*
	verify_checksum(true,
        {   hdr.ipv4.version,
            hdr.ipv4.ihl,
            hdr.ipv4.diffserv,
            hdr.ipv4.totalLen,
            hdr.ipv4.identification,
            hdr.ipv4.flags,
            hdr.ipv4.fragOffset,
            hdr.ipv4.ttl,
            hdr.ipv4.protocol,
            hdr.ipv4.srcAddr,
            hdr.ipv4.dstAddr
        },hdr.ipv4.hdrChecksum, HashAlgorithm.csum16);
	*/
   }
}



//Ingress

control Ay_Ingress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    

    //for outport
    action forward(bit<9> port) {
        standard_metadata.egress_spec = port;
    } 
        

    //multicast group
    action broadcast() {
        standard_metadata.mcast_grp = 1;
    }


    //match sid
    action match() {
	meta.sid_enable = 1;
    }


    //match route
    action match_route(bit<9> route_type) {
	meta.route_type = route_type;
    }


    //drop srh
    action drop() {
        hdr.ipv6.dstAddr = hdr.srh_address.dstAddr;
	hdr.ipv6.nextheader = hdr.srh.nextheader;
	hdr.ipv6.payloadlength = hdr.ipv6.payloadlength -40;
        hdr.srh.setInvalid();
        hdr.srh_address.setInvalid();
	hdr.srh_bdd.setInvalid();
    }


    //port forward
    table match_inport {
        key = {
            standard_metadata.ingress_port : exact;
        }
        actions = {forward;}
    } 


    //arp broadcast
    table handle_arp_broadcast {
        actions = {broadcast;}    
    }


    //arp forward
    table handle_arp {
        key = {
            hdr.arp_ipv4.tpa : lpm;
        }
	actions = {forward;}       
    }


    //ipv4 forward
    table match_ipv4 {
        key = {
            hdr.ipv4.dstAddr : lpm;
        }
        actions = {forward;}
    }

    
    //ndp broadcast
    table handle_ndp_broadcast {
        actions = {broadcast;}
    }


    //ndp
    table handle_ndp {
	key = {
            hdr.icmpv6_neigh.targetAddr : lpm;
        }
	actions = {forward;}
    }


    //interpretation of demands
    table interpret_demand {
	key = {
            hdr.srh_bdd.loc_b : exact;
	    hdr.srh_bdd.loc_n : exact;
        }
	actions = {match;}
    }


    //bandwidth & delay
    table handle_bandwidth_delay {
	key = {
	    hdr.srh_bdd.demand_1 : exact;
	    hdr.srh_bdd.demand_2 : exact;
	    hdr.srh_bdd.bandwidth : exact;
            hdr.srh_bdd.delay : exact;
	}
	actions = {match_route;}
    }


    //ipv6 forward
    table match_ipv6 {
        key = {
            hdr.ipv6.dstAddr : lpm;
        }
        actions = {forward;}        
    }


    //ipv6 forward route 1
    table match_ipv6_route_1 {
        key = {
            hdr.srh_address.dstAddr : lpm;
        }
        actions = {forward;}        
    }


    //ipv6 forward route 2
    table match_ipv6_route_2 {
        key = {
            hdr.srh_address.dstAddr : lpm;
        }
        actions = {forward;}        
    }


    //drop srh
    table drop_srh {
	 key = {
            hdr.srh_address.dstAddr : exact;
        }
        actions = {drop;}
    }




apply {
        match_inport.apply();
	if (hdr.ethernet.etherType == 0x0806) {
	    handle_arp.apply();
	}
	if (hdr.ethernet.etherType == 0x0800) {
            match_ipv4.apply();
        }
	if (hdr.ethernet.etherType == 0x86DD && hdr.ipv6.nextheader == 58 && hdr.icmpv6.type == 135) {
            handle_ndp.apply();
        }
	if (hdr.ethernet.etherType == 0x86DD && hdr.ipv6.nextheader == 58 && (hdr.icmpv6.type == 128 || hdr.icmpv6.type == 129 || hdr.icmpv6.type == 136)) {
            match_ipv6.apply();
        }
	if (hdr.ethernet.etherType == 0x86DD && hdr.ipv6.nextheader == 43) {
	    interpret_demand.apply();
	}
        if (meta.sid_enable == 1) {
	    handle_bandwidth_delay.apply();
	}
	if (meta.route_type == 1) {
	    match_ipv6_route_1.apply();
	}
	if (meta.route_type == 2) {
	    match_ipv6_route_2.apply();
	}
	drop_srh.apply();
    }



     //for base inport processing
     /*
     apply {
         match_inport.apply();
     }*/
    

     //for ip processing
     /*
     apply {
         match_inport.apply();
	 if (hdr.ethernet.etherType == 0x0806 && hdr.arp.oper == 1) {
	     handle_arp_broadcast.apply();
	 }
	 if (hdr.ethernet.etherType == 0x0806 && hdr.arp.oper == 2) {
	     handle_arp.apply();
	 }
	 if (hdr.ethernet.etherType == 0x0800) {
             match_ipv4.apply();
         }
	 if (hdr.ethernet.etherType == 0x86DD && hdr.icmpv6.type == 135) {
             handle_ndp_broadcast.apply();
         }
	 if (hdr.ethernet.etherType == 0x86DD && (hdr.icmpv6.type == 128 || hdr.icmpv6.type == 129 || hdr.icmpv6.type == 136)) {
             match_ipv6.apply();
         }
      }*/
    
}



//Egress

control Ay_Egress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}


//Checksum

control Ay_UpdateChecksum(inout headers hdr, inout metadata meta) {
     apply {
	/*
	update_checksum(true,
        {   hdr.ipv4.version,
            hdr.ipv4.ihl,
            hdr.ipv4.diffserv,
            hdr.ipv4.totalLen,
            hdr.ipv4.identification,
            hdr.ipv4.flags,
            hdr.ipv4.fragOffset,
            hdr.ipv4.ttl,
            hdr.ipv4.protocol,
            hdr.ipv4.srcAddr,
            hdr.ipv4.dstAddr
        },hdr.ipv4.hdrChecksum, HashAlgorithm.csum16);
	*/
    }
}



//Deparser

control Ay_Deparser(packet_out packet, in headers hdr) {
    apply {
      packet.emit(hdr.ethernet);
      packet.emit(hdr.arp);
      packet.emit(hdr.arp_ipv4);
      packet.emit(hdr.ipv4);
      packet.emit(hdr.ipv6);
      packet.emit(hdr.srh);
      packet.emit(hdr.srh_address);
      packet.emit(hdr.srh_bdd);
      packet.emit(hdr.icmpv6);
      packet.emit(hdr.icmpv6_neigh);
      packet.emit(hdr.icmpv6_echo);
    }
}



//Switch

V1Switch(
Ay_Parser(),
Ay_VerifyChecksum(),
Ay_Ingress(),
Ay_Egress(),
Ay_UpdateChecksum(),
Ay_Deparser()
) main;
