# 概述

1. TCP/IP协议族中不同层次协议

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200622_131500.jpg">

2. 五种互联网地址

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200622_131504.jpg">

3. 数据进入协议栈时的封装过程

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200622_131608.jpg">

4. 以太网数据帧的分用过程

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200622_144036.jpg">

# 链路层

1. IEEE802.2/802.3和以太网的分装格式

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200622_125444.jpg">

2. SLIP：串行线路IP

3. 压缩的SLIP

4. PPP：点对点协议

   PPP数据帧格式

5. 数据链路层协议Ethernet（以太网）、IEEE802.3、PPP和HDLC

6. 以太网协议

   1. 6字节目的地址，6字节源地址，2字节类型
   2. 以太网包最小规定为64字节，不足的也会填充到64字节。以太网包的最大长度是1518字节，数据字段长度范围为46到1500，不够64需要补到64
   3. 类型字段，为2字节，用来标识上一层所使用的协议类型，如IP协议（0x0800）,ARP(0x0806)等。

## 环回接口

1. A类网络号127就是为环回接口预留的（127.0.0.1, localhost）

2. 环回接口处理IP数据报过程

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200622_130810.jpg">

## 最大传输单元MTU

1. 几种常见的最大传输单元
2. 路径MTU（通信要经过多个网络时，路径中最小MTU）

# IP：网际协议

***网络层有四个协议：ARP协议，IP协议，ICMP协议，IGMP协议。***

## IP首部

1. IP数据报格式及首部中的各字段

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200622_153848.jpg">

2. 目前版本号为4（IPv4）

3. 首部长度是指首部32bit字的数目，一般没有选项就是5（20字节）

4. 服务类型TOS，3bit优先权子字段，4bitTOS（最小延时，最大吞吐量，最高可靠性，最小费用），1bit保留位，必须为0

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200622_154507.jpg">

5. 总长度字段指整个IP数据报长度，最长可达65535字节

6. 标识字段唯一标识主机发送的每一份数据报，通常每发一份，其值加一

7. TTL生存时间，指经过的最多路由数，由源主机设置，一般32或64

8. 协议字段用来表示哪个协议向IP传送数据

9. 16位首部校验和，取反码相加，接收方结果应该全为1

## IP路由选择

1. 搜索路由表，寻找 与目的IP地址完全匹配的表目
2. 搜索路由表，寻找 与目的网络号相匹配的表目
3. 搜索路由表，寻找标为“默认”的表目

## 子网寻址

**A类和B类地址主机号太多，将主机好划分为子网号和主机号（子网对外部路由来说隐藏了内部网络组织）**

## 子网掩码

掩码是一个32bit的值，值为1的比特留给网络号和子网号，为0的比特留给主机号

# ARP: 地址解析协议

***ARP 的功能是在32bit的IP 地址和采用不同网络技术的硬件地址之间提供动态映射***

***点对点链路不使用ARP***

**RFC826**

1. 输入ftp命令“ftp主机名”时ARP操作

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200623_105231.jpg">

1. APR有高速缓存（arp -a查看，生存周期20分钟）

## APR的分组格式

1. 用于以太网的ARP请求或应答分组格式

   ***以太网中目的地址为全1的特殊地址是广播地址***

   <img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200623_111012.jpg">
   
   1. 硬件类型表示硬件地址类型，1表示以太网地址
   2. 协议类型表示要映射的协议地址类型
3. 硬件地址长度和协议地址长度（以字节为单位），对于以太网上IP地址的ARP请求和应答来说，他们的值是6和4
      1. 操作字段，ARP请求，ARP应答，RARP请求，RARP应答分别是1,2,3,4
   
   **ARP应答是直接送到请求端主机的，而不是广播的**

## ARP代理

***ARP请求由一个网络主机发往另外一个网络主机，连接两个网络的路由就可以回答该请求，该过程称作ARP代理（Proxy ARP）***

## 免费ARP

***主机发送ARP查找自己的IP地址，通常发生在系统引导期进行接口配置的时候***

1. 可以确定另外一个主机是否设置了相同的IP地址。
2. 可更新其他主机上高速缓存中旧的硬件地址。

# RARP：逆地址解析协议

**有磁盘的系统引导时，一般从磁盘中配置文件读取IP地址，无盘系统的RARP实现过程是从接口卡上读取唯一的硬件地址，然后发送一份RARP请求**

-----

# ICMP：Internet控制报文协议

**RFC792**

## ICMP报文类型

1. ICMP报文类型

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200623_174550.jpg">

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200623_174612.jpg">

## ICMP差错报文

**ICMP差错报文必须包括生成该差错报文的数据报IP首部，还必须至少包括跟在该IP首部后面的前8个字节**

## ICMP报文的4.4BSD处理

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200623_183918.jpg">

# Ping程序

**测试另外一台主机是否可达，程序发送ICMP回显报文给主机，并等待返回ICMP回显应答**

## ip记录选项

`-R`选项，经过的每个路由的ip多会方到选项字段，ip首部最长为`15×4=60字节`，ip首部20+RR选项3字节，剩下37字节可用，最多保存9个路由地址。

# Traceroute程序

***TTL字段的目的是防止数据报在选路时无休止地在网络中流动，TTL字段为0或1时不转发该数据报，并给信源机发一份ICMP超时报文***

