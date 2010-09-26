/**
 * @file powerspan.c Source file for PowerSpan II code.
 */

/*
 * (C) Copyright 2005
 * AMIRIX Systems Inc.
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

/**
 * Write one byte with byte swapping.
 * @param  addr [IN] the address to write to
 * @param  val  [IN] the value to write
 */
void write1(unsigned long addr, unsigned char val) {
    volatile unsigned char* p = (volatile unsigned char*)addr;
#if defined(VERBOSITY)
    if(gVerbosityLevel > 1){
        printf("write1: addr=%08x val=%02x\n", addr, val);
    }
#endif
    *p = val;
    PSII_SYNC();
}

/**
 * Read one byte with byte swapping.
 * @param  addr  [IN] the address to read from
 * @return the value at addr
 */
unsigned char read1(unsigned long addr) {
    unsigned char val;
    volatile unsigned char* p = (volatile unsigned char*)addr;

    val = *p;
    PSII_SYNC();
#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("read1: addr=%08x val=%02x\n", addr, val);
    }
#endif
    return val;
}

/**
 * Write one 2-byte word with byte swapping.
 * @param  addr  [IN] the address to write to
 * @param  val   [IN] the value to write
 */
void write2(unsigned long addr, unsigned short val) {
    volatile unsigned short* p = (volatile unsigned short*)addr;

#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("write2: addr=%08x val=%04x -> *p=%04x\n", addr, val,
                ((val & 0xFF00) >> 8) | ((val & 0x00FF) << 8));
        }
#endif
    *p = ((val & 0xFF00) >> 8) | ((val & 0x00FF) << 8);
    PSII_SYNC();
}

/**
 * Read one 2-byte word with byte swapping.
 * @param  addr  [IN] the address to read from
 * @return the value at addr
 */
unsigned short read2(unsigned long addr) {
    unsigned short val;
    volatile unsigned short* p = (volatile unsigned short*)addr;

    val = *p;
    PSII_SYNC();

    val = ((val & 0xFF00) >> 8) | ((val & 0x00FF) << 8);

#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("read2: addr=%08x *p=%04x -> val=%04x\n", addr, *p, val);
    }
#endif
    return val;
}

/**
 * Write one 4-byte word with byte swapping.
 * @param  addr  [IN] the address to write to
 * @param  val   [IN] the value to write
 */
void write4(unsigned long addr, unsigned long val) {
    volatile unsigned long* p = (volatile unsigned long*)addr;
#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("write4: addr=%08x val=%08x -> *p=%08x\n", addr, val,
            ((val & 0xFF000000) >> 24) | ((val & 0x000000FF) << 24) |
            ((val & 0x00FF0000) >> 8)  | ((val & 0x0000FF00) << 8));
        }
#endif
    *p = ((val & 0xFF000000) >> 24) | ((val & 0x000000FF) << 24) |
         ((val & 0x00FF0000) >> 8)  | ((val & 0x0000FF00) << 8);
    PSII_SYNC();
}

/**
 * Read one 4-byte word with byte swapping.
 * @param  addr  [IN] the address to read from
 * @return the value at addr
 */
unsigned long read4(unsigned long addr) {
    unsigned long val;
    volatile unsigned long* p = (volatile unsigned long*)addr;

    val = *p;
    val = ((val & 0xFF000000) >> 24) | ((val & 0x000000FF) << 24) |
          ((val & 0x00FF0000) >> 8)  | ((val & 0x0000FF00) << 8);
    PSII_SYNC();
#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("read4: addr=%08x *p=%08x -> val=%08x\n", addr, *p, val);
    }
#endif
    return val;
}

/** Attempts to read a value from PCI configuration space.
 * @param bus   Bus number.
 * @param dev	Device Number.
 * @param fn	Function Number.
 * @param width Size of value to read from configuration space. Valid for 1,2 or 4 bytes.
 * @param targetPCI2 If 0, this pci config access will target PCI-1, otherwise it will target PCI-2.
 * @param val	Address of long word for result of read.
 * @return Status of attempt to read pci configuration space.
 * @retval NO_DEVICE_FOUND No device Found.
 * @retval ILLEGAL_REG_OFFSET Bad register offset.
 * @retval 0	OK.
 */
