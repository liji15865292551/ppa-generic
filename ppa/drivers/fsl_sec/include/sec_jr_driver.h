//-----------------------------------------------------------------------------
// 
// Copyright 2017 NXP Semiconductors
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 
// Authors:
//  Alexandru Porosanu <alexandru.porosanu@nxp.com>
//  Ruchika Gupta <ruchika.gupta@nxp.com> 
//
//-----------------------------------------------------------------------------

#ifndef _JR_DRIVER_H_
#define _JR_DRIVER_H_

#include "types.h"
#include "jr_driver_config.h"

 // The maximum size of a SEC descriptor, in WORDs (32 bits). 
#define MAX_DESC_SIZE_WORDS		64

 // Return codes for JR user space driver APIs 
typedef enum sec_return_code_e {
	SEC_SUCCESS = 0,		// Operation executed successfully 
	SEC_INVALID_INPUT_PARAM,	// API received an invalid input parameter 
	SEC_OUT_OF_MEMORY,		// Memory allocation failed 
	SEC_DESCRIPTOR_IN_FLIGHT,	// API function indicates there are
					//   descriptors in flight for SEC to
					//  process 
	SEC_LAST_DESCRIPTOR_IN_FLIGHT,	// API function indicates there is one
					//   last descriptor in flight for SEC to
					//   process that 
	SEC_PROCESSING_ERROR,		// Indicates a SEC processing error
					//   occurred on Job Ring which requires
					//   a JR User Space driver shutdown.
					//   Can be returned from 
					//   sec_poll_job_ring(). Then the only
					//   other API that can be called after
					//   this error is sec_release(). 
	SEC_DESC_PROCESSING_ERROR,	// Indicates SEC descriptor processing
					//   error occurred on a Job Ring. Can be
					//   returned from sec_poll_job_ring().
					//   The driver was able to reset JR and
					//   JR can be used like normal case. 
	SEC_JR_IS_FULL,			// Job Ring is full. There is no more
					//   room in the JR for new descriptors.
					//   This can happen if the descriptor RX
					//   rate is higher than SEC capacity. 
	SEC_DRIVER_RELEASE_IN_PROGRESS,	// JR driver shutdown is in progress,
					//   descriptors processing or polling is
					//   allowed. 
	SEC_DRIVER_ALREADY_INITIALIZED, // JR driver is already initialized 
	SEC_DRIVER_NOT_INITIALIZED,	// JR driver is NOT initialized 
	SEC_JOB_RING_RESET_IN_PROGRESS,	// Job ring is resetting due to a
					//   per-descriptor SEC processing error
					//   ::SEC_desc_PROCESSING_ERROR.
					//   Reset is finished when
					//   sec_poll_job_ring() return.
					//  Then the job ring can be used again. 
	SEC_RESET_ENGINE_FAILED,	// Reset of SEC Engine by SEC Kernel
					//  Driver Failed  
	SEC_ENABLE_IRQS_FAILED,		// Enabling IRQs in SEC Kernel Driver
					//   Failed 
	SEC_DISABLE_IRQS_FAILED,	// Disabling IRQs in SEC Kernel Driver
					//   Failed 
	// END OF VALID VALUES 

	SEC_RETURN_CODE_MAX_VALUE,	// Invalid value for return code.
					//   It is used to mark the end of the
					//   return code values.
					//@note ALL new return code values MUST
					//be added before
					//::SEC_RETURN_CODE_MAX_VALUE! 
} sec_return_code_t;

 // 			STRUCTURES AND OTHER TYPEDEFS

 // @brief Function called by JR User Space driver to notify every processed
 //         descriptor.
 // 
 // Callback provided by the User Application.
 // Callback is invoked by JR User Space driver for each descriptor processed by
 // SEC
 // @param [in] status		Status word indicating processing result for
 //                                this descriptor.
 // @param [in] arg		  Opaque data passed by User Application
 //                                It is opaque from JR driver's point of view.
 // @param [in] job_ring           The job ring handle on which the processed
 // 				  descriptor word was enqueued
typedef void (*user_callback)(uint32_t *desc, uint32_t status,
			      void *arg, void *job_ring);

 // Structure encompassing a job descriptor which is to be processed
 // by SEC. User should also initialise this structure with the callback
 // function pointer which will be called by driver after recieving proccessed
 // descriptor from SEC. User data is also passed in this data structure which
 // will be sent as an argument to the user callback function.
