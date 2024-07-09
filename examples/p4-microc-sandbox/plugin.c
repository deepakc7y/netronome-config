/* Copyright (C) 2017,  Netronome Systems, Inc.  All rights reserved. */

#include <stdint.h>
#include <nfp/me.h>
#include <nfp/mem_atomic.h>
#include <pif_common.h>
#include "pif_plugin.h"

int pif_plugin_populate_if_ts(EXTRACTED_HEADERS_T *headers,
                              MATCH_DATA_T *match_data)
{
    PIF_PLUGIN_Metadata_T *Metadata;
    uint32_t ingress_timestamp;

    Metadata = pif_plugin_hdr_get_Metadata(headers);
    /* we retrieve the 32-bit timestamp 8 bytes before the packet data
     * starting point (hence the minus 2)
     */
    ingress_timestamp = pif_pkt_info_global.p_timestamp;//((__mem uint32_t *)pif_pkt_info_global.pkt_buf)[-2];

    Metadata->p10 = ingress_timestamp;

    return PIF_PLUGIN_RETURN_FORWARD;
}