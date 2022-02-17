# P4-Application-aware
第一步：
#编写P4代码 
$ gedit ***.p4 

第二步：
#p4c编译成json
$ p4c --target bmv2 --arch v1model --std p4-16 ***.p4

第三步：
#转到simple_switch文件夹中
$ cd p4/behavioral-model/targets/simple_switch
#启动bmv2的时候指定这个json
$ sudo ./simple_switch /home/p4/p4/tutorials/exercises/test2/test2.json
或
#启动mininet：
$ sudo python start_net.py

第四步：
#再启动一个控制台，启动控制程序（下流表）
$ simple_switch_CLI --thrift-port 9090 < cmd_scr1.txt
或
$ sudo python cmd_add.py

第五步：
#打开h1和h2控制台，做ping测试
$ xterm h1 h2
![image](https://user-images.githubusercontent.com/99868289/154435698-91aae4cc-e179-40d6-91fb-c51ce6045252.png)