int PCIReadConfig(int bus, int dev, int fn, int reg, int width, int targetPCI2, unsigned long* val){
    unsigned int conAdrVal = 0;
    unsigned int conDataReg = PSPAN_BASEADDR + REG_CONFIG_DATA + (reg & 3);
    unsigned int status;
    int ret_val = 0;

    if(targetPCI2){
        conAdrVal = (1 << 24);
    }

    /* TYPE bit is hardcoded to 1: all config cycles are local */
    conAdrVal |= ((bus & 0xFF) << 16)
              |  ((dev & 0xFF) << 11)
              |  ((fn & 0x07)  <<  8)
              |  (reg & 0xFC);

    /* clear any pending master aborts */
	PowerSpanSetBits(REG_P2_CSR,PX_CSR_R_MA);

    /* Load the conAdrVal value first, then read from pb_conf_data */
	PowerSpanWrite(REG_CONFIG_ADDRESS,conAdrVal);

    /* Note: documentation does not match the pspan library code */
    /* Note: *pData comes back as -1 if device is not present */
    switch (width){
        case 4:{
          *val = read4(conDataReg);
          break;
        }
        case 2:{
          *val = (unsigned long)read2(conDataReg);
          break;
        }
        case 1:{
          *val = (unsigned long)read1(conDataReg);
          break;
        }
        default:{
          ret_val = ILLEGAL_REG_OFFSET;
          break;
        }
    }

    /* clear any pending master aborts */
	status = PowerSpanRead(REG_P2_CSR);
    if(status & PX_CSR_R_MA){
        ret_val = NO_DEVICE_FOUND;
		PowerSpanSetBits(REG_P2_CSR,PX_CSR_R_MA);
    }

    return ret_val;
}

/** Attempts to write a value to PCI configuration space.
 * @param bus	Bus number.
 * @param dev	Device Number.
 * @param fn	Function number.
 * @param reg	PCI configuration register offset.
 * @param width	Size of write operation. Valid for 1,2 or 4 bytes.
 * @param targetPCI2 If 0, this pci config access will target PCI-1, otherwise it will target PCI-2.
 * @param val   Value to write to configuration space.
 * @return Status of the write operation.
 * @retval NO_DEVICE_FOUND No Device.
 * @retVal ILLEGAL_REG_OFFSET Invalid register offset.
 * @retval 0  OK.
 */
int PCIWriteConfig(int bus, int dev, int fn, int reg, int width, int targetPCI2, unsigned long val){
    unsigned int conAdrVal = 0;
    unsigned int conDataReg = PSPAN_BASEADDR + REG_CONFIG_DATA + (reg & 3);
    unsigned int status;
    int ret_val = 0;


    if(targetPCI2){
        conAdrVal = (1 << 24);
    }

    /* TYPE bit is hardcoded to 1: all config cycles are local */
    conAdrVal |= ((bus & 0xFF) << 16)
              |  ((dev & 0xFF) << 11)
              |  ((fn & 0x07)  <<  8)
              |  (reg & 0xFC);

    /* clear any pending master aborts */
	PowerSpanSetBits(REG_P2_CSR,PX_CSR_R_MA);

    /* Load the conAdrVal value first, then read from pb_conf_data */
	PowerSpanWrite(REG_CONFIG_ADDRESS,conAdrVal);


    /* Note: documentation does not match the pspan library code */
    /* Note: *pData comes back as -1 if device is not present */
    switch (width){
        case 4:{
          write4(conDataReg, val);
          break;
        }
        case 2:{
          write2(conDataReg, (unsigned short)val);
          break;
        }
        case 1:{
          write1(conDataReg, (unsigned char)val);
          break;
        }
        default:{
          ret_val = ILLEGAL_REG_OFFSET;
          break;
        }
    }

    /* clear any pending master aborts */
	status = PowerSpanRead(REG_P2_CSR);
    if(status & PX_CSR_R_MA){
        ret_val = NO_DEVICE_FOUND;
		PowerSpanSetBits(REG_P2_CSR,PX_CSR_R_MA);
    }

    return ret_val;
}

