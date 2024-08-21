### Optimize system trino query
#### Cấu hình môi trường
    worker = 5
    ram: 16gb
    cpu: 8-10 cpu
    jvm xmx = 16gb x 70% = 11 gb
    query max per node = jvm x 0.7 = 7gb
    memory heap headroom per node = jvm x 0.3 = 3gb
    query.max-memory = 5 x max_mem/node = 5 x 7 = 35gb
    jvm > max_mem/node + heap_headroom/mode ===> 11gb > 7+3 =10 gb thỏa mãn
    general pool on each worker = 1x5 = 5gb
    query.max_totalmemory = 0.7 x 11 x5 =35gb
#### Note
    Trong trường hợp hết bộ nhớ:
        query.low_memory_killer_policy = none hoặc query
        task.low_memory_killer_policy = none
    Tràn memory vào đĩa
        config.properties
            spill-enable = true
            spiller-spill-path=...
            max-spill-per-node =10gb
            query-max-spill-per-node =5gb
    Disable linux swap
        sudo systemctl vm.swappiness = 0
#### Other
    Using cache distribute
        - alluxio
        - ....