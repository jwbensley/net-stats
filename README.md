# net-stats

Bash scripts for monitor Linux network performance:

 * cpu_layout.sh -  List physical CPUs, logical CPUs and no of cores per phy CPU.
 * eth_speed.sh - Print interface Tx/Rx rate every 1 second, stats from NIC port.
 * if_speed.sh - Print interface Tx/Rx rate every 1 second, stats from Kernel
 * irq_balance.sh - Spread NIC port queue interrupts across CPU cores
 * irq_display.sh - List CPU cores NIC port interrupts are assigned to
 * rxq_display.sh - List interface Rx queue to CPU mapping (RPS)
 * soft_irqs.sh - Print NET_TX and NET_RX soft IRQ rate
 * soft_net.sh - Print packet drop rates for RPS
 * tx_inflight.sh - Print no. of in-flight packets in each NIC Tx queue
 * txq_display.sh - Print interface Tx queue to CPU mapping (XPS)