/** Attempts to read one byte from PCI configuration space.
 * @param bus	Bus number.
 * @param dev	Device Number.
 * @param fn	Function number.
 * @param reg	PCI configuration register offset.
 * @param val	Address of location for 1 byte response.
 * @return status of the operation.
 * @retval NO_DEVICE_FOUND No device.
 * @retval ILLEGAL_REG_OFFSET Invalid register offset.
 * @retval 0 OK.
 */
int pci_read_config_byte(int bus, int dev, int fn, int reg, unsigned char* val){
    unsigned long read_val;
    int ret_val;

    ret_val = PCIReadConfig(bus, dev, fn, reg, 1, 1, &read_val);
    *val = read_val & 0xFF;

    return ret_val;
}

/** Attempts to write one byte to PCI configuration space.
 * @param bus	Bus number.
 * @param dev	Device number.
 * @param fn	Function number.
 * @param reg	PCI configuration register offset.
 * @param val	Byte value to write to configuration location.
 * @return	Status of write operation.
 * @retval NO_DEVICE_FOUND	No device.
 * @retval ILLEGAL_REG_OFFSET	Invalid register offset.
 * @retval 0	OK.
 */
int pci_write_config_byte(int bus, int dev, int fn, int reg, unsigned char val){
    return PCIWriteConfig(bus, dev, fn, reg, 1, 1, (unsigned long) val);
}

/** Attempts to read one word (16 bits) from PCI configuration space.
 * @param bus	Bus number.
 * @param dev	Device Number.
 * @param fn	Function number.
 * @param reg	PCI configuration register offset.
 * @param val	Address of location to place value read from pci configuration space.
 * @return Status of the read operation.
 * @retval NO_DEVICE_FOUND No device.
 * @retval ILLEGAL_REG_OFFSET Invalid register offset.
 * @retval 0	OK
 */
int pci_read_config_word(int bus, int dev, int fn, int reg, unsigned short* val){
    unsigned long read_val;
    int ret_val;

    ret_val = PCIReadConfig(bus, dev, fn, reg, 2, 1, &read_val);
    *val = read_val & 0xFFFF;

    return ret_val;
}

/** Attempts to write a word (16 bits) to PCI configuration space.
 * @param bus	Bus number.
 * @param dev	Device number.
 * @param fn	Function number.
 * @param reg	PCI configuration register offset.
 * @param val	Word value to write to PCI configuration space.
 * @return Status of write operation.
 * @retval NO_DEVICE_FOUND	No device.
 * @retval ILLEGAL_REG_OFFSET	Invalid registers offset.
 * @retval 0 	OK.
 */
int pci_write_config_word(int bus, int dev, int fn, int reg, unsigned short val){
    return PCIWriteConfig(bus, dev, fn, reg, 2, 1, (unsigned long)val);
}

/** Attempts to read Dword (32 bits) from PCI configuration space.
 * @param bus	Bus number.
 * @param dev	Device number.
 * @param fn	Function number.
 * @param reg	PCI configuration register offset.
 * @param val	Address of location to return value read fro PCI configuration space.
 * @return Status of the read operation.
 * @retval NO_DEVICE_FOUND	No device.
 * @retval ILLEGAL_REG_OFFSET Invalid register offset.
 * @retval 0	OK.
 */
int pci_read_config_dword(int bus, int dev, int fn, int reg, unsigned long* val){
    return PCIReadConfig(bus, dev, fn, reg, 4, 1, val);
}


/** Attempts to write Dword (32 bits) value to PCI configuration space.
 * @param bus	Bus number.
 * @param dev	Device number.
 * @param fn	Function number.
 * @param reg	PCI configuration register offset.
 * @param val	Dword value to write to PCI configuration space.
 * @return Status of the write attempt.
 * @retval NO_DEVICE_FOUND	No device.
 * @retval ILLEGAL_REG_OFFSET	Invalid register offset.
 * @retval 0	OK.
 */
int pci_write_config_dword(int bus, int dev, int fn, int reg, unsigned long val){
    return PCIWriteConfig(bus, dev, fn, reg, 4, 1, val);
}

