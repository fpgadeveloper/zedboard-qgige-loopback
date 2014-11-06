
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg484-1
#    set_property BOARD_PART em.avnet.com:zed:part0:1.0 [current_project]


# CHANGE DESIGN NAME HERE
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} ne "" && ${cur_design} eq ${design_name} } {

   # Checks if design is empty or not
   if { $list_cells ne "" } {
      set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
      set nRet 1
   } else {
      puts "INFO: Constructing design in IPI design <$design_name>..."
   }
} elseif { ${cur_design} ne "" && ${cur_design} ne ${design_name} } {

   if { $list_cells eq "" } {
      puts "INFO: You have an empty design <${cur_design}>. Will go ahead and create design..."
   } else {
      set errMsg "ERROR: Design <${cur_design}> is not empty! Please do not source this script on non-empty designs."
      set nRet 1
   }
} else {

   if { [get_files -quiet ${design_name}.bd] eq "" } {
      puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

      create_bd_design $design_name

      puts "INFO: Making design <$design_name> as current_bd_design."
      current_bd_design $design_name

   } else {
      set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
      set nRet 3
   }

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

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


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set mdio_io_port_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_0 ]
  set mdio_io_port_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_1 ]
  set mdio_io_port_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_2 ]
  set mdio_io_port_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_io:1.0 mdio_io_port_3 ]
  set rgmii_port_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_0 ]
  set rgmii_port_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_1 ]
  set rgmii_port_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_2 ]
  set rgmii_port_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:rgmii_rtl:1.0 rgmii_port_3 ]

  # Create ports
  set ref_clk_fsel [ create_bd_port -dir O -from 0 -to 0 ref_clk_fsel ]
  set ref_clk_n [ create_bd_port -dir I -from 0 -to 0 ref_clk_n ]
  set ref_clk_oe [ create_bd_port -dir O -from 0 -to 0 ref_clk_oe ]
  set ref_clk_p [ create_bd_port -dir I -from 0 -to 0 ref_clk_p ]
  set reset_port_0 [ create_bd_port -dir O -type rst reset_port_0 ]
  set reset_port_1 [ create_bd_port -dir O -type rst reset_port_1 ]
  set reset_port_2 [ create_bd_port -dir O -type rst reset_port_2 ]
  set reset_port_3 [ create_bd_port -dir O reset_port_3 ]

  # Create instance: axi_ethernet_0, and set properties
  set axi_ethernet_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.1 axi_ethernet_0 ]
  set_property -dict [ list CONFIG.PHY_TYPE {RGMII}  ] $axi_ethernet_0

  # Create instance: axi_ethernet_1, and set properties
  set axi_ethernet_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.1 axi_ethernet_1 ]
  set_property -dict [ list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}  ] $axi_ethernet_1

  # Create instance: axi_ethernet_2, and set properties
  set axi_ethernet_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.1 axi_ethernet_2 ]
  set_property -dict [ list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}  ] $axi_ethernet_2

  # Create instance: axi_ethernet_3, and set properties
  set axi_ethernet_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_ethernet:6.1 axi_ethernet_3 ]
  set_property -dict [ list CONFIG.PHY_TYPE {RGMII} CONFIG.SupportLevel {0}  ] $axi_ethernet_3

  # Create instance: idelay_ctrl_0, and set properties
  set idelay_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:idelay_ctrl:1.0 idelay_ctrl_0 ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.4 processing_system7_0 ]
  set_property -dict [ list CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} CONFIG.PCW_EN_CLK1_PORT {1} CONFIG.PCW_EN_CLK2_PORT {1} CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {125} CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {200} CONFIG.PCW_IRQ_F2P_INTR {1} CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_USE_S_AXI_HP0 {0} CONFIG.preset {ZedBoard*}  ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list CONFIG.NUM_MI {8}  ] $processing_system7_0_axi_periph

  # Create instance: ref_clk_fsel, and set properties
  set ref_clk_fsel [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_fsel ]
  set_property -dict [ list CONFIG.CONST_VAL {1}  ] $ref_clk_fsel

  # Create instance: ref_clk_oe, and set properties
  set ref_clk_oe [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 ref_clk_oe ]
  set_property -dict [ list CONFIG.CONST_WIDTH {1}  ] $ref_clk_oe

  # Create instance: rst_processing_system7_0_100M, and set properties
  set rst_processing_system7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_100M ]

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:1.0 util_ds_buf_0 ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list CONFIG.NUM_PORTS {8}  ] $xlconcat_0

  # Create interface connections
  connect_bd_intf_net -intf_net axi_ethernet_0_m_axis_rxd [get_bd_intf_pins axi_ethernet_0/m_axis_rxd] [get_bd_intf_pins axi_ethernet_1/s_axis_txd]
  connect_bd_intf_net -intf_net axi_ethernet_0_mdio [get_bd_intf_ports mdio_io_port_0] [get_bd_intf_pins axi_ethernet_0/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_0_rgmii [get_bd_intf_ports rgmii_port_0] [get_bd_intf_pins axi_ethernet_0/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_1_m_axis_rxs [get_bd_intf_pins axi_ethernet_0/s_axis_txc] [get_bd_intf_pins axi_ethernet_1/m_axis_rxs]
  connect_bd_intf_net -intf_net axi_ethernet_1_mdio [get_bd_intf_ports mdio_io_port_1] [get_bd_intf_pins axi_ethernet_1/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_1_rgmii [get_bd_intf_ports rgmii_port_1] [get_bd_intf_pins axi_ethernet_1/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_2_m_axis_rxd [get_bd_intf_pins axi_ethernet_2/m_axis_rxd] [get_bd_intf_pins axi_ethernet_3/s_axis_txd]
  connect_bd_intf_net -intf_net axi_ethernet_2_m_axis_rxs [get_bd_intf_pins axi_ethernet_2/m_axis_rxs] [get_bd_intf_pins axi_ethernet_3/s_axis_txc]
  connect_bd_intf_net -intf_net axi_ethernet_2_mdio [get_bd_intf_ports mdio_io_port_2] [get_bd_intf_pins axi_ethernet_2/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_2_rgmii [get_bd_intf_ports rgmii_port_2] [get_bd_intf_pins axi_ethernet_2/rgmii]
  connect_bd_intf_net -intf_net axi_ethernet_3_m_axis_rxd [get_bd_intf_pins axi_ethernet_2/s_axis_txd] [get_bd_intf_pins axi_ethernet_3/m_axis_rxd]
  connect_bd_intf_net -intf_net axi_ethernet_3_m_axis_rxs [get_bd_intf_pins axi_ethernet_2/s_axis_txc] [get_bd_intf_pins axi_ethernet_3/m_axis_rxs]
  connect_bd_intf_net -intf_net axi_ethernet_3_mdio [get_bd_intf_ports mdio_io_port_3] [get_bd_intf_pins axi_ethernet_3/mdio]
  connect_bd_intf_net -intf_net axi_ethernet_3_rgmii [get_bd_intf_ports rgmii_port_3] [get_bd_intf_pins axi_ethernet_3/rgmii]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins axi_ethernet_0/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M01_AXI [get_bd_intf_pins axi_ethernet_1/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M02_AXI [get_bd_intf_pins axi_ethernet_2/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M03_AXI [get_bd_intf_pins axi_ethernet_3/s_axi] [get_bd_intf_pins processing_system7_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net s_axis_txc_1 [get_bd_intf_pins axi_ethernet_0/m_axis_rxs] [get_bd_intf_pins axi_ethernet_1/s_axis_txc]
  connect_bd_intf_net -intf_net s_axis_txd_1 [get_bd_intf_pins axi_ethernet_0/s_axis_txd] [get_bd_intf_pins axi_ethernet_1/m_axis_rxd]

  # Create port connections
  connect_bd_net -net IBUF_DS_N_1 [get_bd_ports ref_clk_n] [get_bd_pins util_ds_buf_0/IBUF_DS_N]
  connect_bd_net -net IBUF_DS_P_1 [get_bd_ports ref_clk_p] [get_bd_pins util_ds_buf_0/IBUF_DS_P]
  connect_bd_net -net axi_ethernet_0_gtx_clk90_out [get_bd_pins axi_ethernet_0/gtx_clk90_out] [get_bd_pins axi_ethernet_1/gtx_clk90] [get_bd_pins axi_ethernet_2/gtx_clk90] [get_bd_pins axi_ethernet_3/gtx_clk90]
  connect_bd_net -net axi_ethernet_0_gtx_clk_out [get_bd_pins axi_ethernet_0/gtx_clk_out] [get_bd_pins axi_ethernet_1/gtx_clk] [get_bd_pins axi_ethernet_2/gtx_clk] [get_bd_pins axi_ethernet_3/gtx_clk]
  connect_bd_net -net axi_ethernet_0_interrupt [get_bd_pins axi_ethernet_0/interrupt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_ethernet_0_mac_irq [get_bd_pins axi_ethernet_0/mac_irq] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_ethernet_0_phy_rst_n [get_bd_ports reset_port_0] [get_bd_pins axi_ethernet_0/phy_rst_n]
  connect_bd_net -net axi_ethernet_1_interrupt [get_bd_pins axi_ethernet_1/interrupt] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net axi_ethernet_1_mac_irq [get_bd_pins axi_ethernet_1/mac_irq] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net axi_ethernet_1_phy_rst_n [get_bd_ports reset_port_1] [get_bd_pins axi_ethernet_1/phy_rst_n]
  connect_bd_net -net axi_ethernet_2_interrupt [get_bd_pins axi_ethernet_2/interrupt] [get_bd_pins xlconcat_0/In5]
  connect_bd_net -net axi_ethernet_2_mac_irq [get_bd_pins axi_ethernet_2/mac_irq] [get_bd_pins xlconcat_0/In4]
  connect_bd_net -net axi_ethernet_2_phy_rst_n [get_bd_ports reset_port_2] [get_bd_pins axi_ethernet_2/phy_rst_n]
  connect_bd_net -net axi_ethernet_3_interrupt [get_bd_pins axi_ethernet_3/interrupt] [get_bd_pins xlconcat_0/In7]
  connect_bd_net -net axi_ethernet_3_mac_irq [get_bd_pins axi_ethernet_3/mac_irq] [get_bd_pins xlconcat_0/In6]
  connect_bd_net -net axi_ethernet_3_phy_rst_n [get_bd_ports reset_port_3] [get_bd_pins axi_ethernet_3/phy_rst_n]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins axi_ethernet_0/axis_clk] [get_bd_pins axi_ethernet_0/s_axi_lite_clk] [get_bd_pins axi_ethernet_1/axis_clk] [get_bd_pins axi_ethernet_1/s_axi_lite_clk] [get_bd_pins axi_ethernet_2/axis_clk] [get_bd_pins axi_ethernet_2/s_axi_lite_clk] [get_bd_pins axi_ethernet_3/axis_clk] [get_bd_pins axi_ethernet_3/s_axi_lite_clk] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/M01_ACLK] [get_bd_pins processing_system7_0_axi_periph/M02_ACLK] [get_bd_pins processing_system7_0_axi_periph/M03_ACLK] [get_bd_pins processing_system7_0_axi_periph/M04_ACLK] [get_bd_pins processing_system7_0_axi_periph/M05_ACLK] [get_bd_pins processing_system7_0_axi_periph/M06_ACLK] [get_bd_pins processing_system7_0_axi_periph/M07_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_CLK2 [get_bd_pins axi_ethernet_0/ref_clk] [get_bd_pins idelay_ctrl_0/ref_clk_i] [get_bd_pins processing_system7_0/FCLK_CLK2]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_100M/ext_reset_in]
  connect_bd_net -net ref_clk_fsel_dout [get_bd_ports ref_clk_fsel] [get_bd_pins ref_clk_fsel/dout]
  connect_bd_net -net ref_clk_oe_dout [get_bd_ports ref_clk_oe] [get_bd_pins ref_clk_oe/dout]
  connect_bd_net -net rst_processing_system7_0_100M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_100M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_aresetn [get_bd_pins axi_ethernet_0/axi_rxd_arstn] [get_bd_pins axi_ethernet_0/axi_rxs_arstn] [get_bd_pins axi_ethernet_0/axi_txc_arstn] [get_bd_pins axi_ethernet_0/axi_txd_arstn] [get_bd_pins axi_ethernet_0/s_axi_lite_resetn] [get_bd_pins axi_ethernet_1/axi_rxd_arstn] [get_bd_pins axi_ethernet_1/axi_rxs_arstn] [get_bd_pins axi_ethernet_1/axi_txc_arstn] [get_bd_pins axi_ethernet_1/axi_txd_arstn] [get_bd_pins axi_ethernet_1/s_axi_lite_resetn] [get_bd_pins axi_ethernet_2/axi_rxd_arstn] [get_bd_pins axi_ethernet_2/axi_rxs_arstn] [get_bd_pins axi_ethernet_2/axi_txc_arstn] [get_bd_pins axi_ethernet_2/axi_txd_arstn] [get_bd_pins axi_ethernet_2/s_axi_lite_resetn] [get_bd_pins axi_ethernet_3/axi_rxd_arstn] [get_bd_pins axi_ethernet_3/axi_rxs_arstn] [get_bd_pins axi_ethernet_3/axi_txc_arstn] [get_bd_pins axi_ethernet_3/axi_txd_arstn] [get_bd_pins axi_ethernet_3/s_axi_lite_resetn] [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M01_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M02_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M03_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M04_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M05_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M06_ARESETN] [get_bd_pins processing_system7_0_axi_periph/M07_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_100M/peripheral_aresetn]
  connect_bd_net -net rst_processing_system7_0_100M_peripheral_reset [get_bd_pins idelay_ctrl_0/rst] [get_bd_pins rst_processing_system7_0_100M/peripheral_reset]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT [get_bd_pins axi_ethernet_0/gtx_clk] [get_bd_pins util_ds_buf_0/IBUF_OUT]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins processing_system7_0/IRQ_F2P] [get_bd_pins xlconcat_0/dout]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_0/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_0/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_1/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_1/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_2/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_2/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x10000 -offset 0x0 [get_bd_addr_spaces axi_ethernet_3/eth_buf/S_AXI_2TEMAC] [get_bd_addr_segs axi_ethernet_3/eth_mac/s_axi/Reg] SEG_eth_mac_Reg
  create_bd_addr_seg -range 0x40000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_0/eth_buf/S_AXI/REG] SEG_eth_buf_REG
  create_bd_addr_seg -range 0x40000 -offset 0x43C40000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_1/eth_buf/S_AXI/REG] SEG_eth_buf_REG1
  create_bd_addr_seg -range 0x40000 -offset 0x43C80000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_2/eth_buf/S_AXI/REG] SEG_eth_buf_REG2
  create_bd_addr_seg -range 0x40000 -offset 0x43CC0000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_ethernet_3/eth_buf/S_AXI/REG] SEG_eth_buf_REG3
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


