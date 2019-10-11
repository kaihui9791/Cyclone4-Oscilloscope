# 目录
1. 介绍
2. 元器件选型
	* 2.1 FPGA芯片
	* 2.2 AD/DA芯片
	* 2.3 硬件实际图
3. 系统设计
	* 3.1 系统总框图
	* 3.2 二级FIFO
	* 3.3 FIFO控制模块
	* 3.4 触发控制模块
	* 3.5 UART控制模块
	* 3.6 上位机指令响应模块
	* 3.7 UART串口模块


## 介绍
这是一个基于Altera Cyclone4的数字示波器项目，使用AD9708进行模数转换以实现信号的量化，采样位数为8位，转换速率可达125MSPS。FPGA使用UART串口向上位机传输数据并响应上位机的指令，如复位，设定触发电平，设定触发方式等，本硬件系统搭配有配套的软件，可以在上位机直接显示和测量波形数据及配置示波器参数。

## 元器件选型
因为之前接触的都是Altera公司的FPGA芯片及比较熟悉Quartus的系统设计及仿真调试，并且测量由软件完成，硬件不需要进行大规模运算，所以选用中规模的FPGA系列-Cyclone4，当然因为Cyclone4本身的限制在仿真调试时有一定的阻碍。因为设计要求中规定了最低的转换速率及位数，选用符合规定的AD9708作为模数转换器。
### FPGA芯片
所使用的FPGA具体型号为EP4CE10F17C8，时钟频率50Mhz，搭载有一片PL2303用于进行串口通讯。
### AD/DA芯片
AD采用AD9708，8位最大转换速率可达125MSPS，允许输入电压范围为-5V~5V，此时输出的数字信号为0000 0000 ~ 1010 1011，最小量化单位0.0117V，共255份。
### 硬件实际图
AD/DA模块通过IO接口与FPGA相连。<br>
![Hardware img](https://github-img.oss-cn-chengdu.aliyuncs.com/img/Hardware.jpg)

## 系统设计
### 系统总框图
硬件系统主要由数据缓存（FIFO_1,FIFO_2），控制（command_platform,trigger_control,fifo_control,uart_control），UART串口（bps,uart_tx,uart_rx）以及调试（DA,sin512）组成，各模块之间的连线与关系可以见下图。<br>
![总框架图](https://github-img.oss-cn-chengdu.aliyuncs.com/img/总框架图大小调整.jpg)

### 二级FIFO
因为采样的速率等于输入AD的时钟频率，而UART数据传输是无论如何也达不到采样速率的，所以需要二级FIFO用来缓冲采样到的数据。本设计中当第一次满足触发条件时，第一级FIFO开始采样，当采样到512个点时（由计数器得到），开始向第二级FIFO发送数据，同时继续写入直到采样到1024个点，到达1024个点后，计数器清零，第一级FIFO关闭写入，仍然允许输出直到读空。第二级FIFO在接收到第一个数据时，允许读取，此时若UART处于空闲状态则开始发送数据，当读空后关闭读取，进入下一个循环或直接停止。
FIFO使用MegaWizard Plug-in Manager生成，fifo_1读写使用同一时钟，fifo_2读写使用不同时钟。<br>
![FIFO](https://github-img.oss-cn-chengdu.aliyuncs.com/img/FIFO.jpg)

### FIFO控制模块
FIFO控制模块用于控制二级FIFO的读写信号以及复位信号，内部使用一个计数器用于计算当前写入FIFO点的数量并根据计数值改变读写信号的值，其同时也受控于触发控制模块与上位机指令响应模块，触发控制模块提供采样开始信号，上位机指令响应模块指定采样方式。
FIFO控制模块代码详见Oscilloscope_project/fifo_control.v。<br>
![fifo_control](https://github-img.oss-cn-chengdu.aliyuncs.com/img/fifo_control.jpg)

### 触发控制模块
触发控制模块用于产生触发信号激活采样，其只在被测信号上升沿或者下降沿时拉高一个时钟周期，用于通知FIFO控制模块可以开始采样。实现方法为当数据大于设定的采样电平时，如为上升沿触发则赋值1，若为下降沿触发则赋值0。当数据小于设定的采样电平时，如为上升沿触发则赋值0，若为下降沿触发则赋值1。然后将此变量送入二级寄存器中，定义信号为第一级寄存器与上取反第二级寄存器。
触发控制模块代码详见Oscilloscope_project/trigger_control.v。<br>
![trigger](https://github-img.oss-cn-chengdu.aliyuncs.com/img/trigger.jpg)

### UART控制模块
UART控制模块用于控制数据发送，在设定采样模式后，只有在串口空闲且第二级FIFO不为空的情况下才开始发送数据。
UART控制模块代码详见Oscilloscope_project/uart_control.v。<br>
![UART_control](https://github-img.oss-cn-chengdu.aliyuncs.com/img/UART_control.jpg)

### 上位机指令响应模块
上位机指令响应模块接收来自上位机的指令，用于配置触发方式，复位，触发沿，与触发电平。因为00-AB为AD输出的范围，所以使用F0-F4作为可以使用的指令数值，F0:重置,F1:连续采样,F2:单次采样，F3:上升沿触发,F4:下降沿触发。
触发控制模块代码详见Oscilloscope_project/command_platform.v。<br>
![command](https://github-img.oss-cn-chengdu.aliyuncs.com/img/command.jpg)

### UART串口模块
UART串口模块由波特率发生器，接收与发送模块组成，传输方式为1位起始位+8位数据位+1位结束位，速度为9600bps。
UART串口模块代码详见Oscilloscope_project/bps.v，Oscilloscope_project/uart_rx.v，Oscilloscope_project/uart_tx.v。