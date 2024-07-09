/* Author: Deepak Choudhary */
/* Description:  IP Forwarding P4 program with MicroC sandbox program for Netronome smartNIC */

#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<16> TYPE_MetaData  = 0x2700;

const bit<32> REG_IDX = 0x1;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<16> egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

extern void populate_if_ts();

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header ipv4_t {
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
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header intrinsic_metadata_t {
    bit<64> ingress_global_timestamp; /* sec[63:32], nsec[31:0] */
    bit<64> current_global_timestamp; /* sec[63:32], nsec[31:0] */
}

header MetaData_t {
    bit<64> p2;
    bit<64> p3;
    bit<14> p4;
    bit<50> p5;
    bit<16> p6;
    bit<16> p7;
    bit<32> p10;
}

struct metadata {
    intrinsic_metadata_t intrinsic_metadata;
    /* empty */
}

struct headers {
    ethernet_t   ethernet;
    MetaData_t   Metadata;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_MetaData: parse_ipv4;
        }
    }

    state parse_ipv4 {
    		packet.extract(hdr.Metadata);
        transition accept;
    }


}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    
    register<bit<48>>(128) myRegg;
    bit<32> input_val = 0;
    counter(2, CounterType.packets) counter_1;
    counter(4, CounterType.bytes) counter_2;
    direct_counter(CounterType.packets_and_bytes) counter_set_source;

    action drop() {
        mark_to_drop();
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        standard_metadata.priority = 4;
        myRegg.write((bit<32>) 0x01, 4294967295);
        myRegg.write((bit<32>) 0x02, 4294967296);
        myRegg.write((bit<32>) 0x03, standard_metadata.ingress_global_timestamp);
        myRegg.write((bit<32>) 0x7F, 95);
        counter_1.count(1);
        counter_2.count(2);
        counter_set_source.count();
        hdr.Metadata.p2 = meta.intrinsic_metadata.ingress_global_timestamp;
        hdr.Metadata.p3 = meta.intrinsic_metadata.current_global_timestamp;
        /* hdr.Metadata.p10 = meta.intrinsic_metadata.current_global_timestamp; */        
	populate_if_ts();
    }

    table ipv4_lpm {
        key = {
            standard_metadata.ingress_port: exact;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
        counters = counter_set_source;
    }

    apply {
      ipv4_lpm.apply();
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {

    apply {
        hdr.Metadata.p4 = standard_metadata.packet_length;
        hdr.Metadata.p6 = standard_metadata.ingress_port;
        hdr.Metadata.p7 = standard_metadata.egress_port;
        //hdr.Metadata.p10 = standard_metadata.ingress_global_timestamp;
     }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.Metadata);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
