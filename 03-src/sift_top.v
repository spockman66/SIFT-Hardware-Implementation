`timescale 1ns / 1ps
/*
	Input:
		时钟、复位
		din1: 串行图像数据
	Output:
		sift_dir: 图像梯度方向，用于后续特征向量
		sift_mag: 图像梯度幅值，用于后续特征向量
		out_feat_en:输出有效
		kp: 关键点标志
		kp_addr: 关键点地址
		complete1: 第一张图像（原图）处理完毕
		complete2: 第二张图像（降采样）处理完毕
	Description：

	Note:
		由于高斯卷积的对称性，2D高斯卷积拆分成两个1D卷积，首先合并同类项，再去做乘法，减少DSP的使用数量。
		采用并行流水线结构，提高数据吞吐量
		在卷积运算过程中，需要对窗口数据做乘加操作，因此使用了Fuxi提供的内置DSP IP。
*/


module sift_top(
	input clk_sys,
	input  wire flag_read,				 // 1时写入新图像，处理模块复位
	input  wire [7:0] img,
	
	output wire [17:0] addr_sift,		// 从FIFO读数据	
	output wire out_feat_en,
	output wire [5:0] sift_dir,
	output wire [7:0] sift_mag, 
	output wire kp,
	output wire [17:0] kp_addr,
	output wire complete1,
	output wire complete2				//完成第一，二组feat_detection
);
	
	//****************  RAM 初始存储地址 *************//	
	parameter [17:0] grad1_addr=3077;// 梯度初始保存地址
	parameter [17:0] dir1_addr=3077;// 方向初始保存地址
	
	parameter [17:0] grad2_addr=1541;// 梯度初始保存地址
	parameter [17:0] dir2_addr=1541;// 方向初始保存地址
	
	parameter [17:0] kp1_addr=3074; //KP1地址
	parameter [17:0] kp2_addr=1538; //KP2地址
	//****************   Clock  ********************//
	wire clk_100;
	wire clk_50;
	wire rst;
	
	reg rst_complete;
	
	pll_sift clk_manager(
		.clkin0		(clk_sys),		
		.clkout0	(clk_100),		//100M	
		.clkout1	(clk_50),		//50M
		.locked		(rst)
	);


	//******************* 主要模块变量 ****************************//
	wire rst_feat;
	wire [7:0] mag;
	wire [5:0] dir;
	
	// *************** 数据流控制********************************//
	assign sift_mag = mag;
	assign sift_dir = {2'b00,dir};
	assign kp_addr = complete1? ({addr_sift[17:10],addr_sift[8:1]}-1538):(addr_sift-3094); 


	//******************* 主要模块 ****************************//
	assign rst_feat= rst && rst_complete && (!flag_read);  	//往图像RAM中写数据时模块复位
															//1帧计算完成后复位所有模块
															//当需要读时，复位所有模块，此信号有效前，
															//complete2完成

	sift_feat U_sift_feat (
		.clk(clk_50),
		.rst(rst_feat), 		// low valid
		.din(img),
		.addr(addr_sift),			// cnt
		
		.dout_kp(kp), 
		.mag(mag), 
		.dir(dir), 
		.out_en(out_feat_en),
		.complete1(complete1),
		.complete2(complete2)
    );
	
	
	
always @(posedge clk_50 or negedge rst) begin
	if(~rst)
		rst_complete <= 1'b1;
	else
		rst_complete <= !complete2;
end
	

endmodule