/**
 * Does a single I2C access (read or write).
 * @param theI2CAddress I2C address.
 * @param theDevCode    I2C device code.
 * @param theChipSel    I2C chip select.
 * @param theValue      The value to write, or the value read.
 * @param RWFlag        If I2C_WRITE, the access is a write, else it is a read
 *
 * @return Status of the access attempt.
 * @retval I2C_BUSY  I2C bus is already in use.
 * @retval I2C_ERR   An error is reported by the I2C bus.
 * @retval 0         If access succeeds.
 */
int I2CAccess(unsigned char theI2CAddress, unsigned char theDevCode, unsigned char theChipSel, unsigned char* theValue, int RWFlag){
    int ret_val = 0;
    unsigned int reg_value;

    reg_value = PowerSpanRead(REG_I2C_CSR);

    if(reg_value & I2C_CSR_ACT){
        printf("Error: I2C busy\n");
        ret_val = I2C_BUSY;
    }
    else{
		if (reg_value & I2C_CSR_ERR) {
		/* Clear error before access attempt. */
			PowerSpanWrite(REG_I2C_CSR,I2C_CSR_ERR);
		}

        reg_value = ((theI2CAddress & 0xFF) << 24)
                  | ((theDevCode & 0x0F) << 12)
                  | ((theChipSel & 0x07) << 9);

        if(RWFlag == I2C_WRITE){
            reg_value |= I2C_CSR_RW | ((*theValue & 0xFF) << 16);
        }

        PowerSpanWrite(REG_I2C_CSR, reg_value);
        udelay(1);

        do{
            reg_value = PowerSpanRead(REG_I2C_CSR);

            if((reg_value & I2C_CSR_ACT) == 0){
                if(reg_value & I2C_CSR_ERR){
                    ret_val = I2C_ERR;
					printf("I2C Error\n");
                }
                else{
                    *theValue = (reg_value & I2C_CSR_DATA) >> 16;
                }
            }
        } while(reg_value & I2C_CSR_ACT);
    }

    return ret_val;
}

/**
 * Do a read type I2CAccess().
 */
int EEPROMRead(unsigned char theI2CAddress, unsigned char* theValue){
    return I2CAccess(theI2CAddress, I2C_EEPROM_DEV, I2C_EEPROM_CHIP_SEL, theValue, I2C_READ);
}

/**
 * Do a write type I2CAccess().
 */
int EEPROMWrite(unsigned char theI2CAddress, unsigned char theValue){
    return I2CAccess(theI2CAddress, I2C_EEPROM_DEV, I2C_EEPROM_CHIP_SEL, &theValue, I2C_WRITE);
}

/**
 * eeprom r OFF [NUM]
 *     - read NUM words starting at OFF
 * eeprom w OFF VAL
 *     - write VAL to eeprom at OFF
 * eeprom g ADD
 *     - get contents of eeprom, store at address ADD
 * eeprom p ADD
 *     - put eeprom data stored at ADD into the eeprom
 * eeprom d
 *     - return eeprom to default contents
 *
 */
