/*
 *  mxpidcpur_cpures.m
 *  MxPidCpuRange
 *
 *  Created by BitesPotatoBacks on 7/25/22.
 *  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
 */

#include <Foundation/Foundation.h>
#include <mach/processor_info.h>

float getres(int interval, natural_t cpus, int core)
{
    processor_info_array_t sample_a;
    processor_info_array_t sample_b;
    
    mach_msg_type_number_t  proc_msg_cnt;
    
    float total_use   = 0;
    float total_ticks = 0;
    float total_res   = 0;
    
    if (!(host_processor_info(mach_host_self(),
                              PROCESSOR_CPU_LOAD_INFO,
                              &cpus, &sample_a,
                              &proc_msg_cnt) == KERN_SUCCESS))
    { return -1; }
    
    [NSThread sleepForTimeInterval:(interval * 1e-3)];
    
    host_processor_info(mach_host_self(),
                        PROCESSOR_CPU_LOAD_INFO,
                        &cpus,
                        &sample_b,
                        &proc_msg_cnt);
    
    total_use = ((sample_b[(CPU_STATE_MAX * core) + CPU_STATE_USER] - sample_a[(CPU_STATE_MAX * core) + CPU_STATE_USER]) +
            (sample_b[(CPU_STATE_MAX * core) + CPU_STATE_SYSTEM] - sample_a[(CPU_STATE_MAX * core) + CPU_STATE_SYSTEM]) +
            (sample_b[(CPU_STATE_MAX * core) + CPU_STATE_NICE]   - sample_a[(CPU_STATE_MAX * core) + CPU_STATE_NICE]));

    total_ticks = total_use + (sample_b[(CPU_STATE_MAX * core) + CPU_STATE_IDLE] - sample_a[(CPU_STATE_MAX * core) + CPU_STATE_IDLE]);
    
    total_res = ((float) total_use / (float) total_ticks) * 100;
    
    if (isnormal(total_res))
        return total_res;
    else
        return 0;
}

int main(int argc, char * argv[])
{
    natural_t   cpus     = 8;
    int         cpu      = 1;
    int         interval = 256;
    
    if (argc == 4) {
        interval  =             [[NSString stringWithFormat:@"%s", argv[1], nil] intValue];
        cpus      =             [[NSString stringWithFormat:@"%s", argv[2], nil] intValue];
        cpu       = (natural_t) [[NSString stringWithFormat:@"%s", argv[3], nil] intValue];
    } else {
        fprintf(stdout, "incorrect number of args supplied");
        exit(1);
    }
    
    float res = getres(interval, cpus, cpu);
    
    if (res != -1)
        fprintf(stdout, "%.2f\n", res);
    else
        exit(1);
    
    return 0;
}
