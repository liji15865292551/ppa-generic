#
# make include file - build AArch64 PPA
#
# Copyright (C) 2015, 2016 Freescale Semiconductor, Inc. All rights reserved.
#
# -----------------------------------------------------------------------------
#
# rdb platform specific definitions
#
# supported targets:
#   rdb     - binary image
#   rdb_fit - fit image
#
# -----------------------------------------------------------------------------
#
# builds a binary image for the rdb board
rdb: 
	$(MAKE) SIM_BUILD=0 rdb_out
	$(MAKE) SIM_BUILD=0 monitor.bin
rdb_out:
	@echo 'build: image=bin \ $(GIC_FILE) \ $(INTER_FILE) \ ddr $(DDR) \ debug $(DBG) \ test "$(TEST)"'
	@echo

# builds a fit image for the rdb board
rdb-fit: 
	$(MAKE) SIM_BUILD=0 rdb_fit_out
	$(MAKE) SIM_BUILD=0 ppa.itb
rdb_fit_out:
	@echo 'build: image=fit \ $(GIC_FILE) \ $(INTER_FILE) \ ddr $(DDR) \ debug $(DBG) \ test "$(TEST)"'
	@echo

# -----------------------------------------------------------------------------

# add psci-related source and headers here
SRC_PSCI   =psci.s
HDRS_PSCI  =psci.h psci_data.h

# add soc-specific asm source and headers here
SRC_SOC    =soc.s
HDRS_SOC   =soc.h soc.mac

# add soc-specific C source and headers here
CSRC_SOC   =
CHDRS_SOC  =

# add arm-specific source and headers here
SRC_ARMV8  =aarch64.s $(INTER_FILE).s $(GIC_FILE).s
HDRS_ARMV8 =aarch64.h

# add security-monitor source and headers here
SRC_MNTR   =monitor.s smc64.s smc32.s vector.s
HDRS_MNTR  =smc.h smc_data.h

# add platform-specific asm here
PLAT_ASM =

# add platform-specific C source and headers here
SRC_PLAT   =
HDRS_PLAT  =policy.h

# add platform-test-specific asm files here
TEST_ASM =$(TEST_FILE)

ifeq ($(DDR_BLD), 1)
  # add ddr-specific source and headers here
  DDR_C    =ddr_init.c
  DDR_HDRS =plat.h

  # add sources for the ddr, i2c, and uart drivers here
  DRIVER_C = utility.c regs.c ddr.c ddrc.c dimm.c opts.c debug.c crc32.c spd.c \
	addr.c uart.c i2c.c timer.c
  DRIVER_HDRS = utility.h lsch2.h immap.h ddr.h dimm.h opts.h regs.h debug.h \
	errno.h io.h i2c.h lib.h timer.h uart.h
else
  DDR_C       =
  DDR_HDRS    =
  DRIVER_C    =
  DRIVER_HDRS =
endif

# -----------------------------------------------------------------------------