int do_eeprom(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    char cmd;
    int ret_val = 0;
    unsigned int address = 0;
    unsigned char value = 1;
    unsigned char read_value;
    int ii;
    int error = 0;
    unsigned char* mem_ptr;

    if(argc < 2){
        goto usage;
    }

    cmd = argv[1][0];
    if(argc > 2){
        address = simple_strtoul(argv[2], NULL, 16);
        if(argc > 3){
            value = simple_strtoul(argv[3], NULL, 16) & 0xFF;
        }
    }

    switch (cmd){
        case 'r':{
            if(address > 256){
                printf("Illegal Address\n");
                goto usage;
            }
            printf("@0x%x: ", address);
            for(ii = 0;ii < value;ii++){
                if(EEPROMRead(address + ii, &read_value) != 0){
                    printf("Read Error\n");
                }
                else{
                    printf("0x%02x ", read_value);
                }

                if(((ii + 1) % 16) == 0){
                    printf("\n");
                }
            }
            printf("\n");
            break;
        }
        case 'w':{
            if(address > 256){
                printf("Illegal Address\n");
                goto usage;
            }
            if(argc < 4){
                goto usage;
            }
            if(EEPROMWrite(address, value) != 0){
                printf("Write Error\n");
            }
            break;
        }
        case 'g':{
            if(argc != 3){
                goto usage;
            }
            mem_ptr = (unsigned char*)address;
            for(ii = 0;((ii < EEPROM_LENGTH) && (error == 0));ii++){
                if(EEPROMRead(ii, &read_value) != 0){
                    printf("Read Error\n");
                    error = 1;
                }
                else{
                    *mem_ptr = read_value;
                    mem_ptr++;
                }
            }
            break;
        }
        case 'p':{
            if(argc != 3){
                goto usage;
            }
            mem_ptr = (unsigned char*)address;
            for(ii = 0;((ii < EEPROM_LENGTH) && (error == 0));ii++){
                if(EEPROMWrite(ii, *mem_ptr) != 0){
                    printf("Write Error\n");
                    error = 1;
                }

                mem_ptr++;
            }
            break;
        }
        case 'd':{
            if(argc != 2){
                goto usage;
            }

            printf("Setting EEPROM...\n");
            if(SetEEPROMToDefault() != 1){
                printf("    Write Error\n");
            }
            else{
                printf("Verifying EEPROM...\n");
                if(VerifyDefaultEEPROM() != 1){
                    printf("    Verification Error\n");
                }
                else{
                    printf("Done.\n");
                }
            }
            break;
        }
        default:{
            goto usage;
        }
    }

    goto done;
 usage:
    printf ("Usage:\n%s\n", cmdtp->help);

 done:
     return ret_val;

}

/**
 * Write the default EEPROM contents to the EEPROM.
 * @retval 1 on success
 * @retval 0 on failure.
 */
int SetEEPROMToDefault(){
    int ret_val = 1;
    int ii;
    unsigned char default_eeprom[] = EEPROM_DEFAULT;

    for(ii = 0;((ii < EEPROM_LENGTH) && (ret_val == 1));ii++){
        if(EEPROMWrite(ii, default_eeprom[ii]) != 0){
            ret_val = 0;
        }
    }

    return ret_val;
}

/**
 * Verify that the EEPROM contains the default EEPROM contents.
 * @retval 1 on success
 * @retval 0 on failure.
 */
int VerifyDefaultEEPROM(){
    int ret_val = 1;
    int ii;
    unsigned char temp_char;
    unsigned char default_eeprom[] = EEPROM_DEFAULT;

    for(ii = 0;((ii < EEPROM_LENGTH) && (ret_val == 1));ii++){
        if(EEPROMRead(ii, &temp_char) != 0){
            printf("Read Error.\n");
            ret_val = 0;
        }
        else{
            if(temp_char != default_eeprom[ii]){
                printf("Data Error: 0x%02x should be 0x%02x (@ offset 0x%02x)\n", temp_char, default_eeprom[ii], ii);
                ret_val = 0;
            }
        }
    }

    return ret_val;
}


/**
 * Read the indicated register.
 * @param theOffset [IN] the register to access.
 * @return the value of the indicated register.
 */
unsigned int PowerSpanRead(unsigned int theOffset){
    volatile unsigned int* ptr = (volatile unsigned int*)(PSPAN_BASEADDR + theOffset);
    unsigned int ret_val;

#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("PowerSpanRead: offset=%08x ", theOffset);
    }
#endif
    ret_val = *ptr;
    PSII_SYNC();

#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("value=%08x\n", ret_val);
    }
#endif

    return ret_val;
}

/**
 * Write to the indicated register.
 * @param theOffset [IN] the register to access.
 * @param theValue  [IN] value to write to the register.
 */
void PowerSpanWrite(unsigned int theOffset, unsigned int theValue){
    volatile unsigned int* ptr = (volatile unsigned int*)(PSPAN_BASEADDR + theOffset);
#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("PowerSpanWrite: offset=%08x val=%02x\n", theOffset, theValue);
    }
#endif
    *ptr = theValue;
    PSII_SYNC();
}

/**
 * Sets the indicated bits in the indicated register.
 * @param theOffset [IN] the register to access.
 * @param theMask   [IN] bits set in theMask will be set in the register.
 */
