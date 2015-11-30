################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

set design_name design_1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

create_bd_design $design_name

current_bd_design $design_name

set parentCell [get_bd_cells /]

# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
   puts "ERROR: Unable to find parent cell <$parentCell>!"
   return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
   puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
   return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# Set parent object as current
current_bd_instance $parentObj

# Add the Processor System and apply board preset
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]

# Configure the PS: Generate 200MHz clock, Enable HP0, Enable interrupts
startgroup
set_property -dict [list CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]
endgroup

# Connect the FCLK_CLK0 to the PS GP0
connect_bd_net [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK]

# Add the concat for the interrupts
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
endgroup
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins processing_system7_0/IRQ_F2P]
startgroup
set_property -dict [list CONFIG.NUM_PORTS {8}] [get_bd_cells xlconcat_0]
endgroup

# Add the AXI Ethernet IPs
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_0
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_1
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_2
endgroup
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:7.0 axi_ethernet_3
endgroup

# Configure ports 1,2 and 3 for "Don't include shared logic"
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_3]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.SupportLevel {0}] [get_bd_cells axi_ethernet_1]

# Configure all AXI Ethernet for RGMII
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_0]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_1]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_2]
set_property -dict [list CONFIG.PHY_TYPE {RGMII}] [get_bd_cells axi_ethernet_3]

startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_0/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_1/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_2/s_axi]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" Clk "Auto" }  [get_bd_intf_pins axi_ethernet_3/s_axi]
endgroup

# Make AXI Ethernet ports external: MDIO, RGMII and RESET
# MDIO
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/mdio] [get_bd_intf_ports mdio_io_port_0]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/mdio] [get_bd_intf_ports mdio_io_port_1]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/mdio] [get_bd_intf_ports mdio_io_port_2]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio_io_port_3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/mdio] [get_bd_intf_ports mdio_io_port_3]
endgroup
# RGMII
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_0
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/rgmii] [get_bd_intf_ports rgmii_port_0]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_1
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/rgmii] [get_bd_intf_ports rgmii_port_1]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/rgmii] [get_bd_intf_ports rgmii_port_2]
endgroup
startgroup
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_3
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/rgmii] [get_bd_intf_ports rgmii_port_3]
endgroup
# RESET
startgroup
create_bd_port -dir O -type rst reset_port_0
connect_bd_net [get_bd_pins /axi_ethernet_0/phy_rst_n] [get_bd_ports reset_port_0]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_1
connect_bd_net [get_bd_pins /axi_ethernet_1/phy_rst_n] [get_bd_ports reset_port_1]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_2
connect_bd_net [get_bd_pins /axi_ethernet_2/phy_rst_n] [get_bd_ports reset_port_2]
endgroup
startgroup
create_bd_port -dir O -type rst reset_port_3
connect_bd_net [get_bd_pins /axi_ethernet_3/phy_rst_n] [get_bd_ports reset_port_3]
endgroup


# Connect interrupts

connect_bd_net [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins xlconcat_0/In0]
connect_bd_net [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In1]
connect_bd_net [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins xlconcat_0/In2]
connect_bd_net [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins xlconcat_0/In3]
connect_bd_net [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins xlconcat_0/In4]
connect_bd_net [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins xlconcat_0/In5]
connect_bd_net [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins xlconcat_0/In6]
connect_bd_net [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins xlconcat_0/In7]

# Connect AXI Ethernet clocks

connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_1/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_1/gtx_clk90]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_2/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_2/gtx_clk90]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_3/gtx_clk]
connect_bd_net [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_3/gtx_clk90]

# Connect 200MHz AXI Ethernet ref_clk

connect_bd_net [get_bd_pins axi_ethernet_0/ref_clk] [get_bd_pins processing_system7_0/FCLK_CLK1]

# Create differential IO buffer for the Ethernet FMC 125MHz clock

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0
endgroup
connect_bd_net [get_bd_pins util_ds_buf_0/IBUF_OUT] [get_bd_pins axi_ethernet_0/gtx_clk]
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_p
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_P] [get_bd_ports ref_clk_p]
endgroup
startgroup
create_bd_port -dir I -from 0 -to 0 ref_clk_n
connect_bd_net [get_bd_pins /util_ds_buf_0/IBUF_DS_N] [get_bd_ports ref_clk_n]
endgroup

# Create Ethernet FMC reference clock output enable and frequency select

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_oe
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_oe
connect_bd_net [get_bd_pins /ref_clk_oe/dout] [get_bd_ports ref_clk_oe]
endgroup

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_fsel
endgroup
startgroup
create_bd_port -dir O -from 0 -to 0 ref_clk_fsel
connect_bd_net [get_bd_pins /ref_clk_fsel/dout] [get_bd_ports ref_clk_fsel]
endgroup

# Connect the loopbacks between MACs

# MAC1 rx -> MAC0 tx
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxd] [get_bd_intf_pins axi_ethernet_0/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_1/m_axis_rxs] [get_bd_intf_pins axi_ethernet_0/s_axis_txc]
# MAC3 rx -> MAC2 tx
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxd] [get_bd_intf_pins axi_ethernet_2/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_3/m_axis_rxs] [get_bd_intf_pins axi_ethernet_2/s_axis_txc]
# MAC0 rx -> MAC1 tx
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins axi_ethernet_1/s_axis_txc]
# MAC2 rx -> MAC3 tx
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins axi_ethernet_3/s_axis_txd]
connect_bd_intf_net [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins axi_ethernet_3/s_axis_txc]

# Connect the AXI Ethernet AXI streaming clocks

connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
connect_bd_net -net [get_bd_nets processing_system7_0_FCLK_CLK0] [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]

# Connect the AXI Ethernet resets

connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
connect_bd_net -net [get_bd_nets rst_processing_system7_0_100M_peripheral_aresetn] [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
