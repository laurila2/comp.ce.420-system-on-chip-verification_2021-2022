onerror resume
onbreak resume
onElabError resume

add wave -position insertpoint  \
sim:/decrypter_axi_tb_top/axi_interface/clk \
sim:/decrypter_axi_tb_top/axi_interface/rst_n

add wave -noupdate -divider -height 19 "Address channel"
add wave -position insertpoint  \
sim:/decrypter_axi_tb_top/axi_interface/waddr_channel/information \
sim:/decrypter_axi_tb_top/axi_interface/waddr_channel/valid \
sim:/decrypter_axi_tb_top/axi_interface/waddr_channel/ready

add wave -noupdate -divider -height 19 "Data channel"
add wave -position insertpoint  \
sim:/decrypter_axi_tb_top/axi_interface/wdata_channel/information \
sim:/decrypter_axi_tb_top/axi_interface/wdata_channel/valid \
sim:/decrypter_axi_tb_top/axi_interface/wdata_channel/ready

add wave -noupdate -divider -height 19 "Response channel"
add wave -position insertpoint  \
sim:/decrypter_axi_tb_top/axi_interface/wresp_channel/information \
sim:/decrypter_axi_tb_top/axi_interface/wresp_channel/valid \
sim:/decrypter_axi_tb_top/axi_interface/wresp_channel/ready



run -all