void PowerSpanSetBits(unsigned int theOffset, unsigned int theMask){
    volatile unsigned int* ptr = (volatile unsigned int*)(PSPAN_BASEADDR + theOffset);
    unsigned int register_value;

#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("PowerSpanSetBits: offset=%08x mask=%02x\n", theOffset, theMask);
    }
#endif
    register_value = *ptr;
    PSII_SYNC();

    register_value |= theMask;
    *ptr = register_value;
    PSII_SYNC();
}

/**
 * Clears the indicated bits in the indicated register.
 * @param theOffset [IN] the register to access.
 * @param theMask   [IN] bits set in theMask will be cleared in the register.
 */
void PowerSpanClearBits(unsigned int theOffset, unsigned int theMask){
    volatile unsigned int* ptr = (volatile unsigned int*)(PSPAN_BASEADDR + theOffset);
    unsigned int register_value;

#ifdef VERBOSITY
    if(gVerbosityLevel > 1){
        printf("PowerSpanClearBits: offset=%08x mask=%02x\n", theOffset, theMask);
    }
#endif
    register_value = *ptr;
    PSII_SYNC();

    register_value &= ~theMask;
    *ptr = register_value;
    PSII_SYNC();
}

/**
 * Configures a slave image on the local bus, based on the parameters and some hardcoded system values.
 * Slave Images are images that cause the PowerSpan II to be a master on the PCI bus.  Thus, they
 *  are outgoing from the standpoint of the local bus.
 * PCI destination bus is PCI-1 (default).
 * @param theImageIndex    [IN] the PowerSpan II image to set (assumed to be 0-7).
 * @param theBlockSize     [IN] the block size of the image (as used by PowerSpan II: PB_SIx_CTL[BS]).
 * @param theMemIOFlag     [IN] if PX_TGT_USE_MEM_IO, this image will have the MEM_IO bit set.
 * @param theEndianness    [IN] the endian bits for the image (already shifted, use defines).
 * @param theLocalBaseAddr [IN] the Local address for the image (assumed to be valid with provided block size).
 * @param thePCIBaseAddr   [IN] the PCI address for the image (assumed to be valid with provided block size).
 */
int SetSlaveImage(int theImageIndex, unsigned int theBlockSize, int theMemIOFlag, int theEndianness, unsigned int theLocalBaseAddr, unsigned int thePCIBaseAddr)
{

	SetSlaveImage2(theImageIndex,theBlockSize,theMemIOFlag,theEndianness,theLocalBaseAddr,thePCIBaseAddr,0);
}

/**
 * Configures a slave image on the local bus, based on the parameters and some hardcoded system values.
 * Slave Images are images that cause the PowerSpan II to be a master on the specified PCI bus.  Thus, they
 *  are outgoing from the standpoint of the local bus.
 *
 * @param theImageIndex    [IN] the PowerSpan II image to set (assumed to be 0-7).
 * @param theBlockSize     [IN] the block size of the image (as used by PowerSpan II: PB_SIx_CTL[BS]).
 * @param theMemIOFlag     [IN] if PX_TGT_USE_MEM_IO, this image will have the MEM_IO bit set.
 * @param theEndianness    [IN] the endian bits for the image (already shifted, use defines).
 * @param theLocalBaseAddr [IN] the Local address for the image (assumed to be valid with provided block size).
 * @param thePCIBaseAddr   [IN] the PCI address for the image (assumed to be valid with provided block size).
 * @param destBus		   [IN] The PCI bus to use for access, 0 = PCI-1, 1 = PCI-2.
 */
