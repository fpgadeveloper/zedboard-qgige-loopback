/******************************************************************************
 *
 * (c) Copyright 2013 Xilinx, Inc. All rights reserved.
 *
 * This file contains confidential and proprietary information of Xilinx, Inc.
 * and is protected under U.S. and international copyright and other
 * intellectual property laws.
 *
 * DISCLAIMER
 * This disclaimer is not a license and does not grant any rights to the
 * materials distributed herewith. Except as otherwise provided in a valid
 * license issued to you by Xilinx, and to the maximum extent permitted by
 * applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL
 * FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS,
 * IMPLIED, OR STATUTORY, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
 * MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE;
 * and (2) Xilinx shall not be liable (whether in contract or tort, including
 * negligence, or under any other theory of liability) for any loss or damage
 * of any kind or nature related to, arising under or in connection with these
 * materials, including for any direct, or any indirect, special, incidental,
 * or consequential loss or damage (including loss of data, profits, goodwill,
 * or any type of loss or damage suffered as a result of any action brought by
 * a third party) even if such damage or loss was reasonably foreseeable or
 * Xilinx had been advised of the possibility of the same.
 *
 * CRITICAL APPLICATIONS
 * Xilinx products are not designed or intended to be fail-safe, or for use in
 * any application requiring fail-safe performance, such as life-support or
 * safety devices or systems, Class III medical devices, nuclear facilities,
 * applications related to the deployment of airbags, or any other applications
 * that could lead to death, personal injury, or severe property or
 * environmental damage (individually and collectively, "Critical
 * Applications"). Customer assumes the sole risk and liability of any use of
 * Xilinx products in Critical Applications, subject only to applicable laws
 * and regulations governing limitations on product liability.
 *
 * THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE
 * AT ALL TIMES.
 *
 ******************************************************************************/
/*****************************************************************************/
/**
 * @file i2c_lib.c
 *
 * This file contains library functions to initialize, control and access
 * IIC devices.
 *
 * <pre>
 * MODIFICATION HISTORY:
 *
 * Ver   Who  Date	 Changes
 * ----- ---- -------- ---------------------------------------------------------
 * 1.0   srt  10/19/13 Initial Version
 *
 * </pre>
 *
 ******************************************************************************/

/***************************** Include Files *********************************/
#include "xparameters.h"
#if XPAR_GIGE_PCS_PMA_CORE_PRESENT == 1
#include "xil_exception.h"
#include "xil_printf.h"
#include "xiicps.h"
#include "sleep.h"
#include "xscugic.h"

/************************** Constant Definitions *****************************/
#define IIC_DEVICE_ID   XPAR_XIICPS_0_DEVICE_ID
#define XIIC	XIicPs
#define XIICCFG	XIicPs_Config
#define I2cSetStatusHandler	XIicPs_SetStatusHandler
#define	I2cLookupConfig		XIicPs_LookupConfig
#define	I2cCfgInitialize	XIicPs_CfgInitialize
#define INTC_DEVICE_ID	XPAR_SCUGIC_SINGLE_DEVICE_ID
#define IIC_INTR_ID	XPAR_XIICPS_0_INTR
#define INTC_HANDLER	XScuGic_InterruptHandler
#define IIC_HANDLER	XIicPs_IntrHandler
#define INTC	XScuGic
#define IIC_SCLK_RATE           100000
/**************************** Type Definitions *******************************/
typedef struct {
	XIIC I2cInstance;
	INTC IntcInstance;
	volatile u8 TransmitComplete;   /* Flag to check completion of Transmission */
	volatile u8 ReceiveComplete;    /* Flag to check completion of Reception */
	volatile u32 TotalErrorCount;
} XIIC_LIB;
/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/
int I2cPhyWrite(XIIC_LIB *I2cLibPtr, u8 PhyAddr, u8 Reg, u16 Data, u16 SlaveAddr);
int I2cPhyRead(XIIC_LIB *I2cLibPtr, u8 PhyAddr, u8 Reg, u16 *Data, u16 SlaveAddr);
int I2cSetupHardware(XIIC_LIB *I2cLibPtr);
int I2cWriteData(XIIC_LIB *I2cLibPtr, u8 *WrBuffer, u16 ByteCount, u16 SlaveAddr);
int I2cReadData(XIIC_LIB *I2cLibPtr, u8 *RdBuffer, u16 ByteCount, u16 SlaveAddr);
static int SetupInterruptSystem(XIIC_LIB *I2cLibPtr);
static void StatusHandler(XIIC_LIB *I2cLibPtr, int Event);

/************************* Global Definitions *****************************/

/************************** Function Definitions *****************************/

/*****************************************************************************/
/**
 * This function configures the IIC hardware.
 *
 * @param	I2cLibPtr contains a pointer to the instance of the IIC library
 *
 * @return	XST_SUCCESS if successful else XST_FAILURE.
 *
 ******************************************************************************/