- `Traceroute`程序发送TTL为1的数据包，处理该数据报的路由发挥ICMP超时报文，这样就获得了第一个路由地址
- 再发送TTL+1的数据报，获得下一个路由的地址
- `Traceroute`程序发送一份选择不可能作为UDP端口号的数据报给目的主机，因此当该数据报到达目的主机时会产生一份**“端口不可达”ICMP**报文，`Traceroute`程序通过判断是否是超时报文和端口不可达报文来判断什么时候结束。

## IP源站选路选项

- 严格的源站选路，发送端指明必须采用的确切路由，当下一个路由不在其直接链接的网络上时，返回**“源站路由失败”的ICMP差错报文**

- 宽松的源站选路，发送端指明要经过的路由，中间可以经过其他路由

**IP首部源站路由选项的通用格式**

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200624_160243.jpg">

- 宽松源站选路，code字段值为0x83
- 严格的源站选路，code字段为0x89

# IP选路

## 选路原理

**IP搜索路由表的几个步骤：**

- 搜索匹配的主机地址
- 搜索匹配的网络地址
- 搜索默认表项

## 查看路由表

`netstat -rn`

**Flags标记**

- U：该路由可用
- G：该路由是到一个网关（路由器）
- H：该路由是到一个主机
- D：该路由是由重定向报文创建
- M：该路由已经被重定向报文修改

## 没有到达目的地的路由

- IP数据包由主机产生，给应用程序返回一个错误
- IP数据包是转发的，给源端发送一份ICMP主机不可达的差错报文

## ICMP重定向差错

**让很小选路信息的主机逐渐建立更完善的路由表**

- 主机发送IP数据报到R1（默认路由）
- R1转发到R2,并检测到R2为目的接口
- R1发送一份ICMP重定向报文给主机，告诉他以后把数据报发送给R2而不是R1



## ICMP重定向报文格式

- ICMP重定向报文

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200628_111454.jpg">

- ICMP重定向报文不同代码值

  | 代码 | 描述                 |
  | :--: | -------------------- |
  |  0   | 网络重定向           |
  |  1   | 主机重定向           |
  |  2   | 服务类型和网络重定向 |
  |  3   | 服务类型和主机重定向 |

## ICMP路由发现报文

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200628_112658.jpg">

- 主机在引导以后要广播或多播传送一份路由器请求报文
- 路由器定期地广播或多播传送他们的路由器通告
- ICMP路由器请求报文格式
- ICMP路由器通告报文格式

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200628_112700.jpg">

# 动态选路协议

**IGP：内部网关协议**

- **RIP（Routing Infromation Protocol），选路信息协议**
- 路由器上有一个进程称为**路由守护程序（routing daemon）**，它运行选路协议
- 动态选路不改变内核在IP层的选路方式（搜索路由表），只是路由由守护程序动态增加和删除

## RIP：选路信息协议

**RIP报文包含在UDP数据报中**

- 命令字段：1请求（要求其他系统发送其全部或部分路由表），2应答，3、4舍弃，5轮询，6轮询表项
- 版本字段通常为1
- 紧跟其后的20字节指定地址系列（对于IP地址其值为2），IP地址以及相应的度量
- **最多可多达25个路由，保证RIP报文长度20 × 25 + 4 = 204, 小于512字节**

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200628_131322.jpg">

- RIP报文格式

### 度量

- 如果路由器通告他与其他网络路由的跳数为1,那么我们与那个网络的度量就是2,这是应为我们要发送报文到那个网络，我们必须经过那个路由器

- 度量为16表示无路由到达该IP地址
- RIP只能用在最大 跳数为15的AS（自治系统）中

## RIP版本2

**RIP-2利用了RIP-1必须为0的部分来传递一些额外的信息**

- RIP-2报文格式

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200628_145930.jpg">

## OSPF：开放最短路径

**OSPF是除RIP外的另外一个内部网关协议**

- OSPF直接使用IP，并不使用UDP或TCP，是一种链路状态协议

## BGP：边界网关协议

**BGP是一种不同自治系统的路由器之间进行通信的外部网关协议**

- RF1268
- RFC1467

## CIDR：无类型域间选路

# UDP：用户数据报协议

**UDP是一个简单的面向数据报的运输层协议，RFC768是UDP的正式规范**

- UDP首部格式

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200628_160329.jpg">

## UDP校验和

**UDP校验和覆盖UDP首部和UDP数据（UDP校验和是可选的，而TCP校验和是必须的）**

- 16位取反求和（和IP首部校验和计算方法一样），当数据长度为奇数时补零为偶数再计算
- UDP校验和计算过程中使用的各字段（伪首部）

<img src="https://media.githubusercontent.com/media/CONG2019/Images/master/tcpip/IMG_20200628_162343.jpg">

## IP分片

- IP数据报重新组装要求在下一站就重新组装，目的是使分片和组装过程对传输层透明
- 标志字段有一个位是不分片，IP数据报被丢弃并发送一个ICMP差错报文

- 除最后一片，其他每一片的数据部分必须为8字节的整数倍

- **IP数据报是指IP层端到端的传输单元**
- 分组是指IP层和链路层之间传输的数据单元

## ICMP不可达差错

- 当路由器收到一份需要分片的数据报，IP首部有设置了不分片，产生该报文
- 可以通过该报文发现路径的最小MTU