int SetSlaveImage2(int theImageIndex, unsigned int theBlockSize, int theMemIOFlag, int theEndianness, unsigned int theLocalBaseAddr, unsigned int thePCIBaseAddr, int destBus)
{
    unsigned int reg_offset = theImageIndex * PB_SLAVE_IMAGE_OFF;
    unsigned int reg_value = 0;

    /* Setup the mask required for requested PB Slave Image configuration */
    reg_value = PB_SLAVE_CSR_TA_EN | theEndianness | (theBlockSize << 24) | PB_SLAVE_CSR_MODE;
    if(theMemIOFlag == PB_SLAVE_USE_MEM_IO){
	/* Generate 1,2 or 4 byte memory reads, otherwize do IO cycles. */
        reg_value |= PB_SLAVE_CSR_MEM_IO;
    }
	if (destBus) {	/* Use PCI-2 bus. */
		reg_value |= PB_SLAVE_CSR_DEST;
	}

    /* hardcoding the following:
        TA_EN = 1
        MD_EN = 0
		mode = 1
        PRKEEP = 0
        RD_AMT = 0
    */
    PowerSpanWrite((REGS_PB_SLAVE_CSR + reg_offset), reg_value);

    /* these values are not checked by software */
    PowerSpanWrite((REGS_PB_SLAVE_BADDR + reg_offset), theLocalBaseAddr);
    PowerSpanWrite((REGS_PB_SLAVE_TADDR + reg_offset), thePCIBaseAddr);

    /* Enable the Slave Image */
    PowerSpanWrite((REGS_PB_SLAVE_CSR + reg_offset), PB_SLAVE_CSR_IMG_EN | reg_value);

    return 0;
}

/**
 * Setup a target image on PCI-1 bus to local bus resources.
 * Configures a target image on the local bus, based on the parameters and some hardcoded system values.
 * Target Images are used when the PowerSpan II is acting as a target for an access.  Thus, they
 *  are incoming from the standpoint of the local bus.
 * In order to behave better on the host PCI bus, if thePCIBaseAddr is NULL (0x00000000), then the PCI
 *  base address will not be updated; makes sense given that the hosts own memory should be mapped to
 *  PCI address 0x00000000.
 * @param theImageIndex    [IN] the PowerSpan II image to set.
 * @param theBlockSize     [IN] the block size of the image (as used by PowerSpan II: Px_TIx_CTL[BS]).
 * @param theMemIOFlag     [IN] if PX_TGT_USE_MEM_IO, this image will have the MEM_IO bit set.
 * @param theEndianness    [IN] the endian bits for the image (already shifted, use defines).
 * @param theLocalBaseAddr [IN] the Local address for the image (assumed to be valid with provided block size).
 * @param thePCIBaseAddr   [IN] the PCI address for the image (assumed to be valid with provided block size).
 * @param targetPCI        [IN] Indicates whether to target local bus or the alternate PCI bus: 0 = local bus, !0 = PCI bus.
 */
int SetTargetImage(int theImageIndex, unsigned int theBlockSize, int theMemIOFlag, int theEndianness, unsigned int theLocalBaseAddr, unsigned int thePCIBaseAddr, int targetPCI){

    return(SetTargetImage2(theImageIndex, theBlockSize, theMemIOFlag, theEndianness, theLocalBaseAddr, thePCIBaseAddr, targetPCI, 0));
}

/**
 * Setup a target image on either PCI bus to local bus resources.
 * Configures a target image on the local bus, based on the parameters and some hardcoded system values.
 * Target Images are used when the PowerSpan II is acting as a target for an access.  Thus, they
 *  are incoming from the standpoint of the local bus.
 * In order to behave better on the host PCI bus (on PCI-1), if thePCIBaseAddr is NULL (0x00000000), then the PCI-1
 *  base address will not be updated; makes sense given that the hosts own memory should be mapped to
 *  PCI address 0x00000000.  Note that PCI-2 will accept base addresses of 0x00000000.
 * @param theImageIndex    [IN] the PowerSpan II image to set.
 * @param theBlockSize     [IN] the block size of the image (as used by PowerSpan II: Px_TIx_CTL[BS]).
 * @param theMemIOFlag     [IN] if PX_TGT_USE_MEM_IO, this image will have the MEM_IO bit set.
 * @param theEndianness    [IN] the endian bits for the image (already shifted, use defines).
 * @param theLocalBaseAddr [IN] the Local address for the image (assumed to be valid with provided block size).
 * @param thePCIBaseAddr   [IN] the PCI address for the image (assumed to be valid with provided block size).
 * @param targetPCI        [IN] Indicates whether to target local bus or the alternate PCI bus: 0 = local bus, !0 = PCI bus.
 * @param whichBus		   [IN] Indicates which PCI interface on powerspan, 0 = PCI-1 configuration, !0 = PCI-2 configuration.
 */
