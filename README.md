# P4-Application-aware

# 简介

基于SRv6技术和P4编程，通过在数据包中添加自定义标签，实现了网络的应用感知和流量调度功能

# 拓扑图

![物理拓扑](https://user-images.githubusercontent.com/99868289/154436994-feaf07f2-ed79-4835-9e05-0b12f63eba1b.PNG)

# 编译
p4c --target bmv2 --arch v1model --std p4-16 APP-aware.p4

# 运行

1.启动mininet：

$ sudo python start_net.py

2.下发流表：

$ sudo python cmd_add.py

3.打开h1和h2控制台：

$ xterm h1 & xterm h2

