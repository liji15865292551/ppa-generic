#
# make include file - build AArch64 PPA
#
# Copyright (C) 2015, 2016 Freescale Semiconductor, Inc. All rights reserved.
#
# -----------------------------------------------------------------------------

# select the test files ----------
ifeq ($(TEST), smp_boot)
	TEST_PSCI=1
    ifeq ($(NUMBER_OF_CLUSTERS), 1)
        TEST_FILE=test_cpu_on_1cluster.s
    else
    ifeq ($(NUMBER_OF_CLUSTERS), 2)
        TEST_FILE=test_cpu_on_2cluster.s
    else
    ifeq ($(NUMBER_OF_CLUSTERS), 4)
        TEST_FILE=test_cpu_on_4cluster.s
    else
    ifeq ($(NUMBER_OF_CLUSTERS), 8)
        TEST_FILE=test_cpu_on_8cluster.s
    else
        $(error -> Number of Clusters not set!)
    endif
    endif
    endif
    endif
else
ifeq ($(TEST), hotplug)
	TEST_PSCI=1
    TEST_FILE=test_cpu_hotplug.s
else
ifeq ($(TEST), off_abort)
	TEST_PSCI=1
    TEST_FILE=test_cpu_hotplug_abort.s
else
ifeq ($(TEST), suspend)
	TEST_PSCI=1
    TEST_FILE=test_cpu_suspend_1cluster.s
else
ifeq ($(TEST), aarch32)
	TEST_PSCI=1
    TEST_FILE=test_aarch32_2core.s
else
ifeq  ($(TEST), aarch32BE)
	TEST_PSCI=1
    TEST_FILE=test_aarch32_2coreBE.s
else
ifeq  ($(TEST), prng)
	TEST_PSCI=1
    TEST_FILE=test_prng.s
else
ifeq  ($(TEST), membank)
	TEST_PSCI=1
    TEST_FILE=test_membank_data.s
else
ifeq  ($(TEST), sys_off)
	TEST_PSCI=1
    ifeq ($(NUMBER_OF_CORES), 1)
        TEST_FILE=test_sysoff_1core.s
    else
        TEST_FILE=test_sysoff_multi.s
    endif
else
	TEST_PSCI=0
    TEST_FILE=
endif
endif
endif
endif
endif
endif
endif
endif
endif

# -----------------------------------------------------------------------------