struct job_descriptor {
	user_callback callback;
	void *arg;
	uint32_t desc[MAX_DESC_SIZE_WORDS];
};

 // @brief Initialize the JR User Space driver.
 // This function will handle initialization of sec library
 // along with registering platform specific callbacks,
 // as well as local data initialization.
 // Call once during application startup.
 // @note Global SEC initialization is done in SEC kernel driver.
 // @note The hardware IDs of the initialized Job Rings are opaque to the UA.
 // The exact Job Rings used by this library are decided between SEC user
 // space driver and SEC kernel driver. A static partitioning of Job Rings is
 // assumed, configured in DTS(device tree specification) file.
 // @param [in] platform_cb    	Registering the platform specific
 //				callbacks with driver
 // @retval ::0			for successful execution
 // @retval ::-1  		failure
int sec_jr_lib_init(void);

 // @brief Initialize the software and hardware resources tied to a job ring.
 // @param [in] jr_mode;		Model to be used by SEC Driver to recieve
 //				notifications from SEC.  Can be either
 //				SEC_NOTIFICATION_TYPE_IRQ or
 //				SEC_NOTIFICATION_TYPE_POLL
 // @param [in] irq_coalescing_timer This value determines the maximum
 // 					amount of time after processing a
 // 					descriptor before raising an interrupt.
 // @param [in] irq_coalescing_count This value determines how many
 // 					descriptors are completed before
 // 					raising an interrupt.
 // @param [in] reg_base_addr	The job ring base address register
 // @param [in] irq_id		The job ring interrupt identification number.
 // @retval  job_ring_handle for successful job ring configuration
 // @retval  NULL on error
void *init_job_ring(uint8_t jr_mode,
			uint16_t irq_coalescing_timer,
			uint8_t irq_coalescing_count,
			void *reg_base_addr, uint32_t irq_id);

 // @brief Release the resources used by the JR User Space driver.
 // Reset and release SEC's job rings indicated by the User Application at
 // init_job_ring() and free any memory allocated internally.
 // Call once during application tear down.
 // @note In case there are any descriptors in-flight (descriptors received by
 // JR driver for processing and for which no response was yet provided to UA),
 // the descriptors are discarded without any notifications to User Application.
 // @retval ::0			is returned for a successful execution
 // @retval ::-1		is returned if JR driver release is in progress
int sec_release(void);


 //
 // @brief Submit a descriptor for SEC processing.
 // This function creates a "job" which is meant to instruct SEC HW
 // to perform the processing on the input buffer. The "job" is enqueued
 // in the Job Ring associated. The function will return after the "job"
 // enqueue is finished. The function will not wait for SEC to
 // start or/and finish the "job" processing.
 // After the processing is finished the SEC HW writes the processing result
 // to the provided output buffer.
 // The Caller must poll JR driver using jr_dequeue()
 // to receive notifications of the processing completion
 // status. The notifications are received by caller by means of callback
 // (see ::user_callback).
 // @param [in]  job_ring_handle   The handle of the job ring on which
 // 				   descriptor is to be enqueued
 // @param [in]  job_descriptor    The job descriptor structure of type
 // 				   struct job_descriptor. This structure
 // 				   should be filled with job descriptor along
 // 				   with callback function to be called after
 // 				   processing of descriptor and some
 // 				   opaque data passed to be passed to the
 // 				   callback function
 // 
 // @retval ::0 		is returned for successful execution
 // @retval ::-1 		is returned if there is some enqueue failure
int enq_jr_desc(void *job_ring_handle,
			struct job_descriptor *jobdescr);

 // @brief Polls for available descriptors processed by SEC on a specific
 // Job Ring
 // This function polls the SEC Job Rings and delivers processed descriptors
 // Each processed descriptor has a user_callback registered.
 // This user_callback is invoked for each processed descriptor.
 // The polling is stopped when "limit" descriptors are notified or when
 // there are no more descriptors to notify.
 // @note The dequeue_jr() API cannot be called from within a user_callback
 // function
 // @param [in]  job_ring_handle    The Job Ring handle.
 // @param [in]  limit              This value represents the maximum number
 // 				    of processed descriptors that can be
 // 				    notified API call on this Job Ring.
 //                                 Note that fewer descriptors may be notified
 //				    if enough processed descriptors are not
 // 				    available.
 //                                 If limit has a negative value, then all
 // 				    ready descriptors will be notified.
 // 
 // @retval :: >=0                  is returned where retval is the total
 // 				    Number of descriptors notified 
 // 				    during this function call.
 // @retval :: -1     		    is returned in case of some error
 
int dequeue_jr(void *job_ring_handle,
	    int32_t limit);

 // To enable irqs on associated irq_id
int jr_enable_irqs(uint32_t irq_id);

 // To disable irqs on associated irq_id
int jr_disable_irqs(uint32_t irq_id);

#endif // _JR_DRIVER_H_ 