int SetTargetImage2(int theImageIndex, unsigned int theBlockSize, int theMemIOFlag, int theEndianness, unsigned int theLocalBaseAddr, unsigned int thePCIBaseAddr, int targetPCI, int whichBus)
{

    unsigned int csr_reg_offset = theImageIndex * P1_TGT_IMAGE_OFF;
    unsigned int pci_reg_offset = theImageIndex * P1_BST_OFF;
    unsigned int reg_value = 0;
	unsigned int targetCSR = REGS_P1_TGT_CSR;
	unsigned int translationAddr = REGS_P1_TGT_TADDR;
	unsigned int baseAddr = REGS_P1_BST0;

	if (whichBus) {
		targetCSR += 0x800;
		translationAddr += 0x800;
		baseAddr += 0x800;
	}


    /* Make sure that the Slave Image is disabled */
    /*    PowerSpanClearBits((targetCSR + csr_reg_offset), PB_SLAVE_CSR_IMG_EN); */
	PowerSpanWrite(targetCSR + csr_reg_offset,0);

    /* Setup the mask required for requested PB Slave Image configuration */
    reg_value = PX_TGT_CSR_TA_EN | PX_TGT_CSR_BAR_EN | (theBlockSize << 24) | PX_TGT_CSR_RTT_READ | PX_TGT_CSR_WTT_WFLUSH | theEndianness;

    if(theMemIOFlag == PX_TGT_USE_MEM_IO){
        reg_value |= PX_TGT_MEM_IO;
    }

    if(targetPCI){
        reg_value |= PX_TGT_PCI2;
    }

    /* hardcoding the following:
        TA_EN = 1
        BAR_EN = 1
        MD_EN = 0
        MODE  = 0
        DEST  = 0
        RTT = 01010
        GBL = 0
        CI = 0
        WTT = 00010
        PRKEEP = 0
        MRA = 0
        RD_AMT = 0
    */
    PowerSpanWrite((targetCSR + csr_reg_offset), reg_value);

    PowerSpanWrite((translationAddr + csr_reg_offset), theLocalBaseAddr);

    if((thePCIBaseAddr != NULL) || (whichBus)){
        PowerSpanWrite((baseAddr + pci_reg_offset), thePCIBaseAddr);
    }

    /* Enable the Slave Image */
    PowerSpanWrite((targetCSR + csr_reg_offset), reg_value | PB_SLAVE_CSR_IMG_EN);

    return 0;
}

#if 0
int do_bridge(cmd_tbl_t *cmdtp, int flag, int argc, char *argv[]){
    char cmd;
    int ret_val = 1;
    unsigned int image_index;
    unsigned int block_size;
    unsigned int mem_io;
    unsigned int local_addr;
    unsigned int pci_addr;
    int endianness;

    if(argc != 8){
        goto usage;
    }

    cmd = argv[1][0];
    image_index = simple_strtoul(argv[2], NULL, 16);
    block_size  = simple_strtoul(argv[3], NULL, 16);
    mem_io      = simple_strtoul(argv[4], NULL, 16);
    endianness  = argv[5][0];
    local_addr  = simple_strtoul(argv[6], NULL, 16);
    pci_addr    = simple_strtoul(argv[7], NULL, 16);


    switch (cmd){
        case 'i':{
            if(tolower(endianness) == 'b'){
                endianness = PX_TGT_CSR_BIG_END;
            }
            else if(tolower(endianness) == 'l'){
                endianness = PX_TGT_CSR_TRUE_LEND;
            }
            else{
                goto usage;
            }
            SetTargetImage(image_index, block_size, mem_io, endianness, local_addr, pci_addr);
            break;
        }
        case 'o':{
            if(tolower(endianness) == 'b'){
                endianness = PB_SLAVE_CSR_BIG_END;
            }
            else if(tolower(endianness) == 'l'){
                endianness = PB_SLAVE_CSR_TRUE_LEND;
            }
            else{
                goto usage;
            }
            SetSlaveImage(image_index, block_size, mem_io, endianness, local_addr, pci_addr);
            break;
        }
        default:{
            goto usage;
        }
    }

    goto done;
 usage:
    printf ("Usage:\n%s\n", cmdtp->help);

 done:
     return ret_val;

}
#endif /* #if 0 */