int I2cSetupHardware(XIIC_LIB *I2cLibPtr)
{
	int Status;
	XIICCFG *ConfigPtr;
	XIIC *I2cInstancePtr;

	I2cInstancePtr = &I2cLibPtr->I2cInstance;

	/*
	 * Initialize the IIC driver so that it is ready to use.
	 */
	ConfigPtr = I2cLookupConfig(IIC_DEVICE_ID);
	if (ConfigPtr == NULL) {
		return XST_FAILURE;
	}

	Status = I2cCfgInitialize(I2cInstancePtr, ConfigPtr,
			ConfigPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * GPIO Code to pull MUX out of reset.
	 */
	Xil_Out32(0xe000a204, 0x2000);
	Xil_Out32(0xe000a208, 0x2000);
	Xil_Out32(0xe000a040, 0x2000);

	/*
	 * Setup the Interrupt System.
	 */
	Status = SetupInterruptSystem(I2cLibPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	I2cSetStatusHandler(I2cInstancePtr, I2cLibPtr, (IIC_HANDLER) StatusHandler);

	/*
	 * Set the IIC serial clock rate.
	 */
	XIicPs_SetSClk(I2cInstancePtr, IIC_SCLK_RATE);

	I2cLibPtr->TotalErrorCount = 0;
	I2cLibPtr->TransmitComplete = FALSE;
	I2cLibPtr->ReceiveComplete = FALSE;

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
 * This function writes data to the PHY.
 *
 * @param	I2cLibPtr contains a pointer to the instance of the IIC library
 * @param 	PhyAddr is the address of PHY to be written
 * @param	Reg is the register address to be written to
 * @param 	Data is the pointer which contains the data to be written
 * @param	SlaveAddr is the address of the slave we are sending to.
 *
 * @return	XST_SUCCESS if successful else XST_FAILURE.
 *
 ******************************************************************************/
int I2cPhyWrite(XIIC_LIB *I2cLibPtr, u8 PhyAddr, u8 Reg, u16 Data, u16 SlaveAddr)
{
	int Status;
	u8 WrBuffer[3];

	WrBuffer[0] = Reg;
	WrBuffer[1] = Data >> 8;
	WrBuffer[2] = Data;

	Status = I2cWriteData(I2cLibPtr, WrBuffer, 3, SlaveAddr);
	if (Status != XST_SUCCESS) {
		xil_printf("PhyWrite: Writing data failed\n\r");
		return Status;
	}

	return Status;
}

/*****************************************************************************/
/**
 * This function reads data from the PHY.
 *
 * @param	I2cLibPtr contains a pointer to the instance of the IIC library
 * @param 	PhyAddr is the address of PHY to be read from
 * @param	Reg is the register address to be read from
 * @param 	Data is the pointer which stores the data read
 * @param	SlaveAddr is the address of the slave we are sending to.
 *
 * @return	XST_SUCCESS if successful else XST_FAILURE.
 *
 ******************************************************************************/
int I2cPhyRead(XIIC_LIB *I2cLibPtr, u8 PhyAddr, u8 Reg, u16 *Data, u16 SlaveAddr)
{
	int Status;
	u8 WrBuffer[2];
	u8 RdBuffer[2];

	WrBuffer[0] = Reg;

	Status = I2cWriteData(I2cLibPtr, WrBuffer, 1, SlaveAddr);
	if (Status != XST_SUCCESS) {
		xil_printf("PhyWrite: Writing data failed\n\r");
		return Status;
	}

	Status = I2cReadData(I2cLibPtr, RdBuffer, 2, SlaveAddr);
	if (Status != XST_SUCCESS) {
		xil_printf("PhyRead: Reading data failed\n\r");
		return Status;
	}

	*Data = RdBuffer[0] << 8 | RdBuffer[1];

	return Status;
}

/*****************************************************************************/
/**
 * This function writes a buffer of data to the IIC Device.
 *
 * @param	I2cLibPtr contains a pointer to the instance of the IIC library
 * @param 	WrBuffer is the buffer which contains data to be written
 * @param	ByteCount contains the number of bytes in the buffer to be
 *			written.
 * @param	SlaveAddr is the address of the slave we are sending to.
 *
 * @return	XST_SUCCESS if successful else XST_FAILURE.
 *
 ******************************************************************************/
int I2cWriteData(XIIC_LIB *I2cLibPtr, u8 *WrBuffer, u16 ByteCount,
		u16 SlaveAddr)
{
	XIIC *I2cInstancePtr;

	I2cInstancePtr = &I2cLibPtr->I2cInstance;

	I2cLibPtr->TransmitComplete = FALSE;

	/*
	 * Send the Data.
	 */
	XIicPs_MasterSend(I2cInstancePtr, WrBuffer, ByteCount, SlaveAddr);

	/*
	 * Wait for the entire buffer to be sent, letting the interrupt
	 * processing work in the background, this function may get
	 * locked up in this loop if the interrupts are not working
	 * correctly.
	 */
	while (I2cLibPtr->TransmitComplete == FALSE) {
		if (0 != I2cLibPtr->TotalErrorCount) {
			xil_printf("I2cWriteData: Failed due to errors\n\r");
			return XST_FAILURE;
		}
	}

	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(I2cInstancePtr));

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
 * This function read data from the IIC Device.
 *
 * @param	I2cLibPtr contains a pointer to the instance of the IIC library
 * @param 	RdBuffer is the buffer into which data read
 * @param	ByteCount contains the number of bytes in the buffer to be
 *			written.
 * @param	SlaveAddr is the address of the slave we are sending to.
 *
 * @return	XST_SUCCESS if successful else XST_FAILURE.
 *
 ******************************************************************************/
int I2cReadData(XIIC_LIB *I2cLibPtr, u8 *RdBuffer, u16 ByteCount, u16 SlaveAddr)
{
	XIIC *I2cInstancePtr;

	I2cInstancePtr = &I2cLibPtr->I2cInstance;

	I2cLibPtr->ReceiveComplete = FALSE;

	/*
	 * Receive the Data.
	 */
	XIicPs_MasterRecv(I2cInstancePtr, RdBuffer, ByteCount, SlaveAddr);

	while (I2cLibPtr->ReceiveComplete == FALSE) {
		if (0 != I2cLibPtr->TotalErrorCount) {
			xil_printf("I2cReadData: Failed due to errors %d\n\r",
					I2cLibPtr->TotalErrorCount);
			return XST_FAILURE;
		}
	}

	/*
	 * Wait until bus is idle to start another transfer.
	 */
	while (XIicPs_BusIsBusy(I2cInstancePtr))
		;

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
 * This function setups the interrupt system so interrupts can occur for the
 * IIC device. The function is application-specific since the actual system may
 * or may not have an interrupt controller. The IIC device could be directly
 * connected to a processor without an interrupt controller. The user should
 * modify this function to fit the application.
 *
 * @param	IicInstPtr contains a pointer to the instance of the IIC device
 *		which is going to be connected to the interrupt controller.
 *
 * @return	XST_SUCCESS if successful else XST_FAILURE.
 *
 * @note		None.
 *
 ******************************************************************************/
static int SetupInterruptSystem(XIIC_LIB *I2cLibPtr)
{
	int Status;
	XIIC *I2cInstancePtr;
	INTC *IntcPtr;

	I2cInstancePtr = &I2cLibPtr->I2cInstance;
	IntcPtr = &I2cLibPtr->IntcInstance;

	XScuGic_Config *IntcConfig;

	/*
	 * Initialize the interrupt controller driver so that it is ready to
	 * use.
	 */
	IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(IntcPtr, IntcConfig,
			IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XScuGic_SetPriorityTriggerType(IntcPtr, IIC_INTR_ID, 0xA0, 0x3);

	/*
	 * Connect the interrupt handler that will be called when an
	 * interrupt occurs for the device.
	 */
	Status = XScuGic_Connect(IntcPtr, IIC_INTR_ID,
			(Xil_InterruptHandler) XIicPs_MasterInterruptHandler,
			I2cInstancePtr);
	if (Status != XST_SUCCESS) {
		return Status;
	}

	/*
	 * Enable the interrupt for the IIC device.
	 */
	XScuGic_Enable(IntcPtr, IIC_INTR_ID);

	/*
	 * Initialize the exception table and register the interrupt
	 * controller handler with the exception table
	 */
	Xil_ExceptionInit();

	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) INTC_HANDLER, IntcPtr);

	/* Enable non-critical exceptions */Xil_ExceptionEnable();

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
 * This Status handler is called asynchronously from an interrupt
 * context and indicates the events that have occurred.
 *
 * @param	InstancePtr is a pointer to the IIC driver instance for which
 *		the handler is being called for.
 * @param	Event indicates the condition that has occurred.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
static void StatusHandler(XIIC_LIB *I2cLibPtr, int Event)
{
	/*
	 * All of the data transfer has been finished.
	 */
	if (0 != (Event & XIICPS_EVENT_COMPLETE_RECV)) {
		I2cLibPtr->ReceiveComplete = TRUE;
	} else if (0 != (Event & XIICPS_EVENT_COMPLETE_SEND)) {
		I2cLibPtr->TransmitComplete = TRUE;
	} else if (0 == (Event & XIICPS_EVENT_SLAVE_RDY)) {
		/*
		 * If it is other interrupt but not slave ready interrupt, it is
		 * an error.
		 * Data was received with an error.
		 */
		I2cLibPtr->TotalErrorCount++;
	}
}
#endif